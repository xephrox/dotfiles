#!/usr/bin/env bash

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# Run fastfetch at startup (only if installed)
if [ -f /usr/bin/fastfetch ]; then
	fastfetch
fi

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

# Enable bash completion
if [ -f /usr/share/bash-completion/bash_completion ]; then
	. /usr/share/bash-completion/bash_completion
elif [ -f /etc/bash_completion ]; then
	. /etc/bash_completion
fi

# Disable the annoying bell
bind "set bell-style visible"

# XDG Base Directories
XDG_DATA_HOME="$HOME/.local/share"
XDG_CONFIG_HOME="$HOME/.config"
XDG_STATE_HOME="$HOME/.local/state"
XDG_CACHE_HOME="$HOME/.cache"

# Expand the history size
export HISTFILESIZE=10000
export HISTSIZE=500
export HISTTIMEFORMAT="%F %T"

# Don't record duplicate/space-prefixed commands in history
export HISTCONTROL=erasedups:ignoredups:ignorespace

# Update window size after each command
shopt -s checkwinsize

# Append to the history file, don't overwrite it
shopt -s histappend
PROMPT_COMMAND='history -a'

# Case-insensitive completion
bind "set completion-ignore-case on"

# Auto-completion with single Tab
bind "set show-all-if-ambiguous On"

# Enable colors for ls and grep
export CLICOLOR=1
export LS_COLORS='no=00:fi=00:di=00;34:ln=01;36:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:ex=01;32:*.tar=01;31:*.tgz=01;31:*.arj=01;31:*.taz=01;31:*.lzh=01;31:*.zip=01;31:*.z=01;31:*.Z=01;31:*.gz=01;31:*.bz2=01;31:*.deb=01;31:*.rpm=01;31:*.jar=01;31:*.jpg=01;35:*.jpeg=01;35:*.gif=01;35:*.bmp=01;35:*.pbm=01;35:*.pgm=01;35:*.ppm=01;35:*.tga=01;35:*.xbm=01;35:*.xpm=01;35:*.tif=01;35:*.tiff=01;35:*.png=01;35:*.mov=01;35:*.mpg=01;35:*.mpeg=01;35:*.avi=01;35:*.fli=01;35:*.gl=01;35:*.dl=01;35:*.xcf=01;35:*.xwd=01;35:*.ogg=01;35:*.mp3=01;35:*.wav=01;35:*.xml=00;31:'

# Colored manpages
export LESS_TERMCAP_mb=$'\E[01;31m'
export LESS_TERMCAP_md=$'\E[01;31m'
export LESS_TERMCAP_me=$'\E[0m'
export LESS_TERMCAP_se=$'\E[0m'
export LESS_TERMCAP_so=$'\E[01;44;33m'
export LESS_TERMCAP_ue=$'\E[0m'
export LESS_TERMCAP_us=$'\E[01;32m'

#region General Aliases
alias cp='cp -i'
alias mv='mv -i'
alias rm='trash -v'
alias mkdir='mkdir -p'
alias ping='ping -c 10'
alias less='less -R'
alias grep='grep --color=auto'
alias vim='nvim'

# Custom quick access
alias cdc='cd /storage/media/code'
alias devtime='cdc && just dev'

# Recursive delete
alias rmd='/bin/rm --recursive --force --verbose'

# Replace cat with bat
alias catr='cat' # cat raw
alias cat='bat'

# Alias's for multiple directory listing commands
alias la='ls -Alh'                # show hidden files
alias ls='ls -aFh --color=always' # add colors and file type extensions
alias lx='ls -lXBh'               # sort by extension
alias lk='ls -lSrh'               # sort by size
alias lc='ls -ltcrh'              # sort by change time
alias lu='ls -lturh'              # sort by access time
alias lr='ls -lRh'                # recursive ls
alias lt='ls -ltrh'               # sort by date
alias lm='ls -alh |more'          # pipe through 'more'
alias lw='ls -xAh'                # wide listing format
alias ll='ls -Fls'                # long listing format
alias labc='ls -lap'              # alphabetical sort
alias lf="ls -l | egrep -v '^d'"  # files only
alias ldir="ls -l | egrep '^d'"   # directories only
alias lla='ls -Al'                # List and Hidden Files
alias las='ls -A'                 # Hidden Files
alias lls='ls -l'                 # List

# Archive commands
alias mktar='tar -cvf'
alias mkbz2='tar -cvjf'
alias mkgz='tar -cvzf'
alias untar='tar -xvf'
alias unbz2='tar -xvjf'
alias ungz='tar -xvzf'

# Clean up all Docker resources
alias docker-clean=' \
    docker container prune -f ; \
    docker image prune -f ; \
    docker network prune -f ; \
    docker volume prune -f '

