# NixOS/dotfiles/zsh/zsh-extra-config.zsh
# Initialize zsh completion system
autoload -U compinit
compinit

# Carapace Initialization for great completions
eval "$(carapace zsh)"

# Zoxide Initialization for fast directory switching
eval "$(zoxide init zsh)"

# Starship Initialization for a customizable prompt
eval "$(starship init zsh)"

# Better history search with arrow keys
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

# Set some nice options
setopt AUTO_CD               # cd by typing directory name if it's not a command
setopt AUTO_PUSHD            # Push the current directory visited on the stack
setopt PUSHD_IGNORE_DUPS     # Do not store duplicates in the stack
setopt PUSHD_SILENT          # Do not print the directory stack after pushd or popd

# Improve autosuggestion style
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=8'
ZSH_AUTOSUGGEST_STRATEGY=(history completion)

# Key bindings for autosuggestions (fish-like)
bindkey '^f' autosuggest-accept # Ctrl+F to accept suggestion
bindkey '^e' autosuggest-execute # Ctrl+E to execute suggestion

# Vi mode with better indication
bindkey -v
export KEYTIMEOUT=1

# Change cursor shape based on vi mode
function zle-keymap-select {
  if [[ ${KEYMAP} == vicmd ]] || [[ $1 = 'block' ]]; then
    echo -ne '\e[1 q'
  elif [[ ${KEYMAP} == main ]] || [[ ${KEYMAP} == viins ]] || [[ ${KEYMAP} = '' ]] || [[ $1 = 'beam' ]]; then
    echo -ne '\e[5 q'
  fi
}
zle -N zle-keymap-select

# Initialize cursor to beam shape on startup
echo -ne '\e[5 q'

# Enable direnv (automatic loading of .envrc files)
eval "$(direnv hook zsh)"

# Better directory navigation
function d() {
  if [[ -n $1 ]]; then
    dirs "$@"
  else
    dirs -v | head -n 10
  fi
}
