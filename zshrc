# ============================================================================
# ZINIT INITIALIZATION
# ============================================================================

ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

if [ ! -d "$ZINIT_HOME" ]; then
   mkdir -p "$(dirname $ZINIT_HOME)"
   git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

source "${ZINIT_HOME}/zinit.zsh"

# ============================================================================
# BASIC ZSH CONFIGURATION
# ============================================================================

setopt PROMPT_SUBST

# ============================================================================
# EDITOR
# ============================================================================

export EDITOR="nvim"
export VISUAL="nvim"
export COLORTERM="truecolor"
export TERM="xterm-256color"

# ============================================================================
# HISTORY CONFIGURATION
# ============================================================================

HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.zsh_history

setopt APPEND_HISTORY
setopt INC_APPEND_HISTORY
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_SAVE_NO_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_VERIFY
setopt SHARE_HISTORY
setopt HIST_REDUCE_BLANKS

# ============================================================================
# PLUGINS & TOOLS (via Zinit)
# ============================================================================

zinit ice depth=1
zinit light jeffreytse/zsh-vi-mode

zinit ice wait lucid
zinit light zdharma-continuum/fast-syntax-highlighting

zinit ice wait lucid atload'_zsh_autosuggest_start'
zinit light zsh-users/zsh-autosuggestions

zinit ice wait lucid blockf atpull'zinit creinstall -q .'
zinit light zsh-users/zsh-completions

zinit ice wait lucid
zinit light Aloxaf/fzf-tab

zinit ice wait lucid
zinit light ajeetdsouza/zoxide

# ============================================================================
# COMPLETION & AUTOCOMPLETE
# ============================================================================

autoload -Uz compinit && compinit
zinit cdreplay -q

zstyle ':completion::complete:*' use-cache 1
zstyle ':completion::complete:*' cache-path ~/.zsh/cache
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' menu select
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}

zstyle ':fzf-tab:*' fzf-flags '--color=bg+:#262626,bg:#161616,spinner:#be95ff,hl:#33b1ff,fg:#f2f4f8,header:#33b1ff,info:#be95ff,pointer:#ff7eb6,marker:#3ddbd9,fg+:#f2f4f8,prompt:#be95ff,hl+:#ff7eb6'

# ============================================================================
# FZF CONFIGURATION
# ============================================================================

if command -v fzf >/dev/null 2>&1; then
    export FZF_DEFAULT_OPTS="
    --color=bg+:#262626,bg:#161616,spinner:#be95ff,hl:#33b1ff
    --color=fg:#f2f4f8,header:#33b1ff,info:#be95ff,pointer:#ff7eb6
    --color=marker:#3ddbd9,fg+:#f2f4f8,prompt:#be95ff,hl+:#ff7eb6"

    source <(fzf --zsh) 2>/dev/null || true
fi

# ============================================================================
# KEYBINDINGS & SHORTCUTS
# ============================================================================

# Re-apply custom keybindings after zsh-vi-mode initialises
function zvm_after_init {
  export VIM_INSERT="I"

  _accept_suggestion() { zle autosuggest-accept }
  zle -N _accept_suggestion

  bindkey -M viins '^I' expand-or-complete
  bindkey -M viins '^R' history-incremental-search-backward
  bindkey -M viins '^S' history-incremental-search-forward
  bindkey -M viins '^[[1;5C' forward-word
  bindkey -M viins '^[[1;5D' backward-word
  bindkey -M viins '^A' beginning-of-line
  bindkey -M viins '^E' _accept_suggestion
  bindkey -M viins '^[e' end-of-line
  bindkey -M viins '^X^K' kill-line
  bindkey -M viins '^X^L' clear-screen
  bindkey -M viins '^U' kill-whole-line
  bindkey -M viins '^W' backward-kill-word
  bindkey -M viins '^[[3~' delete-char
  bindkey -M viins '^[[H' beginning-of-line
  bindkey -M viins '^[[F' end-of-line
}