#endregion

#######################################################
# SPECIAL FUNCTIONS
#######################################################

# Extracts any archive(s)
extract() {
	for archive in "$@"; do
		if [ -f "$archive" ]; then
			case $archive in
			*.tar.bz2) tar xvjf "$archive" ;;
			*.tar.gz) tar xvzf "$archive" ;;
			*.bz2) bunzip2 "$archive" ;;
			*.rar) rar x "$archive" ;;
			*.gz) gunzip "$archive" ;;
			*.tar) tar xvf "$archive" ;;
			*.tbz2) tar xvjf "$archive" ;;
			*.tgz) tar xvzf "$archive" ;;
			*.zip) unzip "$archive" ;;
			*.Z) uncompress "$archive" ;;
			*.7z) 7z x "$archive" ;;
			*) echo "don't know how to extract '$archive'..." ;;
			esac
		else
			echo "'$archive' is not a valid file!"
		fi
	done
}

# Internal and external IP address lookup
whatsmyip() {
	# Get internal (local) IP - default interface
	echo -n "Internal IP: "
	ip route get 1.1.1.1 2>/dev/null | awk '{for(i=1;i<=NF;i++) if ($i=="src") print $(i+1)}'

	# Get external (public) IP
	echo -n "External IP: "
	curl -s https://ifconfig.me
}

# Trim leading and trailing whitespace
trim() {
	local var=$*
	var="${var#"${var%%[![:space:]]*}"}" # leading
	var="${var%"${var##*[![:space:]]}"}" # trailing
	echo -n "$var"
}

check_missing_plasma_meta_deps() {
	local cache_dir="$HOME/.cache/plasma-meta"
	local today_file="$cache_dir/deps-$(date +%Y%m%d).txt"
	local latest_file

	mkdir -p "$cache_dir"

	# Extract current plasma-meta Depends On list
	pacman -Si plasma-meta |
		awk '/Depends On/ {for (i=4; i<=NF; i++) print $i}' |
		tr -d ':' |
		sort >"$today_file"

	# Find the latest previous snapshot before today
	latest_file=$(ls -1 "$cache_dir"/deps-*.txt 2>/dev/null | grep -v "$(basename "$today_file")" | sort | tail -n1)

	echo "📅 Current dependency list saved to $today_file"

	# Show differences with previous if exists
	if [[ -f "$latest_file" ]]; then
		echo "🔍 Comparing with previous snapshot $latest_file ..."
		echo "➕ Added since last check:"
		comm -13 "$latest_file" "$today_file" || echo "(none)"
		echo
		echo "➖ Removed since last check:"
		comm -23 "$latest_file" "$today_file" || echo "(none)"
		echo
	else
		echo "ℹ️ No previous snapshot found, skipping diff."
		echo
	fi

	# Show missing packages (not installed)
	echo "🔎 Missing 'plasma-meta' dependencies on your system:"
	comm -23 "$today_file" <(pacman -Qq | sort) | while read -r pkg; do
		desc=$(pacman -Si "$pkg" 2>/dev/null | awk -F ': ' '/^Description/ {print $2}')
		printf "• %-30s - %s\n" "$pkg" "${desc:-No description found}"
	done
}

compare_plasma_desktop_vs_meta() {
	# Get sorted dependency lists
	local meta_deps=$(pacman -Si plasma-meta | awk '/Depends On/ {for(i=4;i<=NF;i++) print $i}' | tr -d ':' | sort)
	local desktop_deps=$(pacman -Si plasma-desktop | awk '/Depends On/ {for(i=4;i<=NF;i++) print $i}' | tr -d ':' | sort)

	# Packages in plasma-meta but NOT in plasma-desktop
	local diff=$(comm -23 <(echo "$meta_deps") <(echo "$desktop_deps"))

	if [[ -z "$diff" ]]; then
		echo "No difference: plasma-meta and plasma-desktop dependencies are identical."
		return
	fi

	echo "Packages included in plasma-meta but NOT in plasma-desktop:"
	echo

	# Show installed packages from diff with descriptions
	while IFS= read -r pkg; do
		if pacman -Qq "$pkg" &>/dev/null; then
			desc=$(pacman -Si "$pkg" 2>/dev/null | awk -F ': ' '/^Description/ {print $2}')
			printf "• %-30s - %s\n" "$pkg" "${desc:-No description found}"
		fi
	done <<<"$diff"
}

# Add custom paths to PATH
export PATH="$HOME/.local/bin:/usr/local/sbin:/usr/local/bin:/usr/bin:/usr/bin/site_perl:/usr/bin/vendor_perl:/usr/bin/core_perl"

# Starship prompt
export STARSHIP_CONFIG="$HOME/.config/starship/starship.toml"
eval "$(starship init bash)"
