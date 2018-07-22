# Runnable config for zsh

# Source global definitions
[ -r "/etc/zshrc" ] && [ -f "/etc/zshrc" ] && source "/etc/zshrc"

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# Source shell shared things
for file in "$HOME/.shell/"{path,exports,aliases,profile}; do
    source "$file"
done

# Include functions
source "$HOME/.zsh/functions.zsh"

# Load colors for easier coloring
autoload -U colors && colors

# Coloring for ls
[[ -f "$HOME/.dircolors" ]] && eval $(dircolors "$HOME/.dircolors") || eval $(dircolors)

# Set locations
HISTFILE="$HOME/.zsh_history"
DIRSTACKFILE="$HOME/.zsh_dirs"

# Increase history size
HISTSIZE=5000
SAVEHIST="$HISTSIZE"

# Increase stack size of dirs
DIRSTACKSIZE=20

# Let zsh decide when to page a list
LISTMAX=0

# Disable mail checking
MAILCHECK=0

# Enable completion of aliases
setopt completealiases

# Append history instead of overwriting
setopt appendhistory

# Save each command's beginning timestamp and duration
setopt extended_history

# Ignore duplication command history list
setopt hist_ignore_dups

# Ignore commands which start with space
setopt hist_ignore_space

# Allow command review on history substition by loading it into buffer instead of directly executing it
# (e.g. `cd !$` does not directly expand and execute `!$`, instead it changes the current line to cd previews_commands_argument)
setopt hist_verify

# Increment history number automatically
setopt inc_append_history

# Jump without cd to a directory (cd /usr = /usr)
setopt auto_cd

# Needed to use #, ~ and ^ in regexing filenames
setopt extended_glob

# Display PID when suspending proceses
setopt longlistjobs

# Report status of background jobs immediately
setopt notify

# Make sure entire command is hashed before completion
setopt hash_list_all

# Push old directory onto the directory stack automatically
setopt auto_pushd

# Do not push the same dir twice
setopt pushd_ignore_dups

# Disable beeping
setopt nobeep

# No matching for dotfiles (e.g. * does not expand to .dotfiles but .* does)
setopt noglobdots

# Allow comments in interactive shells
setopt interactive_comments

# Enable command substitution for the prompt
setopt prompt_subst

# Disable killing of background jobs
setopt nohup

# Enable completion from within a word
setopt complete_in_word

# Move cursor to the end on completing a word
setopt always_to_end

# Include completions
[ -d "/usr/local/share/zsh-completions" ] && fpath=(/usr/local/share/zsh-completions $fpath)

# Enable zsh better completion (Note: it might be necessary to run: `compaudit | xargs chmod g-w`)
autoload -Uz compinit && compinit -u

# Load heroku autocomplete (disabled due long loading time)
#[ -x "$(command -v heroku)" ] && eval "$(heroku autocomplete:script zsh)"

# Enable bash completionss
autoload -U bashcompinit && bashcompinit

# Setup completers to use (Correction in commands should be disabled)
zstyle ':completion:*::::' completer _expand _complete _ignored _approximate

# Warn if there are no matches
zstyle ':completion:*:warnings' format "%{$fg[red]%}No matches for:%{$reset_color%} %d"

# Display what currently is completed
zstyle ':completion:*' format 'Completing %d'

# Colorize completion
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}

# Match uppercase with lowercase chars and mixed (case-insensitive)
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|=*' 'l:|=* r:|=*'

# Display completion of man pages in separate sections
zstyle ':completion:*:manuals' separate-sections true

# Show percentage of when scrolling trough completion
zstyle ':completion:*' select-prompt %S%p%s

# Use caching so that commands like apt and dpkg complete are useable
zstyle ':completion::complete:*' use-cache 1
zstyle ':completion::complete:*' cache-path "$ZSH_CACHE_DIR"

