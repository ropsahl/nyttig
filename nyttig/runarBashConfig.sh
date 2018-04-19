#!/usr/bin/env bash
RED=$(echo -en '\033[00;31m')
GREEN=$(echo -en '\033[00;32m')
YELLOW=$(echo -en '\033[00;33m')
BLUE=$(echo -en '\033[00;34m')

function __ocp() {
    status=$(oc status 2>/dev/null)
    if [[ $? == 0 ]] ; then
        project=${status%% on*};project=${project##* }
        cluster=${status%%:8443*};cluster=${cluster##*cluster.}
        color=${RED}
        if [[ "$cluster" == "poc" ]] ; then
            color=${GREEN}
        elif [[ "$cluster" == "dev" ]] ; then
            color=${YELLOW}
        fi
        echo "${color}[${project}@${cluster}]"
    fi
}

function _tagWindow() { 
  _TTAG=$1;
  color='\e[0;97m';
  textColor=$color;
  if [[ $(hostname) =~ doc-prod-master ]] ;then color='\e[38;5;196m';textColor=$color;fi
  if [[ $(hostname) =~ mgmt-devops01 ]] ;then color='\e[38;5;226m';textColor=$color;fi
  if [[ $(hostname) =~ .* ]] ;then color='\e[38;5;226m';fi
  if [[ $(hostname) =~ localhost ]] ;then color='\e[0;32m';fi
  PS1="$(__ocp) \u@\h \[$color\]\w\[$textColor\]\n\$ "
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

PROMPT_COMMAND='_tagWindow'

