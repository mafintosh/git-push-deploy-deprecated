
## gpd auto-completion and path inclusion
if complete &>/dev/null; then
	_gpd_completion () {
                COMPREPLY=($(COMP_CWORD="$COMP_CWORD" COMP_LINE="$COMP_LINE" gpd autocomplete)) || return $?
	}
	complete -F _gpd_completion gpd
fi
export PATH=$PATH:~/.gpd/bin
## end of gpd settings
