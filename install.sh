#!/bin/bash

append () {
	[ -e ~/.$1 ] && grep -v "## gpd " ~/.$1 > /dev/null && cat ~/.gpd/bashrc >> ~/.$1
}

append bashrc
append bash_profile

git clone git@github.com:mafintosh/gpd.git ~/.git
