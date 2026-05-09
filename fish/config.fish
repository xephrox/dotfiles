# Run fastfetch at startup
if command -q fastfetch
    fastfetch
end

# XDG Base Directories
set -gx XDG_DATA_HOME "$HOME/.local/share"
set -gx XDG_CONFIG_HOME "$HOME/.config"
set -gx XDG_STATE_HOME "$HOME/.local/state"
set -gx XDG_CACHE_HOME "$HOME/.cache"

# Colors for ls
set -gx CLICOLOR 1
set -gx LS_COLORS 'no=00:fi=00:di=00;34:ln=01;36:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:ex=01;32:*.tar=01;31:*.tgz=01;31:*.arj=01;31:*.taz=01;31:*.lzh=01;31:*.zip=01;31:*.z=01;31:*.Z=01;31:*.gz=01;31:*.bz2=01;31:*.deb=01;31:*.rpm=01;31:*.jar=01;31:*.jpg=01;35:*.jpeg=01;35:*.gif=01;35:*.bmp=01;35:*.pbm=01;35:*.pgm=01;35:*.ppm=01;35:*.tga=01;35:*.xbm=01;35:*.xpm=01;35:*.tif=01;35:*.tiff=01;35:*.png=01;35:*.mov=01;35:*.mpg=01;35:*.mpeg=01;35:*.avi=01;35:*.fli=01;35:*.gl=01;35:*.dl=01;35:*.xcf=01;35:*.xwd=01;35:*.ogg=01;35:*.mp3=01;35:*.wav=01;35:*.xml=00;31:'

# Colored manpages
set -gx LESS_TERMCAP_mb "\e[01;31m"
set -gx LESS_TERMCAP_md "\e[01;31m"
set -gx LESS_TERMCAP_me "\e[0m"
set -gx LESS_TERMCAP_se "\e[0m"
set -gx LESS_TERMCAP_so "\e[01;44;33m"
set -gx LESS_TERMCAP_ue "\e[0m"
set -gx LESS_TERMCAP_us "\e[01;32m"

# ── Aliases ───────────────────────────────────────────────────────────────────

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
alias catr='cat'
alias cat='bat'

# Directory listing
alias la='ls -Alh'
alias ls='ls -aFh --color=always'
alias lx='ls -lXBh'
alias lk='ls -lSrh'
alias lc='ls -ltcrh'
alias lu='ls -lturh'
alias lr='ls -lRh'
alias lt='ls -ltrh'
alias lm='ls -alh | more'
alias lw='ls -xAh'
alias ll='ls -Fls'
alias labc='ls -lap'
alias lf="ls -l | grep -v '^d'"
alias ldir="ls -l | grep '^d'"
alias lla='ls -Al'
alias las='ls -A'
alias lls='ls -l'

# Archive shortcuts
alias mktar='tar -cvf'
alias mkbz2='tar -cvjf'
alias mkgz='tar -cvzf'
alias untar='tar -xvf'
alias unbz2='tar -xvjf'
alias ungz='tar -xvzf'

# ── PATH ──────────────────────────────────────────────────────────────────────

fish_add_path "$HOME/.local/bin" /usr/local/sbin /usr/local/bin /usr/bin /usr/bin/site_perl /usr/bin/vendor_perl /usr/bin/core_perl

# Ripgrep config
set -gx RIPGREP_CONFIG_PATH "$HOME/.config/ripgrep/ripgreprc"

# ── Starship ──────────────────────────────────────────────────────────────────

set -gx STARSHIP_CONFIG "$HOME/.config/starship/starship.toml"
starship init fish | source
