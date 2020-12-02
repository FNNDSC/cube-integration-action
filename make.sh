#!/bin/bash -ex
# provision CUBE for local development and then run integration tests

repo=${INPUT_REPOSITORY:-https://github.com/FNNDSC/ChRIS_ultron_backEnd.git}
cube_folder=$(mktemp -dt ChRIS_ultron_backEnd_XXXX)
echo "::save-state name=cube_folder::$cube_folder"

git clone --depth=1 "$repo" $cube_folder
cd $cube_folder

docker pull fnndsc/pfdcm
docker pull fnndsc/swarm

docker swarm init --advertise-addr 127.0.0.1

chmod -R 755 $PWD
mkdir -p FS/remote
chmod -R 777 FS

export STOREBASE=$PWD/FS/remote COMPOSE_FILE=$PWD/docker-compose_dev.yml

docker-compose up -d

{ set +x; } 2> /dev/null
echo Waiting for MySQL database to be ready to accept connections
tries=0
until docker-compose exec -T chris_dev_db mysqladmin -uroot -prootp status 2> /dev/null; do
  echo .
  sleep 5
  if [ "$((tries++))" -gt "60" ]; then
    echo "Timed out waiting for MySQL server"
    exit 1
  fi
done
echo done

set -x

docker-compose exec -T chris_dev_db mysql -uroot -prootp -e 'GRANT ALL PRIVILEGES ON *.* TO "chris"@"%"'

docker-compose exec -T chris_dev python manage.py test --tag integration
