# how2use

- `$ docker pull hogehuga/epss-db`
- `$ docker volume create epssdbVolume`
- `$ docker container run --name epssdb -v epssdbVolume:/var/lib/mysql -e MYSQL_ROOT_PASSWORD=mysql -d hogehuga/epss-db`
- `$ docker exec -it epssdb /bin/bash`
- ``
- ``


# update images(devel)

- `$ cd docker`
- `$ docker build -t hogehuga/epss-db:<version> .`
- `$ docker login`
- `$ docker push hogehuga/epss-db`
