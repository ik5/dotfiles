# the following make file is based on the idea from
# https://github.com/fatih/dotfiles/blob/master/Makefile

all:
	[ -f ~/.bash_profile ] || ln -s $(PWD)/bash_profile ~/.bash_profile
	[ - ~/.ctags ] || ln -s $(PWD)/ctags ~/.ctags
	[ - ~/.gitconfig ] || ln -s $(PWD)/gitconfig ~/.gitconfig
	[ - ~/.gitignore ] || ln -s $(PWD)/gitignore ~/.gitignore
	[ - ~/.hgrc ] || ln -s $(PWD)/hgrc ~/.hgrc
	[ - ~/.inputrc ] || ln -s $(PWD)/inputrc ~/.inputrc
	[ - ~/.pryrc ] || ln -s $(PWD)/pryrc ~/.pryrc
	[ - ~/.xinitrc ] || ln -s $(PWD)/xinitrc ~/.xinitrc
	[ - ~/.xsession ] || ln -s $(PWD)/xsession ~/.xsession
	[ - ~/.zlogin ] || ln -s $(PWD)/zlogin ~/.zlogin
	[ - ~/.tmux.conf ] || ln -s $(PWD)/tmux.conf ~/.tmux.conf
	[ - ~/.psqlrc ] || ln -s $(PWD)/psqlrc ~/.psqlrc

.PHONY: all
