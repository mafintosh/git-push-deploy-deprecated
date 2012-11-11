#!/bin/bash

## HELPERS

error () {
	echo $* 1>&2
	exit 1
}

template () {
	cat $1 | sed s/\{name\}/$NAME/g | sed s\|\{app\}\|$APPS/$NAME\|g | sed s\|\{build-pack\}\|$BUILD_PACK\|g | sed s\|\{log\}\|$LOG/$NAME\.log\|g | sed s\|\{gpd\}\|$GPD\|g
}

app-exists () {
	[ ! -e $APPS/$NAME ] && error $NAME does not exist
}


## ENVIRONMENT

GPD=/home/ubuntu/gpd
APPS=$GPD/apps
REPOS=/git

CWD=$PWD
ARGV=$*

cd $(dirname $0)

DIRNAME=$PWD
BUILD_PACK=$DIRNAME/build-packs/node
LOG=/var/log

NAME=$2


## COMMANDS

cmd-add () {
	[ -e $APPS/$NAME ] && error app already exists

	# making sure everything is ready to go

	sudo mkdir -p $REPOS
	sudo chown ubuntu.ubuntu $REPOS
	mkdir -p $APPS
	mkdir -p $REPOS/$NAME.git

	cd $REPOS/$NAME.git || exit 1

	# git magic

	git init --quiet --bare 2> /dev/null
	git clone $REPOS/$NAME.git $APPS/$NAME --quiet 2> /dev/null

	# setup upstart hooks

	template $BUILD_PACK/upstart.conf > /tmp/$NAME.conf
	sudo chown root.root /tmp/$NAME.conf
	sudo mv /tmp/$NAME.conf /etc/init/$NAME.conf

	template $BUILD_PACK/restart.sh > $REPOS/$NAME.git/hooks/post-receive
	chmod +x $REPOS/$NAME.git/hooks/post-receive

	echo $REPOS/$NAME.git
}

cmd-start () {
	app-exists
	sudo service $NAME start
}

cmd-stop () {
	app-exists
	sudo service $NAME stop
}

cmd-restart () {
	app-exists
	$REPOS/$NAME.git/hooks/post-receive
}

cmd-restart-force () {
	app-exists
	sudo service $NAME restart
}

cmd-ls () {
	ls $GPD/apps
}

cmd-rm () {
	app-exists
	sudo service $NAME stop 2> /dev/null > /dev/null

	sudo rm -f /etc/init/$NAME.conf
	sudo rm -rf $LOG/$NAME.log
	rm -rf $REPOS/$NAME.git
	rm -rf $APPS/$NAME
}

cmd-tail () {
	app-exists
	tail $LOG/$NAME.log -f
}

cmd-log () {
	app-exists
	cat $LOG/$NAME.log
}

cmd-add-proxy () {
	template $GPD/proxy/upstart.conf > /tmp/proxy.conf
	sudo chown root.root /tmp/proxy.conf
	sudo mv /tmp/proxy.conf /etc/init/proxy.conf

	sudo service proxy start
}

cmd-remove-proxy () {
	sudo service proxy stop
	sudo rm -f /etc/init/proxy.conf
}

## BOOTSTRAP

cmd-$1
