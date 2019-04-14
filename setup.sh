#!/usr/bin/env bash

if [ -f .env ]
then
  export $(cat .env | sed 's/#.*//g' | xargs)
fi


JETBRAINS_PRODUCTS=(teamcity hub youtrack upsource postgres teamcity-agent)
for item in ${JETBRAINS_PRODUCTS[*]}
do
    mkdir -p -m ${JETBRAINS_PERMS}  ${item}/backups ${item}/data ${item}/logs ${item}/temp ${item}/conf
    chown -R ${JETBRAINS_USER_ID}:${JETBRAINS_USER_ID} ${item}/backups ${item}/data ${item}/logs ${item}/temp ${item}/conf
    chmod -R ${JETBRAINS_PERMS} ${item}/backups ${item}/data ${item}/logs ${item}/temp ${item}/conf
done

rmdir teamcity/backups teamcity/temp
rmdir postgres/backups postgres/logs postgres/temp postgres/conf
rmdir teamcity-agent/backups teamcity-agent/data teamcity-agent/logs teamcity-agent/temp

sed -i "s/SED_JB_NETWORK/${JB_NETWORK}/g" docker-compose.yml
sed -i "s/JB_ROOT_DOMAIN_ESCAPED/${JB_ROOT_DOMAIN_ESCAPED}/g" nginx/cors_limited.conf

./certs.sh
