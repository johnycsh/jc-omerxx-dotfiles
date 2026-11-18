# Reevaluate the prompt string each time it's displaying a prompt
setopt prompt_subst
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
autoload -Uz compinit
compinit

# Homebrew stays for GUI casks / custom taps, so keep its shims on PATH
export PATH=/opt/homebrew/bin:$PATH

# zsh-autosuggestions (installed via Nix — see nix-darwin/home.nix)
source "$HOME/.nix-profile/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
bindkey '^w' autosuggest-execute
bindkey '^e' autosuggest-accept
bindkey '^u' autosuggest-toggle
bindkey '^L' vi-forward-word
bindkey '^k' up-line-or-search
bindkey '^j' down-line-or-search

export LANG=en_US.UTF-8
export EDITOR=nvim
export XDG_CONFIG_HOME="$HOME/.config"

alias la=tree
alias cat=bat
alias cl='clear'

# Git
alias gc="git commit -m"
alias gca="git commit -a -m"
alias gp="git push origin HEAD"
alias gpu="git pull origin"
alias gst="git status"
alias glog="git log --graph --topo-order --pretty='%w(100,0,6)%C(yellow)%h%C(bold)%C(black)%d %C(cyan)%ar %C(green)%an%n%C(bold)%C(white)%s %N' --abbrev-commit"
alias gdiff="git diff"
alias gco="git checkout"
alias gb='git branch'
alias gba='git branch -a'
alias gadd='git add'
alias ga='git add -p'
alias gcoall='git checkout -- .'
alias gr='git remote'
alias gre='git reset'

# Dirs
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias .....="cd ../../../.."
alias ......="cd ../../../../.."

export GOPATH="$HOME/go"
export PATH="$PATH:${GOPATH}/bin:$HOME/.cargo/bin"
alias v="nvim"
alias nm="nmap -sC -sV -oN nmap"

### FZF ###
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow'
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# VI Mode
bindkey jj vi-cmd-mode

# navigation
cx() { cd "$@" && ls -la; }
fcd() { cd "$(find . -type d -not -path '*/.*' | fzf)" && ls -la; }
f() { echo "$(find . -type f -not -path '*/.*' | fzf)" | pbcopy }
fv() { nvim "$(find . -type f -not -path '*/.*' | fzf)" }

alias mat='osascript -e "tell application \"System Events\" to key code 126 using {command down}" && tmux neww "cmatrix"'

# Nix
export NIX_CONF_DIR=$HOME/.config/nix
export PATH=/run/current-system/sw/bin:$HOME/.nix-profile/bin:$PATH
if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
	. '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
fi

# Starship / zoxide / atuin / direnv — the binaries and config are
# Nix-managed (nix-darwin/home.nix), but the shell-hook activation lives
# here since this file, not home-manager, owns zsh startup.
eval "$(starship init zsh)"
export STARSHIP_CONFIG="$HOME/.config/starship/starship.toml"
eval "$(zoxide init zsh)"
eval "$(atuin init zsh)"
eval "$(direnv hook zsh)"
