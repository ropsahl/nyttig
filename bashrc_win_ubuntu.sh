#!/usr/bin/env bash
RED=$(echo -en '\033[00;31m')
GREEN=$(echo -en '\033[01;32m')
YELLOW=$(echo -en '\033[0;32m')
WHITE=$(echo -en '\033[00m')
BLUE=$(echo -en '\033[01;34m')

function err() {
  echo "${RED}$@${WHITE}"
}

bind '"\C-p": history-search-backward'
bind '"\C-n": history-search-forward'
bind '"\e[A": history-search-backward'
bind '"\e[B": history-search-forward'

log_bash_persistent_history() {
  cmd=$(history 1)
  if [[ ! "$cmd" == "$PERSISTENT_HISTORY_LAST" ]] ; then
    if [[ ! ${cmd#* } =~ ^hgp.* ]] ; then
      echo "$(date +'%Y-%m-%d-%H:%M:%S') ${cmd#* }" >>~/.persistent_history
      export PERSISTENT_HISTORY_LAST="$cmd"
    fi
  fi
}
__git_ps1_color() {
  if [[ $(__git_ps1) =~ master ]] ; then
    echo "$RED$(__git_ps1)"
  else
    echo "$(__git_ps1)"
  fi
}
# Stuff to do on PROMPT_COMMAND
run_on_prompt_command() {
  if [[ $? -eq 0 ]]; then
    log_bash_persistent_history
  fi
  export PS1="$BLUE(\$?)$(__git_ps1_color)$GREEN\w $WHITE\n\$ \[$(tput sgr0)\]"
}

PROMPT_COMMAND="run_on_prompt_command"
export DATE_TIME='[0-9]*-[0-9]*-[0-9]*[ -][0-9]*:[0-9]*:[0-9]*'
function hgp() {
  grep "$1" ~/.persistent_history | sed -r -e "/.{300,}/d" -e "s/$DATE_TIME [0-9]* //" | awk '!_[$0]++' | grep --color "$1"
}

function hgpp() {
  greps=""
  args=""
  for a in "$@"; do
    greps="$greps | grep $a "
    args="$args -e $a "
  done
  cmd="cat ~/.persistent_history $greps | sed -r -e '/.{300,}/d' -e 's/$DATE_TIME [0-9]* //' | awk '!_[$0]++' | grep $args"
  echo "CMD: $cmd"
  eval "$cmd"
}

function husk() {
  grep -A 10  -B 10 "$1" ~/.persistent_history | grep -v ^"$DATE_TIME" |sed 's/^EOF/-------------------------------------/'| grep  -A 10 -B 10 --color "$1"
}

function hp() {
  if [ -z "${1}" ] ; then lines=10; else lines="$1";fi
  tail -"$lines" ~/.persistent_history | sed "s/$DATE_TIME [0-9]* //" | awk '!_[$0]++'
}

function java11() {
  sudo rm /etc/alternatives/java
  sudo ln -s /usr/lib/jvm/java-11-openjdk-amd64/bin/java /etc/alternatives/java
  sudo rm /etc/alternatives/javac
  sudo ln -s /usr/lib/jvm/java-11-openjdk-amd64/bin/java /etc/alternatives/javac
}
function java17() {
   sudo rm /etc/alternatives/java
   sudo ln -s /usr/lib/jvm/java-17-openjdk-amd64/bin/java /etc/alternatives/java
   sudo rm /etc/alternatives/javac
   sudo ln -s /usr/lib/jvm/java-17-openjdk-amd64/bin/java /etc/alternatives/javac
}

#export DOCKER_HOST=localhost:2375
function docker() {
  sudo /usr/bin/docker "$@"
}

function docker-compose() {
  sudo /usr/bin/docker-compose "$@"
}

export PROXY="https_proxy=socks5://127.0.0.1:12345"
alias kubectl="${PROXY} kubectl"
alias helm="${PROXY} helm"
alias oc="${PROXY} oc"
#source <(oc completion bash)
#source <(kubectl completion bash)
alias k=kubectl

alias l='ls -lrt'



export EDITOR='/usr/bin/vi'
export PATH=~/java/bin:$PATH

# TietoEvry
function tsync() {
    rsync -ulrv --delete --exclude '.idea' --exclude 'data' --exclude 'target' --exclude 'logs' --exclude 'workspace.xml' --exclude '.flattened-pom.xml' --exclude 'htmlReport' --exclude 'dockerlogs' --exclude out ~/wCode/$1/ ~/code/$1/
    find ~/code/$1/scripts -type f -exec dos2unix {} \; &>/dev/null
    dos2unix Makefile
}


cd

