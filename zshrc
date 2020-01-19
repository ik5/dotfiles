# Test for an interactive shell.  There is no need to set anything
# past this point for scp and rcp, and it's important to refrain from
# outputting anything in those cases.
if [[ $- != *i* ]] ; then
  # Shell is non-interactive.  Be done now!
  # return
fi

if [[ "$OSTYPE" == "linux-gnu" ]]; then
  export OS="linux"
elif [[ "$OSTYPE" == "darwin"* ]]; then
  export OS="macosx"
elif [[ "$OSTYPE" == "cygwin" ]]; then
  export OS="cygwin"
elif [[ "$OSTYPE" == "msys" || "$OSTYPE" == "win32"  ]]; then
  export OS="windows"
elif [[ "$OSTYPE" == "freebsd"* ]]; then
  export OS="bsd"
fi

if [[ "$OS" == "macosx" && -e /usr/local/bin/ggrep ]]; then
  alias grep="/usr/local/bin/ggrep"
fi

export EDITOR=nvim
export VISUAL=nvim
export BROWSER=$(which firefox vivaldi vivaldi-stable chromium-browser google-chrome links2 links lynx | grep -Pm1 '^/')
export TERMINAL=$(which tilix terminator konsole terminal aterm xterm | grep -Pm1 '^/')

# fix n a new ruby version installed
if [[ -e ~/.bin/tmuxinator.zsh ]]; then
  source ~/.bin/tmuxinator.zsh
else
  (>&2 echo "\e[1mWARNING:\e[0m \e[93m\e[101mCould not find \e[1m\e[4m$HOME/.bin/tmuxinator.zsh\e[21m\e[24m.\e[0m")
fi

export HISTFILE=$HOME/.zsh_history
export HISTSIZE=950000
export SAVEHIST=950000
setopt BANG_HIST                 # Treat the '!' character specially during expansion.
setopt EXTENDED_HISTORY          # Write the history file in the ":start:elapsed;command" format.
setopt INC_APPEND_HISTORY        # Write to the history file immediately, not when the shell exits.
setopt SHARE_HISTORY             # Share history between all sessions.
setopt HIST_EXPIRE_DUPS_FIRST    # Expire duplicate entries first when trimming history.
setopt HIST_IGNORE_DUPS          # Don't record an entry that was just recorded again.
setopt HIST_IGNORE_ALL_DUPS      # Delete old recorded entry if new entry is a duplicate.
setopt HIST_FIND_NO_DUPS         # Do not display a line previously found.
setopt HIST_IGNORE_SPACE         # Don't record an entry starting with a space.
setopt HIST_SAVE_NO_DUPS         # Don't write duplicate entries in the history file.
setopt HIST_REDUCE_BLANKS        # Remove superfluous blanks before recording entry.
setopt HIST_VERIFY               # Don't execute immediately upon history expansion.
setopt HIST_BEEP                 # Beep when accessing nonexistent history.

# if you do a 'rm *', Zsh will give you a sanity check!
setopt RM_STAR_WAIT

# Zsh has a spelling corrector
setopt CORRECT

# do not timeout a session
unset TMOUT

#
### Antigen configuration
. $HOME/antigen.zsh
if [[ ! -x antigen-apply ]]; then
  source $HOME/antigen.zsh
fi

antigen use oh-my-zsh

#antigen bundle git
antigen bundle git-flow-avh
antigen bundle pip
antigen bundle heroku
antigen bundle gem
antigen bundle npm
antigen bundle command-not-found
antigen bundle ruby
antigen bundle go
antigen bundle tmux
antigen bundle colored-man-pages
antigen bundle colorize
antigen bundle zsh-users/zsh-syntax-highlighting
antigen bundle popstas/zsh-command-time
antigen bundle zsh-users/zsh-completions
if [[ "$OS" == "macosx" ]]; then
  antigen bundle osx
fi

antigen apply

antigen theme ys
ZSH_COMMAND_TIME_ECHO=1
ZSH_COMMAND_TIME_MIN_SECONDS=1 # one seconds and more

# The following lines were added by compinstall
zstyle :compinstall filename "$HOME/.zshrc"
autoload -Uz compinit
compinit
# End of lines added by compinstall

if [[ "$GOPATH" == "" ]]; then
  mkdir -p $HOME/projects/go_resources/
  export GOPATH="$HOME/projects/go_resources/"