# ============================================================================
# ALIASES
# ============================================================================

# Sudo
alias sudo='sudo '

# Update
alias update='paru -Syu'

if command -v eza >/dev/null 2>&1; then
    alias ls='eza --color=always'
    alias ll='eza -la --color=always'
    alias la='eza -a --color=always'
    alias lt='eza --tree --color=always'
else
    alias ls='ls --color=auto'
    alias ll='ls -la --color=auto'
    alias la='ls -a --color=auto'
fi

alias grep='grep --color=auto'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias ~='cd ~'
alias h='history'
alias j='jobs'
alias c='clear'
alias y='yazi'
alias nv='nvim'
alias rb='reboot'

# Install/Remove
alias install='paru -S '
alias remove='sudo pacman -Rs '
alias remove-all='sudo pacman -Rns '

alias g='git'
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git log --oneline'
alias gd='git diff'

# Lazygit
alias lg='lazygit'

alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

# ============================================================================
# FUNCTIONS
# ============================================================================

mkcd() {
    mkdir -p "$1" && cd "$1"
}

extract() {
    if [[ -f $1 ]]; then
        case $1 in
            *.tar.bz2) tar xjf $1 ;;
            *.tar.gz)  tar xzf $1 ;;
            *.bz2)     bunzip2 $1 ;;
            *.rar)     unrar x $1 ;;
            *.gz)      gunzip $1 ;;
            *.tar)     tar xf $1 ;;
            *.tbz2)    tar xjf $1 ;;
            *.tgz)     tar xzf $1 ;;
            *.zip)     unzip $1 ;;
            *.Z)       uncompress $1 ;;
            *.7z)      7z x $1 ;;
            *)         echo "Don't know how to extract '$1'" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}

# ============================================================================
# ADDITIONAL OPTIONS
# ============================================================================

setopt AUTO_CD
setopt CORRECT
setopt COMPLETE_IN_WORD
setopt ALWAYS_TO_END
setopt EXTENDED_GLOB

unsetopt BEEP

# ============================================================================
# PATH CONFIGURATION
# ============================================================================

[[ -d "$HOME/.local/bin" ]] && export PATH="$HOME/.local/bin:$PATH"
[[ -d "$HOME/bin" ]] && export PATH="$HOME/bin:$PATH"

# ============================================================================
# FINAL SETUP
# ============================================================================

function zvm_after_select_vi_mode {
  unset VIM_NORMAL VIM_INSERT VIM_VISUAL
  case $ZVM_MODE in
    $ZVM_MODE_NORMAL)      export VIM_NORMAL="N" ;;
    $ZVM_MODE_VISUAL)      export VIM_VISUAL="V" ;;
    $ZVM_MODE_VISUAL_LINE) export VIM_VISUAL="VL" ;;
    *)                     export VIM_INSERT="I" ;;
  esac
}

# if [[ -o interactive ]]; then 
#     if [[ -z "$TMUX" ]]; then
#         fastfetch
#     elif [[ "$(tmux display -p '#{pane_index}')" == "$(tmux show -gv pane-base-index)" ]]; then
#         fastfetch
#     fi
# fi

export STARSHIP_CONFIG=~/.config/starship/starship.toml
eval "$(starship init zsh)"

[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local

# Generated for envman. Do not edit.
[ -s "$HOME/.config/envman/load.sh" ] && source "$HOME/.config/envman/load.sh"

if command -v zoxide >/dev/null 2>&1; then
    eval "$(zoxide init zsh)"
    alias cd='z'
fi

export GITHUB_PERSONAL_ACCESS_TOKEN=
# bun completions
[ -s "/home/juicygoose007/.bun/_bun" ] && source "/home/juicygoose007/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

alias claude-mem='/home/juicygoose007/.bun/bin/bun "/home/juicygoose007/.claude/plugins/marketplaces/thedotmack/plugin/scripts/worker-service.cjs"'
