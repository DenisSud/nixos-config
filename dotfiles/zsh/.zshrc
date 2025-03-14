# Simplified zshrc with fish-like features

# Initialize zsh completion system
autoload -U compinit
compinit

# Carapace Initialization for great completions
eval "$(carapace zsh)"

# Zoxide Initialization for fast directory switching
eval "$(zoxide init zsh)"

# Starship Initialization for a customizable prompt
eval "$(starship init zsh)"

# Custom Aliases - from your nushell config
alias rm="rip"
alias zed="zeditor"
alias gs="git status"
alias ga="git add ."
alias gc="git commit -a -m"
alias gp="git push"
alias gl="git log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold cyan)%aD%C(reset) %C(bold green)(%ar)%C(reset)%C(auto)%d%C(reset)%n''          %C(white)%s%C(reset) %C(dim white)- %an%C(reset)'"
alias v="nvim"
alias vi="nvim"
alias ls="ls --color=auto"
alias ll="ls -la"
alias la="ls -a"

# Vi mode with better indication
bindkey -v
export KEYTIMEOUT=1

# Change cursor shape based on vi mode
function zle-keymap-select {
  if [[ ${KEYMAP} == vicmd ]] ||
     [[ $1 = 'block' ]]; then
    echo -ne '\e[1 q'
  elif [[ ${KEYMAP} == main ]] ||
       [[ ${KEYMAP} == viins ]] ||
       [[ ${KEYMAP} = '' ]] ||
       [[ $1 = 'beam' ]]; then
    echo -ne '\e[5 q'
  fi
}
zle -N zle-keymap-select

# Initialize cursor to beam shape on startup
echo -ne '\e[5 q'

# Enable direnv (automatic loading of .envrc files)
eval "$(direnv hook zsh)"

# Better browsing with fzf - if installed
if command -v fzf &> /dev/null; then
  # Ctrl+R for history search with fzf
  source "${pkgs.fzf}/share/fzf/key-bindings.zsh"
  source "${pkgs.fzf}/share/fzf/completion.zsh"
fi

# Better directory navigation
function d() {
  if [[ -n $1 ]]; then
    dirs "$@"
  else
    dirs -v | head -n 10
  fi
}
