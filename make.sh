#!/bin/bash -ex
# provision CUBE for local development and then run integration tests

# get inputs
repo=${INPUT_REPOSITORY:-https://github.com/FNNDSC/ChRIS_ultron_backEnd.git}
branch=
if [ -n "$INPUT_BRANCH" ]; then
  branch="--branch=$INPUT_BRANCH"
fi

# check if repo needs to be downloaded
if [ -d "$repo" ]; then
  cube_folder="$(realpath "$repo")"
  if [ -n "branch" ]; then
    echo "::warning ::Ignoring branch=$branch because repository=$repo is a directory"
  fi
else
  echo "should_cleanup=true" >> $GITHUB_STATE
  cube_folder=$(mktemp -dt ChRIS_ultron_backEnd_XXXX)
  git clone --depth=1 $branch "$repo" $cube_folder
fi

cd $cube_folder
echo "cube_folder=$cube_folder" >> $GITHUB_STATE

docker swarm init --advertise-addr 127.0.0.1
docker network create -d overlay --attachable remote

chmod -R 755 $PWD
mkdir -p FS/remote
chmod -R 777 FS

export STOREBASE=$PWD/FS/remote COMPOSE_FILE=$PWD/docker-compose_dev.yml

docker stack deploy -c $PWD/swarm/docker-compose_remote.yml pfcon_stack
docker-compose up -d

{ set +x; } 2> /dev/null
printf Waiting for PostgreSQL database to be ready to accept connections
tries=0
until docker-compose exec -T chris_dev_db psql -U chris -d chris_dev -c "select 1" \
  > /dev/null 2>&1; do
  printf .
  sleep 5
  if [ "$((tries++))" -gt "60" ]; then
    echo "Timed out waiting for PostgreSQL server"
    exit 1
  fi
done
echo done

set -x

if [ "$INPUT_WHICH" = "all" ]; then
  docker-compose exec -T chris_dev python manage.py test
elif [ -n "$INPUT_WHICH" ]; then
  docker-compose exec -T chris_dev python manage.py test --tag "$INPUT_WHICH"
else
  echo "Skipped"
fi
