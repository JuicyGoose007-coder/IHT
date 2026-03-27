# ============================================================================
# ZINIT INITIALIZATION
# ============================================================================

# Set the directory we want to store zinit and plugins
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

# Download Zinit, if it's not there yet
if [ ! -d "$ZINIT_HOME" ]; then
   mkdir -p "$(dirname $ZINIT_HOME)"
   git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

# Source/Load zinit
source "${ZINIT_HOME}/zinit.zsh"

# ============================================================================
# POWERLEVEL10K CONFIGURATION (disabled - using starship instead)
# ============================================================================

# zinit ice depth=1
# zinit light romkatv/powerlevel10k

# ============================================================================
# BASIC ZSH CONFIGURATION
# ============================================================================

# Enable colors and change prompt
autoload -U colors && colors
setopt PROMPT_SUBST

# ============================================================================
# OXOCARBON THEME COLORS
# ============================================================================

# Oxocarbon color palette (IBM Carbon Design)
# export CLICOLOR=1
# export LSCOLORS="ExGxBxDxCxEgEdxbxgxcxd"


# ============================================================================
# Editor
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

setopt HIST_IGNORE_DUPS # Don't record duplicate entries
setopt HIST_IGNORE_ALL_DUPS # Delete old duplicates
setopt HIST_SAVE_NO_DUPS # Don't save duplicates
setopt HIST_IGNORE_SPACE # Don't record commands starting with space
setopt HIST_VERIFY # Show command with history expansion before running
setopt SHARE_HISTORY # Share history between all sessions

# ============================================================================
# PLUGINS & TOOLS (via Zinit)
# ============================================================================

# Vi mode (must load before other plugins)
zinit ice depth=1
zinit light jeffreytse/zsh-vi-mode

# Fast Syntax Highlighting - must be loaded BEFORE zsh-autocomplete
zinit ice wait lucid
zinit light zdharma-continuum/fast-syntax-highlighting

# Zsh Autosuggestions
zinit ice wait lucid atload'_zsh_autosuggest_start'
zinit light zsh-users/zsh-autosuggestions

# Zsh Completions
zinit ice wait lucid blockf atpull'zinit creinstall -q .'
zinit light zsh-users/zsh-completions

# FZF Tab - Better tab completion with fzf
zinit ice wait lucid
zinit light Aloxaf/fzf-tab

# Zoxide - Better cd
zinit ice wait lucid
zinit light ajeetdsouza/zoxide

# # Catppuccin Prompt (disabled - using starship instead)
# zinit light romkatv/powerlevel10k
# zinit light tolkonepiu/catppuccin-powerlevel10k-themes

# ============================================================================
# COMPLETION & AUTOCOMPLETE
# ============================================================================

autoload -Uz compinit && compinit

# Zinit completion optimization
zinit cdreplay -q

# Enable completion caching
zstyle ':completion::complete:*' use-cache 1
zstyle ':completion::complete:*' cache-path ~/.zsh/cache

# Case insensitive completion
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'

# Menu selection
zstyle ':completion:*' menu select

# Colorful completions
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}

# FZF Tab configuration with Oxocarbon colors
zstyle ':fzf-tab:*' fzf-flags '--color=bg+:#262626,bg:#161616,spinner:#be95ff,hl:#33b1ff'
zstyle ':fzf-tab:*' fzf-flags '--color=fg:#f2f4f8,header:#33b1ff,info:#be95ff,pointer:#ff7eb6'
zstyle ':fzf-tab:*' fzf-flags '--color=marker:#3ddbd9,fg+:#f2f4f8,prompt:#be95ff,hl+:#ff7eb6'

# ============================================================================
# FZF CONFIGURATION
# ============================================================================

if command -v fzf >/dev/null 2>&1; then
    # FZF configuration with Oxocarbon colors
    export FZF_DEFAULT_OPTS="
    --color=bg+:#262626,bg:#161616,spinner:#be95ff,hl:#33b1ff
    --color=fg:#f2f4f8,header:#33b1ff,info:#be95ff,pointer:#ff7eb6
    --color=marker:#3ddbd9,fg+:#f2f4f8,prompt:#be95ff,hl+:#ff7eb6"

    # Key bindings
    source <(fzf --zsh) 2>/dev/null || true
fi

# ============================================================================
# KEYBINDINGS & SHORTCUTS
# ============================================================================

# Use emacs key bindings
# bindkey -e

# History search
bindkey '^R' history-incremental-search-backward
bindkey '^S' history-incremental-search-forward

# Word movement
bindkey '^[[1;5C' forward-word # Ctrl+Right
bindkey '^[[1;5D' backward-word # Ctrl+Left

