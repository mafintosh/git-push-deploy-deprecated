#!/bin/bash

append-to () {
	[ -e ~/.$1 ] && grep -v "## gpd " ~/.$1 > /dev/null && cat ~/.gpd/bashrc >> ~/.$1
}

append-to bashrc
append-to bash_profile
