docker-compose with multiple [JetBrains](https://www.jetbrains.com/) services:
* youtrack (issue tracker)
* teamcity (ci)
* * Postgres linked
* upsource (code browser)
* hub (centralized auth)

Provisioned onto docker network (for later additions of agents).
Repo was forked and modified to provision the latest images from vendor.

Additionally, this branch is intended for usage by an internal proxy system.
Ideally, you would run as defined below after configuring, and it produces all 4 products linked together by docker network using self-signed and self-accepted certificates, as provisioned over an internal nginx proxy.
This is the only way, outside of providing real ssl certs, to properly connect the products to the Hub, or each other. 
I left the port for nginx open, allowing one to utilize /hosts file for testing purposes. Delete the port in docker-compose to secure it. 

USAGE:
* ```git clone repo && cd repo```
* Configure as needed
  * ```vim .env```
  * ```vim init.sql```
  * ```vim docker-compose.yml```
* ```./setup.sh```
* docker-compose up -d
  
The .env config is CRITICAL. The options there are used through the scripts.  
Your hostnames are utilized for an internal reverse-proxy allowing the Java products to connect to each other on the internal network over SSL via self-signed certs.   
The Network Subnet is the first 3 octets of the subnet: ```10.0.0```, or ```192.168.1```, or ```172.31.0``` for example.  
This is used to assign the intended external web address to be utilized by the internal product as cascaded over an ssl proxy, as resolved by the /etc/hosts file (extra_hosts).

I could've written up Dockerfile's to provision the installation of self-signed (approved) certificates via the install_certs.sh generated in each conf/certs/ folder.
But did not. Therefore one must ```docker exec -u 0 -it <container> bash``` followed by ```/opt/<product>/conf/certs/install_certs.sh``` . 
It imports into the global keystore for entire product container. 
