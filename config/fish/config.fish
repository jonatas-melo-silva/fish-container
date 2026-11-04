if status is-interactive
    # Sem mensagem de boas-vindas do fish
    set -g fish_greeting

    # Prompt, navegação e busca
    starship init fish | source
    zoxide init fish --cmd cd | source
    fzf --fish | source
end

# Substitutos dos comandos clássicos
alias cat='bat'
alias ls='eza --icons'
alias l='eza -l --icons --git'

# fzf: Ctrl+T lista arquivos ignorando .git e node_modules, com preview via bat
set -gx FZF_CTRL_T_COMMAND 'fd --type f --hidden --exclude .git --exclude node_modules'
set -gx FZF_CTRL_T_OPTS "--preview 'bat --color=always --style=numbers {}'"