# Line editing
bindkey '^A' beginning-of-line # Ctrl+A
bindkey '^E' end-of-line # Ctrl+E
bindkey '^X^K' kill-line # Ctrl+X Ctrl+K (Ctrl+K reserved for tmux pane up)
bindkey '^X^L' clear-screen # Ctrl+X Ctrl+L (Ctrl+L reserved for tmux pane right)
bindkey '^U' kill-whole-line # Ctrl+U
bindkey '^W' backward-kill-word # Ctrl+W

# Delete key
bindkey '^[[3~' delete-char # Delete

# Home and End keys
bindkey '^[[H' beginning-of-line # Home
bindkey '^[[F' end-of-line # End

# ============================================================================
# ALIASES
# ============================================================================

# Colorful ls
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

# Common shortcuts
alias grep='grep --color=auto'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias ~='cd ~'
alias c='clear'
alias h='history'
alias j='jobs'
alias r='reboot'
alias nv='nvim'
# alias vim='nvim'
alias z='cd'
alias y='yazi'

# Git shortcuts
alias g='git'
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git log --oneline'
alias gd='git diff'

# Safety nets
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

# Zoxide integration (if installed)
if command -v zoxide >/dev/null 2>&1; then
    eval "$(zoxide init zsh)"
    alias cd='z'
    alias zi='__zoxide_zi' # Override zinit's zi alias with zoxide interactive
fi

# ============================================================================
# FUNCTIONS
# ============================================================================

# Quick directory creation and navigation
mkcd() {
    mkdir -p "$1" && cd "$1"
}

# Extract various archive formats
extract() {
    if [[ -f $1 ]]; then
        case $1 in
            *.tar.bz2) tar xjf $1 ;;
            *.tar.gz) tar xzf $1 ;;
            *.bz2) bunzip2 $1 ;;
            *.rar) unrar x $1 ;;
            *.gz) gunzip $1 ;;
            *.tar) tar xf $1 ;;
            *.tbz2) tar xjf $1 ;;
            *.tgz) tar xzf $1 ;;
            *.zip) unzip $1 ;;
            *.Z) uncompress $1 ;;
            *.7z) 7z x $1 ;;
            *) echo "Don't know how to extract '$1'" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}

# ============================================================================
# ADDITIONAL OPTIONS
# ============================================================================

setopt AUTO_CD # Auto cd to directory without typing cd
setopt CORRECT # Command correction
setopt COMPLETE_IN_WORD # Allow completion in middle of word
setopt ALWAYS_TO_END # Move cursor to end after completion
setopt EXTENDED_GLOB # Extended globbing patterns

# Disable beep
unsetopt BEEP

# ============================================================================
# PATH CONFIGURATION
# ============================================================================

# Add common directories to PATH if they exist
[[ -d "$HOME/.local/bin" ]] && export PATH="$HOME/.local/bin:$PATH"
[[ -d "$HOME/bin" ]] && export PATH="$HOME/bin:$PATH"

# ============================================================================
# FINAL SETUP
# ============================================================================

# Vim mode indicator for Starship via zsh-vi-mode
export VIM_INSERT="INS"
unset VIM_NORMAL VIM_VISUAL

function zvm_after_select_vi_mode {
  unset VIM_NORMAL VIM_INSERT VIM_VISUAL
  case $ZVM_MODE in
    $ZVM_MODE_NORMAL)      export VIM_NORMAL="NOR" ;;
    $ZVM_MODE_VISUAL)      export VIM_VISUAL="VIS" ;;
    $ZVM_MODE_VISUAL_LINE) export VIM_VISUAL="VIS" ;;
    *)                     export VIM_INSERT="INS" ;;
  esac
}

# Re-apply custom keybindings after zsh-vi-mode initialises
function zvm_after_init {
  bindkey '^R' history-incremental-search-backward
  bindkey '^S' history-incremental-search-forward
  bindkey '^[[1;5C' forward-word
  bindkey '^[[1;5D' backward-word
  bindkey '^A' beginning-of-line
  bindkey '^E' end-of-line
  bindkey '^X^K' kill-line
  bindkey '^X^L' clear-screen
  bindkey '^U' kill-whole-line
  bindkey '^W' backward-kill-word
  bindkey '^[[3~' delete-char
  bindkey '^[[H' beginning-of-line
  bindkey '^[[F' end-of-line
}

# Starship prompt
export STARSHIP_CONFIG=~/.config/starship/starship.toml
eval "$(starship init zsh)"

# Load any local customizations
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local

# Display system info (run last to avoid affecting prompt colors)
# if [[ -o interactive ]]; then
#     fastfetch
# fi