# Disable completing uninteresting users
zstyle ':completion:*:*:*:users' ignored-patterns \
        adm amanda apache at avahi avahi-autoipd beaglidx bin cacti canna \
        clamav daemon dbus distcache dnsmasq dovecot fax ftp games gdm \
        gkrellmd gopher hacluster haldaemon halt hsqldb ident junkbust kdm \
        ldap lp mail mailman mailnull man messagebus  mldonkey mysql nagios \
        named netdump news nfsnobody nobody nscd ntp nut nx obsrun openvpn \
        operator pcap polkitd postfix postgres privoxy pulse pvm quagga radvd \
        rpc rpcuser rpm rtkit scard shutdown squid sshd statd svn sync tftp \
        usbmux uucp vcsa wwwrun xfs '_*'

# Display red dots on completion
_zsh-expand-red-dots() { echo -n "\e[31m......\e[0m"; zle expand-or-complete; zle redisplay }
zle -N _zsh-expand-red-dots
bindkey "^I" _zsh-expand-red-dots

# Enable verbose output
zstyle ':completion:*' verbose true

# Display all processes for killall
zstyle ':completion:*:processes-names' command 'ps -u ${USER} -o command,pid -c | uniq'

# Display menu if there are >2 completions
zstyle ':completion:*' menu select=2

# Case-sensitive completion
zstyle ':completion:*' matcher-list 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'

# Enable completion of ssh hosts
zstyle -e ':completion:*:(ssh|scp|sftp|rsh|rsync):hosts' \
    hosts 'reply=(${=${${(f)"$(cat {/etc/ssh_,~/.ssh/known_}hosts(|2)(N) /dev/null)"}%%[# ]*}//,/ })'

# Enable history navigation
bindkey '^p' up-history
bindkey '^n' down-history

# Enable word deletion with ctrl+w
bindkey '^w' backward-kill-word

# Enable backward search in history with ctrl+r
bindkey '^r' history-incremental-search-backward

# Enable moving to beginning/end of line with home/end
# Note: Add key fn+left with esc sequence to [1~ and fn+right to [4~
bindkey '^[[1~' beginning-of-line
bindkey '^[[4~' end-of-line

# Enable to jump back in a menu with shift+tab
bindkey '^[[Z' reverse-menu-complete

# Setup fzf autocompletion
if [ -x "$(command -v fzf)" ]; then
    # Trigger fzf with ~~
    export FZF_COMPLETION_TRIGGER='~~'

    source "/usr/local/opt/fzf/shell/completion.zsh" 2> /dev/null
    # Key bindings
    # Ctrl+T - Search and paste selected to cli
    # Alt+C - cd into selected directory
    # Ctrl+R - Use fzf for history search
    source "/usr/local/opt/fzf/shell/key-bindings.zsh"
fi

# Setup prompt
source "$HOME/.zsh/theme.zsh"

# Check dotfiles
[[ $( (cd ~/.dotfiles/; git status -s 2> /dev/null) | tail -n1) != "" ]] \
            && echo -e "\n $fg[red] WARNING:  There are uncommited changes in your dotfiles. $reset_color \n"

# Autostart tmux on remote systems
if [[ -z "${TMUX+x}" && -z $"SSH_CONNECTION" && ! "$USERNAME" == "root" ]]; then
    tmux -2 attach -t default ||  tmux new -s default
fi

# Syntax highlighting (this must be at the end of .zshrc)
if [ -r "/usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]; then
    source /usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
    export ZSH_HIGHLIGHT_HIGHLIGHTERS_DIR=/usr/local/share/zsh-syntax-highlighting/highlighters

    # Highlight commands, options, arguments, paths, strings and brackets
    # See: https://github.com/zsh-users/zsh-syntax-highlighting/blob/master/docs/highlighters/main.md
    ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets)
    ZSH_HIGHLIGHT_STYLES[default]='fg=cyan'
    ZSH_HIGHLIGHT_STYLES[path]='fg=cyan,bold'
    ZSH_HIGHLIGHT_STYLES[globbing]='fg=cyan'
    ZSH_HIGHLIGHT_STYLES[single-hyphen-option]='fg=magenta'
    ZSH_HIGHLIGHT_STYLES[double-hyphen-option]='fg=magenta'
    ZSH_HIGHLIGHT_STYLES[back-quoted-argument]='fg=yellow'
    ZSH_HIGHLIGHT_STYLES[unknown-token]='fg=red'
fi