fi

export GOROOT=$(go env GOROOT)

if [[ "$OS" == "linux" ]]; then
  alias ls='ls --color=always'
elif [[ "$OS" == "macosx" || "$OS" == "bsd" ]]; then
  alias ls='ls -G'
fi
alias ll='ls -lh'
alias lla='ll -A'
alias grep='grep --color=auto'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'
alias mnt='mount | column -t'
alias gomod='GO111MODULE=on go'
alias mux='tmuxinator'

if [[ "$OS" == "macosx" && -e /usr/local/bin/gdate ]]; then
  alias date="/usr/local/bin/gdate"
fi

if [ -e $HOME/.zshrc.private ]; then
  # loading private stuff that should not be on github
  source $HOME/.zshrc.private
fi

export PULSE_LATENCY_MSEC=60
# Settings for umask
if (( EUID == 0 )); then
    umask 002
else
    umask 022
fi

## ZLE tweaks ##

## use the vi navigation keys (hjkl) besides cursor keys in menu completion
bindkey -M menuselect 'h' vi-backward-char        # left
bindkey -M menuselect 'k' vi-up-line-or-history   # up
bindkey -M menuselect 'l' vi-forward-char         # right
bindkey -M menuselect 'j' vi-down-line-or-history # bottom

## set command prediction from history, see 'man 1 zshcontrib'
is4 && zrcautoload predict-on && \
zle -N predict-on         && \
zle -N predict-off        && \
bindkey "^X^Z" predict-on && \
bindkey "^Z^X" predict-off

## press ctrl-q to quote line:
mquote () {
      zle beginning-of-line
      zle forward-word
      # RBUFFER="'$RBUFFER'"
      RBUFFER=${(q)RBUFFER}
      zle end-of-line
}
zle -N mquote && bindkey '^q' mquote

## define word separators (for stuff like backward-word, forward-word, backward-kill-word,..)
WORDCHARS='*?_-.[]~=/&;!#$%^(){}<>' # the default
WORDCHARS=.
WORDCHARS='*?_[]~=&;!#$%^(){}'
WORDCHARS='${WORDCHARS:s@/@}'

# just type '...' to get '../..'
rationalise-dot() {
local MATCH
if [[ $LBUFFER =~ '(^|/| |  |'$'\n''|\||;|&)\.\.$' ]]; then
  LBUFFER+=/
  zle self-insert
  zle self-insert
else
  zle self-insert
fi
}
zle -N rationalise-dot
bindkey . rationalise-dot
# without this, typing a . aborts incremental history search
bindkey -M isearch . self-insert

bindkey '\eq' push-line-or-edit

## some popular options ##

## add `|' to output redirections in the history
setopt histallowclobber

## try to avoid the 'zsh: no matches found...'
setopt nonomatch

## warning if file exists ('cat /dev/null > ~/.zshrc')
setopt NO_clobber

## don't warn me about bg processes when exiting
setopt nocheckjobs

## alert me if something failed
setopt printexitvalue

## Allow comments even in interactive shells
setopt interactivecomments


## telnet on non-default ports? ...well:
## specify specific port/service settings:
#telnet_users_hosts_ports=(
#  user1@host1:
#  user2@host2:
#  @mail-server:{smtp,pop3}
#  @news-server:nntp
#  @proxy-server:8000
#)

## aliases ##

## ignore ~/.ssh/known_hosts entries
#alias insecssh='ssh -o "StrictHostKeyChecking=no" -o "UserKnownHostsFile=/dev/null" -o "PreferredAuthentications=keyboard-interactive"'


## global aliases (for those who like them) ##

alias -g '...'='../..'
alias -g '....'='../../..'
#alias -g BG='& exit'
#alias -g C='|wc -l'
#alias -g G='|grep'
#alias -g H='|head'
#alias -g Hl=' --help |& less -r'
#alias -g K='|keep'
#alias -g L='|less'
#alias -g LL='|& less -r'
#alias -g M='|most'
#alias -g N='&>/dev/null'
#alias -g R='| tr A-z N-za-m'
#alias -g SL='| sort | less'
#alias -g S='| sort'
#alias -g T='|tail'
#alias -g V='| nvim -'

## instead of global aliase it might be better to use grmls $abk assoc array, whose contents are expanded after pressing ,.
#$abk[SnL]="| sort -n | less"

