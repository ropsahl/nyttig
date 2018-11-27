#!/usr/bin/env bash
RED=$(echo -en '\033[00;31m')
GREEN=$(echo -en '\033[00;32m')
YELLOW=$(echo -en '\033[00;33m')
BLUE=$(echo -en '\033[00;34m')

function __ocp() {
    status=$(cat   ~/.kube/config |grep 'current-context')
    if [[ $? == 0 ]] ; then
        project=${status##* };project=${project%%/*};
        cluster=${status##*cluster-};cluster=${cluster%%:*}
        color=${RED}
        if [[ "$cluster" == "poc" ]] ; then
            color=${GREEN}
        elif [[ "$cluster" == "dev" ]] ; then
            color=${YELLOW}
        elif [[ "$cluster" == "demo" ]] ; then
            color=${BLUE}
        fi
        echo "${color}[${project}@${cluster}]"
    fi
}

git_branch() {
  b=$(git branch 2>/dev/null | grep '^*' | colrm 1 2)
  s=$(git status|grep modified>/dev/null;if [[ $? == 0 ]]; then echo '*';fi)
  c=$(if [[ "$b" == "master" ]];then echo $RED;else echo $GREEN;fi)
  echo "$c[$b$s]"
}

function _tagWindow() { 
  _TTAG=$1;
  color='\e[0;97m';
  textColor=$color;
  if [[ $(hostname) =~ doc-prod-master ]] ;then color='\e[38;5;196m';textColor=$color;fi
  if [[ $(hostname) =~ mgmt-devops01 ]] ;then color='\e[38;5;226m';textColor=$color;fi
  if [[ $(hostname) =~ .* ]] ;then color='\e[38;5;226m';fi
  if [[ $(hostname) =~ localhost ]] ;then color='\e[0;32m';fi
  PS1="$(__ocp)$(git_branch)\[$color\]\w\[$textColor\]\n\$ "
}
_tagWindow
function hg() { history|grep "$@"; }

bind '"\C-p": history-search-backward'
bind '"\C-n": history-search-forward'
bind '"\e[A": history-search-backward'
bind '"\e[B": history-search-forward'

function du_nodes() {
  for id in $(docker -H doc-test-master:2376 ps |grep jenkins-swarm|grep doc-test-node|sed 's/ .*doc-test-node/;doc-test-node/'); do 
    echo
    echo ${id//*;/};
    echo docker  -H doc-test-master:2376 exec -i -t ${id//;*/} bash; 
    docker  -H doc-test-master:2376 exec -i -t ${id//;*/} df -h ;
  done
}

log_bash_persistent_history()
{
  cmd=$(history 1)
  
  if [ "$cmd" != "$PERSISTENT_HISTORY_LAST" ]
  then
    echo $(date +'%Y-%m-%d-%H:%M:%S') ${cmd#* } >> ~/.persistent_history
    export PERSISTENT_HISTORY_LAST="$cmd"
  fi
}

# Stuff to do on PROMPT_COMMAND
run_on_prompt_command()
{
    log_bash_persistent_history
    _tagWindow
}

PROMPT_COMMAND="run_on_prompt_command"
export DATE_TIME='[0-9]*-[0-9]*-[0-9]*[ -][0-9]*:[0-9]*:[0-9]* '
function hgp {
 cat ~/.persistent_history |sed "s/$DATE_TIME//" |sort -u |grep --color "$1" 
}

source <(kubectl completion bash)
alias k=kubectl
alias l='ls -lrt'

setxkbmap no

