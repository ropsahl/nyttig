#!/usr/bin/env bash

var="$1 Ikke funnet"
KEYS='oc var reg jenkins docker curl state git tools prom color'
if [[ ${KEYS} != *"$1"* ]] ;then
  echo Lovlige argument: $KEYS
fi

if [[ $1 == tools ]] ; then
    read -d '' var <<"EOF"
stern_linux_amd64
EOF
fi

if [[ $1 =~ prom:* ]] ; then
    read -d '' var <<"EOF"

{__name__=~"kube_replicationcontroller_status.*",namespace="bostotte-bygg-deploy"}

# Ignorere pod og server, fra resultatet slik at pod restart ikke gir nytt datasett:
label_replace(label_replace(haproxy_server_http_responses_total{namespace=~"$Namespace",route=~".+",code=~".+"},"pod","ignore","pod","(.+)"),"server","ignore","server",".+")

# Bare de der verdi >0
haproxy_server_http_responses_total{namespace=~"$Namespace",route=~".+",code=~".+"} and haproxy_server_http_responses_total{namespace=~"$Namespace",route=~".+",code=~".+"}>0
haproxy_server_http_responses_total{namespace=~"$Namespace",route=~".+",code=~".+"} unless haproxy_server_http_responses_total{namespace=~"$Namespace",route=~".+",code=~".+"}==0

label_replace(kube_replicationcontroller_status_replicas{namespace="bostotte-bygg-deploy"},"navn","$1","replicationcontroller","(.*)-.*")
label_replace(kube_replicationcontroller_status_available_replicas{instance=~"kube.*"},"navn","$1","replicationcontroller","(.*)-.*")
EOF
fi

if [[ $1 == oc ]] ; then
    read -d '' var <<"EOF"
oc adm policy add-scc-to-user -z default anyuid
oc exec -it soknadsko- bash
#Slette hengende pod,
GUI->Delete pod, kryss av Delete pod immediately
#Port forward:
oc port-forward -p $(oc get pods|grep hb-openshift-mongo|sed 's/ .*//') 27017:27017
#CRON
oc run cronmaintenance --image=docker-registry01.local.husbanken.no/hb-java-8-rhel7:2.0.1 --schedule='*/1 * * * *' --restart=Never --labels parent="cronmaintenance" --command -- curl registry-maintenance:8080/delete/candidates
oc delete cronjob/cronmaintenance

EOF
fi

if [[ $1 =~ var.* ]] ; then
    read -d '' var <<"EOF"
