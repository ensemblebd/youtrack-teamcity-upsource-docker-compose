#!/usr/bin/env bash

if [ -z "$JB_NETWORK" ]
then
  if [ -f .env ]
  then
    export $(cat .env | sed 's/#.*//g' | xargs)
  fi
fi

mkdir -p nginx/certs
mkdir -p certs && cd certs

if [ ! -f "./v3.ext" ]
then
  touch v3.ext
  echo 'authorityKeyIdentifier=keyid,issuer' >> v3.ext
  echo 'basicConstraints=CA:FALSE' >> v3.ext
  echo 'keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment' >> v3.ext
fi

for i in 1 2
do
  if [ $i = 1 ]
  then 
    JETBRAINS_PRODUCTS=(hub)
  else 
    JETBRAINS_PRODUCTS=(teamcity youtrack upsource)
  fi

  for item in ${JETBRAINS_PRODUCTS[*]}
  do
    varname=JB_HOSTNAME_${item}
    hostname="${!varname}"
    dockername="${JB_PREFIX}${item}"
    echo " -- [CREATING CERTS] -- , for: [${item}], under container [${dockername}] and hosted at: [${hostname}]"
    openssl genrsa -out ${item}_TLS.pem 2048
    openssl req -new -key ${item}_TLS.pem -out ${item}_TLS_req.csr -subj "${JB_SELFSIGN_CERT_PROPS}/CN=${hostname}"
    rm -f v3.${item}.ext && cp v3.ext v3.${item}.ext
    echo "subjectAltName=DNS:${hostname},DNS:${dockername},DNS:${JB_PREFIX}nginx" >> v3.${item}.ext
    openssl x509 -in ${item}_TLS_req.csr -out ${item}_TLS_cert.pem -req -signkey ${item}_TLS.pem -days 3650 -extfile v3.${item}.ext
  
    mkdir -p ../${item}/conf/certs
    cp ${item}_TLS.pem ../nginx/certs/
    cp ${item}_TLS_cert.pem ../nginx/certs/
    [ $i = 1 ] && cp ${item}_TLS_cert.pem ../${item}/conf/certs/
    
    if [ $i = 1 ]
    then
      echo "JAVA_HOME/jre/bin/keytool -noprompt -storepass changeit -alias ${hostname} -import -keystore JAVA_HOME/jre/lib/security/cacerts -file /opt/${item}/conf/certs/${item}_TLS_cert.pem" >> ../${item}/conf/certs/install_certs.sh
    else 
      echo "JAVA_HOME/jre/bin/keytool -noprompt -storepass changeit -alias ${JB_HOSTNAME_hub} -import -keystore JAVA_HOME/jre/lib/security/cacerts -file /opt/${item}/conf/certs/hub_TLS_cert.pem" >> ../${item}/conf/certs/install_certs.sh 
    fi
    sed -i 's/JAVA_HOME/$JAVA_HOME/g' ../${item}/conf/certs/install_certs.sh
    chmod +x ../${item}/conf/certs/install_certs.sh
    
    #old approach-- instead of importing globally to JRE, rather import it directly into the product... Disabled at moment, here for posterity
    #$JAVA_HOME/bin/keytool -import -v -trustcacerts -alias src.mysite.com -file /opt/upsource/conf/certs/proxy.hub.crt -keystore /opt/upsource/conf/certs/cacerts.jks -keypass pwd_from_bundle.props -storepass pwd_from_bundle.props
  
    sed -i "s/JB_HOSTNAME_${item}/${hostname}/g" ../nginx/nginx.conf
    sed -i "s/JB_DOCKERNAME_${item}/${dockername}/g" ../nginx/nginx.conf
  
  done
done

JETBRAINS_PRODUCTS=(teamcity youtrack upsource)
for item in ${JETBRAINS_PRODUCTS[*]}
do
  cp ${item}_TLS_cert.pem ../hub/conf/certs
  cp hub_TLS_cert.pem ../${item}/conf/certs/

  if [ ${item} = 'youtrack' ]
  then 
    cp upsource_TLS_cert.pem ../${item}/conf/certs/
    echo "JAVA_HOME/jre/bin/keytool -noprompt -storepass changeit -alias ${JB_HOSTNAME_upsource} -import -keystore JAVA_HOME/jre/lib/security/cacerts -file /opt/${item}/conf/certs/upsource_TLS_cert.pem" >> ../${item}/conf/certs/install_certs.sh
    sed -i 's/XJAVA_HOME/$JAVA_HOME/g' ../${item}/conf/certs/install_certs.sh
  elif [ ${item} = 'upsource' ]
  then 
    cp youtrack_TLS_cert.pem ../${item}/conf/certs/
     echo "JAVA_HOME/jre/bin/keytool -noprompt -storepass changeit -alias ${JB_HOSTNAME_youtrack} -import -keystore JAVA_HOME/jre/lib/security/cacerts -file /opt/${item}/conf/certs/youtrack_TLS_cert.pem" >> ../${item}/conf/certs/install_certs    .sh
    sed -i 's/XJAVA_HOME/$JAVA_HOME/g' ../${item}/conf/certs/install_certs.sh
  fi

  varname=JB_HOSTNAME_${item}
  hostname="${!varname}"
  echo "XJAVA_HOME/jre/bin/keytool -noprompt -storepass changeit -alias ${hostname} -import -keystore XJAVA_HOME/jre/lib/security/cacerts -file /opt/hub/conf/certs/${item}_TLS_cert.pem" >> ../hub/conf/certs/install_certs.sh
  sed -i 's/XJAVA_HOME/$JAVA_HOME/g' ../hub/conf/certs/install_certs.sh
done


