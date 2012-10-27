
## gpd auto-completion and alias

if complete &>/dev/null; then
	_gpd_completion () {
                COMPREPLY=($(COMP_CWORD="$COMP_CWORD" \
                        COMP_LINE="$COMP_LINE" \
                        COMP_POINT="$COMP_POINT" \
                        gpd autocomplete )) || return $?
	}

	complete -F _gpd_completion gpd
fi

export PATH=$PATH:~/.gpd/bin

## end of gpd settings
