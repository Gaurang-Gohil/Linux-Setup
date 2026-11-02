
# --- added by hyprlust-setup ---
if status is-interactive
    set -g fish_greeting
    type -q fastfetch; and fastfetch
    type -q starship;  and starship init fish | source
    type -q zoxide;    and zoxide init fish | source
    type -q eza;       and alias ls 'eza --icons --group-directories-first'
end
# --- end hyprlust-setup ---
export PATH="$HOME/.local/bin:$PATH"
