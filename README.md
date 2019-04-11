docker-compose with multiple [JetBrains](https://www.jetbrains.com/) services:
* youtrack (issue tracker)
* teamcity (ci)
* * Postgres linked
* upsource (code browser)
* hub (centralized auth)

Provisioned onto docker network (for later additions of agents).
Repo was forked and modified to provision the latest images from vendor.

USAGE:
* ```git clone repo && cd repo```
* Configure as needed
  * ```vim .env```
  * ```vim init.sql```
  * ```vim docker-compose.yml```
* ```./setup.sh```
* docker-compose up -d

IN PROGRESS:

TODO:
* Implement manual Dockerfile git clone of Teamcity-server repo, to allow for provisioning customized services on install per docs.
* add sample addon compose/docker files to provision additional agents (nano win, or extended toolset variation)
