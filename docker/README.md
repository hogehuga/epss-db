# remove epss-db

- remove container
  - `$ docker ps`
  - `$ docker stop <target>`
  - `$ docker ps -a`
  - `$ docker rm <target>`
- remove docker image
  - `$ docker rmi hogehuga/epss-db`
- remove docker volumes
  - `$ docker volume ls`
  - `$ docker volume rm epssDB`
  - `$ docker volume rm epssFile`
- creanup shared folder

# update images(devel)

- modify hogehuga/epss-db
- `$ cd docker`
- `$ docker bulder prune -f` (キャッシュ削除)
- `$ docker build . -t hogehuga/epss-db:<version> -t hogehuga/epss-db:latest`
- `$ docker login`
- `$ docker push hogehuga/epss-db -a`
