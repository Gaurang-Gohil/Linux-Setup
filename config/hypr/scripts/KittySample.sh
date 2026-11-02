#!/usr/bin/env bash
# Sample terminal output in the 16 standard colors (kitty draws them in the current theme).
c() { printf '\e[%sm' "$1"; }; R=$(c 0)
echo; echo "  $(c 1)${1#👉 }$R"; echo
echo "  $(c 32)$USER$R@$(c 34)$(cat /etc/hostname)$R $(c 36)~/projects$(c 35) ❯$R ls"
echo "  $(c 34)docs/  $(c 32)build.sh*  ${R}notes.md  $(c 35)photo.png  $(c 31)old.tar.gz$R"
echo "  $(c 32)$USER$R@$(c 34)$(cat /etc/hostname)$R $(c 36)~/projects$(c 35) ❯$R git status"
echo "  $(c 32)modified:   ${R}main.py    $(c 31)deleted:   ${R}old.txt"; echo
echo "  $(c 90)# greet a user$R"
echo "  $(c 35)def $(c 34)greet$R(name: $(c 36)str$R) -> $(c 36)None$R:"
echo "      $(c 35)if ${R}name $(c 35)== $(c 32)\"\"$R:  name = $(c 32)\"world\"$R"
echo "      $(c 34)print$R($(c 33)f\"Hello, {name}!\"$R, count=$(c 93)3$R)"; echo
printf '  '; for i in 0 1 2 3 4 5 6 7; do printf '\e[4%sm      \e[0m ' $i; done; echo
printf '  '; for i in 0 1 2 3 4 5 6 7; do printf '\e[10%sm      \e[0m ' $i; done; echo
