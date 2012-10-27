#!/bin/bash

append () {
	[ -e ~/.$1 ] && grep -v "## gpd " ~/.$1 > /dev/null && cat ~/.gpd/bashrc >> ~/.$1
}

git clone git@github.com:mafintosh/gpd.git ~/.gpd

append bashrc
append bash_profile

. ~/.gpd/bashrc