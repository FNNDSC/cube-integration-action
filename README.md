# Github Action for ChRIS Integration Tests

Use this _Github Action_ to run CUBE integration tests against a
CUBE satelite service (pfcon, pman, pfioh).

## Description

Provisions a local development environment for CUBE and then runs integration tests.

## Steps

In a prior step, build your container image with the tag `fnndsc/p*`, i.e. one which appears in
[ChRIS_ultron_backEnd/docker-compose_dev.yml](https://github.com/FNNDSC/ChRIS_ultron_backEnd/blob/master/docker-compose_dev.yml).

## Example

```yaml
name: CI

on:
  push:
    branches: [ master ]
  pull_request:
    branches: [ master ]

jobs:
  test:
    runs-on: ubuntu-20.04
    steps:
      - uses: actions/checkout@v2
      - run: docker build -t fnndsc/pfcon .
      - uses: FNNDSC/cube-integration-action@v2
```
