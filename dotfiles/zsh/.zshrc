# Simplified zshrc focusing on completions, zoxide, starship, and aliases

# Initialize zsh completion system (required for good completions)
autoload -U compinit
compinit

# Carapace Initialization for great completions
eval "$(carapace zsh)"

# Zoxide Initialization for fast directory switching
eval "$(zoxide init zsh)"

# Starship Initialization for a customizable prompt
eval "$(starship init zsh)"

# Custom Aliases - from your nushell config
alias cd="z"
alias rm="rip"
alias zed="zeditor" # You might need to define zeditor or change this if you use it
alias gs="git status"
alias ga="git add ."
alias gc="git commit -a -m"
alias gp="git push"
alias gl="git log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold cyan)%aD%C(reset) %C(bold green)(%ar)%C(reset)%C(auto)%d%C(reset)%n''          %C(white)%s%C(reset) %C(dim white)- %an%C(reset)'"
alias v="nvim"
alias vi="nvim"

# Vi mode (if you prefer vi keybindings)
bindkey -v
