#!/usr/bin/env bash

if [ -f .env ]
then
  export $(cat .env | sed 's/#.*//g' | xargs)
fi


docker network create --driver bridge ${JB_NETWORK}

JETBRAINS_PRODUCTS=(teamcity hub youtrack upsource postgres teamcity-agent)
JETBRAINS_USER_ID=13001
JETBRAINS_PERMS=750

for item in ${JETBRAINS_PRODUCTS[*]}
do
    mkdir -p -m  ${item}/backups ${item}/data ${item}/logs ${item}/temp ${item}/conf
    chown -R ${JETBRAINS_USER_ID}:${JETBRAINS_USER_ID} ${item}/backups ${item}/data ${item}/logs ${item}/temp ${item}/conf
    chmod -R ${JETBRAINS_PERMS} ${item}/backups ${item}/data ${item}/logs ${item}/temp ${item}/conf
done

rmdir teamcity/backups teamcity/temp
rmdir postgres/backups postgres/temp postgres/logs postgres/temp postgres/conf
rmdir teamcity-agent/backups teamcity-agent/data teamcity-agent/logs teamcity-agent/temp