# Frem til:
${VAR%%:*}
# Etter:
${VAR##*:}
# 8 tegn fra det 5.
${VAR;5;8}
EOF
fi

if [[ $1 =~ reg.* ]] ; then
    read -d '' var <<"EOF"
# liste alle image
curl -sqfk https://docker-registry01.local.husbanken.no/v2/_catalog?n=50000|jq -r '.repositories|.[]'

# image og tags
image=$1
tags=$(curl -sqfk https://docker-registry01.local.husbanken.no/v2/$image/tags/list|jq -r '.tags|.[]')
for tag in $tags ; do
   sha=$(curl -sIik -H "Accept: application/vnd.docker.distribution.manifest.v2+json"  https://docker-registry01.local.husbanken.no/v2/$image/manifests/$tag|grep Digest|sed 's/Docker-Content-Digest: //'|strings);
   echo "$sha $tag";
done|sort

echo curl -sIik -H "Accept: application/vnd.docker.distribution.manifest.v2+json"  -X DELETE https://docker-registry01.local.husbanken.no/v2/$image/manifests/sha256:

id=$(curl --silent --fail --insecure -H "Accept: application/vnd.docker.distribution.manifest.v2+json" https://docker-registry01.local.husbanken.no/v2/$image/manifests/$tag |grep digest|head -1|sed 's/.*sha256://')

for image in $(curl -sqfk https://docker-registry01.local.husbanken.no/v2/_catalog?n=50000|jq -r '.repositories|.[]'|grep startskudd); do
   echo $image;
   for tag in $(curl -sqfk https://docker-registry01.local.husbanken.no/v2/$image/tags/list|jq -r '.tags|.[]'|grep '2.5.0'); do
     sha=$(curl -sIik -H "Accept: application/vnd.docker.distribution.manifest.v2+json"  https://docker-registry01.local.husbanken.no/v2/$image/manifests/$tag|grep Digest|sed 's/Docker-Content-Digest: //'|strings);
     echo "$sha $tag";
   done;
done

BLOBS
curl -k -H "Accept: application/vnd.docker.distribution.manifest.v2+json"  https://docker-registry01.local.husbanken.no/v2/hb-java-8-rhel7/blobs/sha256:f355ab90ff81937205a1db238720a782d8b44f3003b35336cc600295d3a2abf5

# Semantisk versjonering, major minor:
JENKINS_VERSJON="3.10.1-develop"
RE='[^0-9]*\([0-9]*\)[.]\([0-9]*\)[.]\([0-9]*\)\([0-9A-Za-z-]*\)'
JENKINS_MAJOR_VERSJON=$(echo $JENKINS_VERSJON | sed -e "s#$RE#\1\4#")
JENKINS_MINOR_VERSJON=$(echo $JENKINS_VERSJON | sed -e "s#$RE#\1.\2\4#")

EOF
fi

if [[ $1 == jenkins.* ]] ; then
    read -d '' var <<"EOF"
for (aSlave in hudson.model.Hudson.instance.slaves) {
    println('====================');
    println('Name: ' + aSlave.name);
    println('getLabelString: ' + aSlave.getLabelString());
    println('getNumExectutors: ' + aSlave.getNumExecutors());
    println('getRemoteFS: ' + aSlave.getRemoteFS());
    println('getMode: ' + aSlave.getMode());
    println('getRootPath: ' + aSlave.getRootPath());
    println('getDescriptor: ' + aSlave.getDescriptor());
    println('getComputer: ' + aSlave.getComputer());
    println('\tcomputer.isAcceptingTasks: ' + aSlave.getComputer().isAcceptingTasks());
    println('\tcomputer.isLaunchSupported: ' + aSlave.getComputer().isLaunchSupported());
    println('\tcomputer.getConnectTime: ' + aSlave.getComputer().getConnectTime());
    println('\tcomputer.getDemandStartMilliseconds: ' + aSlave.getComputer().getDemandStartMilliseconds());
    println('\tcomputer.isOffline: ' + aSlave.getComputer().isOffline());
    println('\tcomputer.countBusy: ' + aSlave.getComputer().countBusy());
    if (aSlave.name == 'NAME OF NODE TO DELETE') {
      println('Shutting down node!!!!');
      aSlave.getComputer().setTemporarilyOffline(true,null);
      aSlave.getComputer().doDoDelete();
    }
    println('\tcomputer.getLog: ' + aSlave.getComputer().getLog());
    println('\tcomputer.getBuilds: ' + aSlave.getComputer().getBuilds());
}
EOF
fi
if [[ $1 =~ docker.* ]] ; then
    read -d '\n' var <<'EOF'
    docker -H doc-test-master:2376 ps|grep stil
    docker -H doc-test-master:2376 logs f453570059bd
    docker -H doc-test-master:2376 exec -it f453570059bd /bin/bash
    docker -H doc-test-master:2376 inspect f453570059bd

    --------docker cleanup
    docker rm $(docker ps -a|awk '{print $1}')
    docker rmi -f $(docker images|grep 'none'|awk '{print $3}')

    --------docker registry lookup sha
    curl -Iik -H "Accept: application/vnd.docker.distribution.manifest.v2+json" https://docker-registry01/v2/jenkins-runar/manifests/2
    docker -H doc-prod-master:2376 inspect 1111f21e776f|grep Memory
    docker -H doc-prod-master:2376 stats 1111f21e776f
    docker -H doc-prod-master:2376 exec -u 0 -it 1111f21e776f sh
    docker -H doc-prod-master:2376 update -m 3500m 1111f21e776f
    $ docker ps -a|cut -d' ' -f1|xargs docker rm
    curl -k https://docker-registry01.local.husbanken.no/v2/_catalog?n=5000|sed 's/,/\n/g'|grep jenkins
    curl -k https://docker-registry01.local.husbanken.no/v2/jenkins-2-centos7/tags/list
    docker exec -it $(docker ps |grep jenkins|awk '{print $1}') bash
    ---- tags docker registry
    for p in $(curl -k https://docker-registry01.local.husbanken.no/v2/_catalog?n=5000|sed -e 's/,/\n/g' -e 's/"//g'|grep jenkins);do curl -k https://docker-registry01.local.husbanken.no/v2/$p/tags/list;done
    curl -Iik -H "Accept: application/vnd.docker.distribution.manifest.v2+json" https://docker-registry01/v2/jenkins-runar/manifests/1
    curl -Iik -H "Accept: application/vnd.docker.distribution.manifest.v2+json" -X DELETE https://docker-registry01/v2/jenkins-runar/manifests/sha256:64157491163845dded47f84dc7c11a13f79441f6b4fce8ac399e69f561ba00cc
    for t in $(curl -sk https://docker-registry01.local.husbanken.no/v2/jenkins-runar/tags/list|sed -e 's/.*\[//' -e 's/"//g' -e 's/\]\}//' -e 's/,/ /g'); do echo tag $t; curl -sIik -H "Accept: application/vnd.docker.distribution.manifest.v2+json" https://docker-registry01/v2/jenkins-runar/manifests/$t|grep 'Docker-Content-Digest'|sed 's#Docker-Content-Digest: #curl -Iik -H "Accept: application/vnd.docker.distribution.manifest.v2+json" -X DELETE https://docker-registry01/v2/jenkins-runar/manifests/#';done
    docker -H doc-prod-master:2376 ps
        CLI_EXEX="docker -H doc-prod-master:2376 exec -it $(docker -H doc-prod-master:2376 ps -q --filter=label=com.docker.compose.service=soknadsko) wildfly/bin/jboss-cli.sh"
    CLI_EXEX="docker -H doc-prod-master:2376 exec -it $(docker -H doc-prod-master:2376 ps -q --filter=label=com.docker.compose.service=soknadsko) wildfly/bin/jboss-cli.sh"
    systemctl stop docker
    systemctl enable docker
    systemctl start docker
    rm -rf /var/lib/docker/*
    while sleep 3;do id=$(ps -ef|grep startlan-esoknad|grep -v grep|sed 's/.*://');curl --silent --fail --insecure https://docker-registry01.local.husbanken.no/v2/startlan-esoknad-vedlegg-behandling/tags/list|sed -e 's/.*\[//' -e 's/[",]/ /g' -e 's/\].*//'|grep $id;df -h /;done
    kill $(ps -ef|grep startlan-esoknad|grep docker|grep pull|grep -v grep|sed 's/horu //'|awk '{print $1}')
    tags=$(curl --silent --fail --insecure https://docker-registry01.local.husbanken.no/v2/startlan-esoknad-vedlegg-behandling/tags/list|sed -e 's/.*\[//' -e 's/[",]/ /g' -e 's/\].*//')
        docker pull docker-registry01.local.husbanken.no/startlan-esoknad-vedlegg-behandling:$tag >>pull.log
    ids=$(docker images docker-registry01.local.husbanken.no/startlan-esoknad-vedlegg-behandling |awk '{print $3}'|sort -u|grep -v IMAGE)
         created=$(docker inspect --format='{{json .Created}}' $id);
            digest=$(docker inspect --format='{{json .RepoDigests}}' $id|sed -e "s#docker-registry01.local.husbanken.no/startlan-esoknad-vedlegg-behandling[:@]##g"  -e 's/\[\"//g' -e 's/\".*//g')
            curl -sIik -H Accept: application/vnd.docker.distribution.manifest.v2+json -X DELETE https://docker-registry01.local.husbanken.no/v2/startlan-esoknad-vedlegg-behandling/manifests/$digest
            curl -sIik -H Accept: application/vnd.docker.distribution.manifest.v2+json -X DELETE https://docker-registry01.local.husbanken.no/v2/startlan-esoknad-vedlegg-behandling/manifests/$sha;
EOF
fi

if [[ $1 =~ curl.* ]] ; then
    read -d '\n' var <<'EOF'
POST:
curl -X POST https://sim-esoknad-startlan-esoknad-e2e.cluster.dev/simulert/login -d='{ "uid": "01026300394",  "fnr": "01026300394",  "mobiltelefonnummer": "12345678",  "Culture": "nb",  "DigitalContactInfoStatus": "NEI",  "SecurityLevel": 999 }'
EOF
fi

if [[ $1 =~ koer.* ]] ; then
    read -d '\n' var <<'EOF'
    oc exec -it soknadsko- bash
wildfly/bin/jboss-cli.sh
connect
/subsystem=messaging/hornetq-server=default/jms-queue=DLQ:list-messages
/subsystem=messaging/hornetq-server=default/jms-queue=meldingFraSokerDLQ:list-messages
/subsystem=messaging/hornetq-server=default/jms-queue=meldingLestDLQ:list-messages
/subsystem=messaging/hornetq-server=default/jms-queue=soknadTilSaksbehandlingDLQ:list-messages
/subsystem=messaging/hornetq-server=default/jms-queue=vedleggDLQ:list-messages

/subsystem=messaging/hornetq-server=default/jms-queue=vedleggDLQ:move-message(message-id=ID:afbf84da-1bfd-11e8-b633-e5609acccc92, other-queue-name=vedlegg)
EOF
fi

if [[ $1 =~ state.* ]] ; then
    read -d '\n' var <<'EOF'
 kubectl scale statefulsets <stateful-set-name> --replicas=<new-replicas>
EOF
fi

if [[ $1 =~ git.* ]] ; then
    read -d '\n' var <<'EOF'
Fjern 3 siste commit, blir usynk mot remote så må committe på ny branch!
git reset --soft HEAD~3
Checksum for dir:
git ls-tree -r HEAD startlan-esoknad-backend|git hash-object --stdin
git tag -a -f -m 'Jenkins pipeline docker image' 0.4.0-develop && git push --tags -f
EOF
fi

if [[ $1 =~ col.* ]] ; then
    read -d '\n' var <<'EOF'
RESTORE=$(echo -en '\033[0m')
RED=$(echo -en '\033[00;31m')
GREEN=$(echo -en '\033[00;32m')
YELLOW=$(echo -en '\033[00;33m')
BLUE=$(echo -en '\033[00;34m')
MAGENTA=$(echo -en '\033[00;35m')
PURPLE=$(echo -en '\033[00;35m')
CYAN=$(echo -en '\033[00;36m')
LIGHTGRAY=$(echo -en '\033[00;37m')
LRED=$(echo -en '\033[01;31m')
LGREEN=$(echo -en '\033[01;32m')
LYELLOW=$(echo -en '\033[01;33m')
LBLUE=$(echo -en '\033[01;34m')
LMAGENTA=$(echo -en '\033[01;35m')
LPURPLE=$(echo -en '\033[01;35m')
LCYAN=$(echo -en '\033[01;36m')
WHITE=$(echo -en '\033[01;37m')

# Test
echo ${RED}RED${GREEN}GREEN${YELLOW}YELLOW${BLUE}BLUE${PURPLE}PURPLE${CYAN}CYAN${WHITE}WHITE${RESTORE}
EOF
fi

if [[ $2 != '' ]] ;then
 echo "$var" |grep --color $2
else
 echo "$var"
fi