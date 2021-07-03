#!/bin/bash -x

cd $STATE_cube_folder

docker stack rm pfcon_stack
docker-compose -f docker-compose_dev.yml down -v
docker network rm remote
docker swarm leave --force

cd -

# don't clean up if repo was there to begin with, i.e.
# it was cloned by actions/checkout@v2 which is going to want
# to clean up after itself
if [ -n "$STATE_should_cleanup" ]; then
  sudo rm -rf $STATE_cube_folder
fi
