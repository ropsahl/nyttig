#!/usr/bin/env bash

var="$1 Ikke funnet"
if [[ $1 == oc ]] ; then
    read -d '' var <<"EOF"
oc adm policy add-scc-to-user -z default anyuid
oc exec -it soknadsko- bash
EOF
fi

if [[ $1 =~ var ]] ; then
    read -d '' var <<"EOF"
# Frem til:
${VAR%%:*}
# Etter:
${VAR##:*}
# 8 tegn fra det 5.
${VAR;5;8}
EOF
fi

if [[ $1 =~ registry ]] ; then
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


EOF
fi

if [[ $1 == stopSlave ]] ; then
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
if [[ $1 =~ docker ]] ; then
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

if [[ $2 != '' ]] ;then
 echo "$var" |grep --color $2
else
 echo "$var"
fi