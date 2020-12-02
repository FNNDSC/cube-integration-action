#!/bin/bash -x

cd $STATE_cube_folder

docker-compose -f docker-compose_dev.yml down -v
docker swarm leave --force

cd -
sudo rm -rf $STATE_cube_folder
