#!/usr/bin/env bash
RED=$(echo -en '\033[00;31m')
GREEN=$(echo -en '\033[01;32m')
#YELLOW=$(echo -en '\033[00;33m')
YELLOW=$(echo -en '\033[0;32m')
WHITE=$(echo -en '\033[00m')
BLUE=$(echo -en '\033[01;34m')

function __ocp() {
    status=$(cat   ~/.kube/config |grep 'current-context')
    if [[ $? == 0 ]] ; then
        project=${status##* };project=${project%%/*};
        cluster=${status#*/};cluster=${cluster%%-corp*};
#        echo $project
#        echo $cluster
        color=${RED}
        if [[ "$cluster" =~ 'test-dchub' ]] ; then
            color=${GREEN}
        elif [[ "$cluster" == "dev" ]] ; then
            color=${YELLOW}
        elif [[ "$cluster" == "test-bsshub" ]] ; then
            color=${BLUE}
        fi
        echo "$color[${project}@${cluster}]"
    fi
}

git_branch() {
  if [ -d ".git" ] ; then
    b=$(git branch 2>/dev/null | grep '^*' | colrm 1 2)
    s=$(git status|grep modified>/dev/null;if [[ $? == 0 ]]; then echo '*';fi)
    c=$(if [[ "$b" == "master" ]];then echo $RED;else echo $GREEN;fi)
    echo "$c[${b:0:20}$s]"
  fi
  echo ""
}

function _tagWindow() {
  _TTAG=$1;
  openshift=$(__ocp)
  PS1="\[\e]0;\u@\h:  \w \a\]$BLUE\w$openshift$(git_branch) $WHITE\n\$ "
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
    if [[ $? -eq 0 ]] ; then
      log_bash_persistent_history
    fi
    _tagWindow
}

PROMPT_COMMAND="run_on_prompt_command"
export DATE_TIME='[0-9]*-[0-9]*-[0-9]*[ -][0-9]*:[0-9]*:[0-9]*'
function hgp {
 grep "$1" ~/.persistent_history |sed "s/$DATE_TIME [0-9]* //" |awk '!_[$0]++'|grep --color "$1"
}

function hp {
 tail -"$1" ~/.persistent_history |sed "s/$DATE_TIME [0-9]* //" |awk '!_[$0]++'
}

source <(~/bin/oc completion bash)
source <(~/bin/kubectl completion bash)
alias k=kubectl
alias l='ls -lrt'
export EDITOR='/usr/bin/vi'
export OPENSHIFT_USER=t936990
# setxkbmap no