## get top 10 shell commands:
#alias top10='print -l ${(o)history%% *} | uniq -c | sort -nr | head -n 10'

## miscellaneous code ##

## Use a default width of 80 for manpages for more convenient reading
#export MANWIDTH=${MANWIDTH:-80}

## Set a search path for the cd builtin
cdpath=(.. ~)

## variation of our manzsh() function; pick you poison:
manzsh()  { /usr/bin/man zshall |  $PAGER +/"$1" ; }

## Switching shell safely and efficiently? http://www.zsh.org/mla/workers/2001/msg02410.html
bash() {
    NO_SWITCH="yes" command bash "$@"
}
restart () {
    exec $SHELL $SHELL_ARGS "$@"
}

## Handy functions for use with the (e::) globbing qualifier (like nt)
contains() { grep -q "$*" $REPLY }
sameas() { diff -q "$*" $REPLY &>/dev/null }
ot () { [[ $REPLY -ot ${~1} ]] }

# List all occurrences of programm in current PATH
plap() {
    emulate -L zsh
    if [[ $# = 0 ]] ; then
        echo "Usage:    $0 program"
        echo "Example:  $0 zsh"
        echo "Lists all occurrences of program in the current PATH."
    else
        ls -l ${^path}/*$1*(*N)
    fi
}

# Find out which libs define a symbol
lcheck() {
    if [[ -n "$1" ]] ; then
        nm -go /usr/lib/lib*.a 2>/dev/null | grep ":[[:xdigit:]]\{8\} . .*$1"
    else
        echo "Usage: lcheck <function>" >&2
    fi
}

# Memory overview
memusage() {
    ps aux | awk '{if (NR > 1) print $5;
                   if (NR > 2) print "+"}
                   END { print "p" }' | dc | numfmt --to=iec-i --suffix=B
}

# print hex value of a number
hex() {
    emulate -L zsh
    if [[ -n "$1" ]]; then
        printf "%x\n" $1
    else
        print 'Usage: hex <number-to-convert>'
        return 1
    fi
}

# get geolocation from domain/ip
function getipinfo() {
  curl -s https://ipinfo.io/$(dig +short "$1") | jq ;
}

# from https://gist.github.com/knadh/123bca5cfdae8645db750bfb49cb44b0
function preexec() {
  timer=$(($(date +%s%N)/1000000))
}

function human_readable_ms {
  local MS=$1
  local Ss="$((MS/1000))"
  local S="$((Ss % 60))"
  local M="$((Ss/60%60))"
  local H="$((Ss/60/60%24))"
  local D="$((Ss/60/60/24))"
  [[ $D > 0 ]] && printf '%dd ' $D
  [[ $H > 0 ]] && printf '%dh ' $H
  [[ $M > 0 ]] && printf '%dm ' $M
  # [[ $D > 0 || $H > 0 || $M > 0 && $S > 0 ]] && printf 'and '
  printf '%ds ' $S
  printf '(%dms)' $MS
}

function precmd() {
  if [ $timer ]; then
    now=$(($(date +%s%N)/1000000))
    elapsed=$(($now-$timer))
    human=$(human_readable_ms elapsed)

    export RPROMPT="%F{cyan}${human} %{$reset_color%}"
    unset timer
  fi
}

# create a directory and enter to it
# if parent directory does not exists, it creates it as well
function mkthencd {
  if [ ! -n "$1" ]; then
    echo "Usage: $0 <dir name>"
  elif [ -d $1 ]; then
    (>&2 echo "\`$1' already exists")
  else
    mkdir -p $1 && cd $1
  fi
}

# create a directory and enters it
# if the directory already exists, just enters it
function mkcd {
  if [ ! -n "$1" ]; then
    echo "Usage: $0 <dir name>"
    return
  fi

  mkdir -p $1 && cd $1
}

# Get to the top of a git tree
function gcdrt () {
  # from https://github.com/nibalizer/bash-tricks/
  TEMP_PWD=`pwd`
  while ! [ -d .git ]; do
  cd ..
  done
  OLDPWD=$TEMP_PWD
}

## associate types and extensions (be aware with perl scripts and anwanted behaviour!)
#check_com zsh-mime-setup || { autoload zsh-mime-setup && zsh-mime-setup }
#alias -s pl='perl -S'

## ctrl-s will no longer freeze the terminal.
#stty erase "^?"

## Some quick Perl-hacks aka /useful/ oneliner
bew() { perl -le 'print unpack "B*","'$1'"' }
web() { perl -le 'print pack "B*","'$1'"' }
hew() { perl -le 'print unpack "H*","'$1'"' }
weh() { perl -le 'print pack "H*","'$1'"' }
#pversion()    { perl -M$1 -le "print $1->VERSION" } # i. e."pversion LWP -> 5.79"
#getlinks ()   { perl -ne 'while ( m/"((www|ftp|http):\/\/.*?)"/gc ) { print $1, "\n"; }' $* }
#gethrefs ()   { perl -ne 'while ( m/href="([^"]*)"/gc ) { print $1, "\n"; }' $* }
#getanames ()  { perl -ne 'while ( m/a name="([^"]*)"/gc ) { print $1, "\n"; }' $* }
#getforms ()   { perl -ne 'while ( m:(\</?(input|form|select|option).*?\>):gic ) { print $1, "\n"; }' $* }
#getstrings () { perl -ne 'while ( m/"(.*?)"/gc ) { print $1, "\n"; }' $*}
#getanchors () { perl -ne 'while ( m/«([^«»\n]+)»/gc ) { print $1, "\n"; }' $* }
#showINC ()    { perl -e 'for (@INC) { printf "%d %s\n", $i++, $_ }' }
#vimpm ()      { vim `perldoc -l $1 | sed -e 's/pod$/pm/'` }
# vimhelp ()    { nvim -c "help $1" -c on -c "au! VimEnter *" }

if [[ -e '/etc/profile.d/emscripten.sh' ]]; then
  source /etc/profile.d/emscripten.sh
fi

if [[ -e "/etc/profile.d/android"* ]]; then
  # execute android's path scripts
  for f in `/etc/profile.d/android-*.sh`; do
    source $f
  done

  if [[ -e $ANDROID_HOME ]]; then
    if [[ ":$PATH:" != "*/opt/android-sdk/tools/bin/*" ]]; then
      PATH=$ANDROID_HOME/tools/bin:$PATH
    fi
  fi
fi
export PATH=${GOPATH}bin/:$PATH

# expprt the default settings for GOOS and GOARCH, I use them inside (n)vim
export GOOS=$(go env GOOS)
export GOARCH=$(go env GOARCH)

for i in $(seq 9 -1 3); do
  gempath="$HOME/.gem/ruby/2.$i.0/bin"
  if [[ -d "$gempath" ]]; then
    PATH=$gempath:$PATH
    break
  fi
done

# alias vim="nvim"
alias nvimdiff="nvim -d"
alias vimdiff="nvim -d"
alias vidadd="sudo modprobe uvcvideo"
alias vidrm="sudo modprobe -r uvcvideo"
alias mount_vm="sudo mount /run/media/ik/home_fs/ik/VirtualBox\ VMs ~/VirtualBox\ VMs --bind"

[[ -e ~/.fzf.zsh && `test -h ~/.fzf.zsh` ]] && source ~/.fzf.zsh

# added by travis gem
[ -e $HOME/.travis/travis.sh ] && source $HOME/.travis/travis.sh

export WORKON_HOME=$HOME/.venv
export PROJECT_HOME=$HOME/projects
# [ -e /usr/bin/virtualenvwrapper.sh ] && source /usr/bin/virtualenvwrapper.sh

if [[ "$OS" == "macosx" ]]; then
  test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"
fi

alias goget='go get -v -u'
# [ -e/usr/share/nvm/init-nvm.sh ] && source /usr/share/nvm/init-nvm.sh

# if [[ "$OS" == "linux" ]]; then
#   `which screenfetch 2>&1 > /dev/null`
#   [[ $? -eq 0 ]] && screenfetch
# fi

[[ -e $HOME/.antigen/bundles/robbyrussell/oh-my-zsh/plugins/tmux/tmux.plugin.zsh ]] && source $HOME/.antigen/bundles/robbyrussell/oh-my-zsh/plugins/tmux/tmux.plugin.zsh

# set to TMUX terminal if we are inside tmux
[[ $TMUX != "" ]] && export TERM="screen-256color"

###-tns-completion-start-###
if [ -f $HOME/.tnsrc ]; then
    source $HOME/.tnsrc
fi
###-tns-completion-end-###

eval "$(rbenv init -)"
