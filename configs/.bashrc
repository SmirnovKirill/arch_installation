#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias vi='vim'
PS1='[\u@\h \W]\$ '

if [[ ! $DISPLAY && $XDG_VTNR -eq 1 ]]; then
	xinput disable "MSFT0001:00 06CB:7E7E Touchpad"
	exec startx &> /dev/null #не выводить в консоль данные startx
fi
