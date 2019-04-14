#!/usr/bin/env bash

if [ -f .env ]
then
  export $(cat .env | sed 's/#.*//g' | xargs)
fi

JETBRAINS_PRODUCTS=(teamcity hub youtrack upsource)
for item in ${JETBRAINS_PRODUCTS[*]}
do
  if [ ! "$(docker ps -a | grep ${JB_PREFIX}${item})" ]
  then
    docker stop ${JB_PREFIX}${item} > /dev/null
    docker rm ${JB_PREFIX}${item} > /dev/null
  fi
  echo "Cleaning directories: ${item}"
  rm -rf ./${item}/backups/
  rm -rf ./${item}/logs/ 
  rm -rf ./${item}/data/
  rm -rf ./${item}/temp/
  rm -rf ./${item}/certs/
  rm -rf ./certs/
done

docker stop jetbrains_teamcity-agent_1 > /dev/null  && docker rm jetbrains_teamcity-agent_1 > /dev/null
docker stop ${JB_PREFIX}nginx > /dev/null && docker rm ${JB_PREFIX}nginx > /dev/null
docker network rm ${JB_NETWORK}_${JB_NETWORK}
