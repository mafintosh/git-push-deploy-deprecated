#!/bin/bash

## HELPERS

error () {
	echo $* 1>&2
	exit 1
}

autocomplete () {
	[ "$CMD" != "autocomplete" ] && return 0

	WORD=$(echo $COMP_LINE | tr " " "\n" | tail -n +2 | tail -n +$COMP_CWORD | head -n 1)
	[ "$COMP_CWORD" == "1" ] && echo $* | tr " " "\n" | grep ^$WORD
	[ "$COMP_CWORD" == "2" ] && cat ~/.ssh/known_hosts 2> /dev/null | sed 's/[, ].*//' | grep ^$WORD
	exit 0
}

is-git-repo () {
	cd $CWD
	[ -d .git ] || git rev-parse --git-dir > /dev/null 2>&1
}

tag () {
	echo $ARGV | grep -e "-$1 " -e "-$1$" -e "--$2 " -e "--$2$" > /dev/null
	return $?
}
arg () {
	ARG=$(echo $ARGV | grep -e "-$1 " -e "--$2 " | sed "s/.*-$1 \([^ ]*\).*/\1/g" | sed "s/.*--$2 \([^ ]*\).*/\1/")
	([ "$ARG" == "" ] && echo $3) || echo $ARG
}

remote () {
	ssh ubuntu@$DOMAIN $GPD/remote.sh $*
}


## ENVIRONMENT

GPD=\~/gpd
CWD=$PWD
ARGV=$*
ARGV_CMD=${@:2}
CMD=$1
DOMAIN=$2
NAME=$(arg n name $DOMAIN)

cd $(dirname $(readlink $0 || echo $0))
DIRNAME=$PWD
BUILD_PACK=$DIRNAME/build-packs/$(arg bp build-pack node)


## COMMANDS

cmd-add-user () {
	[ ! -e ~/.ssh/id_rsa.pub ] && error could not find ssh public key. run ssh-keygen

	SSH_PUBLIC_KEY=$(cat ~/.ssh/id_rsa.pub)
	AUTH_KEYS=\~/.ssh/authorized_keys
	ssh $ARGV_CMD mkdir -p \~/.ssh\; touch $AUTH_KEYS\; grep \"$SSH_PUBLIC_KEY\" $AUTH_KEYS \> /dev/null \|\| echo \"$SSH_PUBLIC_KEY\" \>\> $AUTH_KEYS
}

cmd-publish () {
	cd $DIRNAME
	ssh ubuntu@$DOMAIN mkdir -p $GPD
	ssh ubuntu@$DOMAIN cd $GPD\; rm -rf $(ls)
	tar c . | ssh ubuntu@$DOMAIN tar x -C $GPD \2\> /dev/null
}

cmd-config () {
	echo DOMAIN is $DOMAIN
	echo NAME is $NAME
	echo DIRNAME is $DIRNAME
	echo BUILD_PACK is $BUILD_PACK
	echo FORCE is $(tag f force || echo not) set
}

cmd-clone () {
	git clone ubuntu@$DOMAIN:/git/$NAME.git $CWD/$NAME
}

cmd-restart () {
	tag f force || remote restart $NAME
	tag f force && remote restart-force $NAME
}

cmd-start () {
	remote start $NAME
}

cmd-stop () {
	remote stop $NAME
}

cmd-tail () {
	remote tail $NAME
}

cmd-add () {
	! is-git-repo && error $(basename $PWD) is not a git repository

	GIT_REPO=$(remote add $NAME) || exit 1
	git remote add $NAME ubuntu@$DOMAIN:$GIT_REPO 2> /dev/null

	echo added $NAME as a git remote
}

cmd-rm () {
	remote rm $NAME || exit 1
	is-git-repo && git remote rm $NAME 2> /dev/null
}

cmd-add-proxy () {
	remote add-proxy
}

cmd-rm-proxy () {
	remote rm-proxy
}

cmd-update () {
	cd $DIRNAME
	git pull
}

## BOOTSTRAP

autocomplete $(cat $DIRNAME/local.sh | grep cmd-[a-z] | sed 's/cmd-\([^ ]*\).*/\1/')

[ "$DOMAIN" == "" ] && error usage: gpd cmd domain

cmd-$1
