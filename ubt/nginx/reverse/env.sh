#!/bin/sh

export DRONE_TAG_SERVER="0.8.9"
export DRONE_TAG_AGENT="0.8.9"
export DRONE_ROOT="/opt/cicd/drone"
export DRONE_DATAS="${DRONE_ROOT}/datas"

# drone server
export DRONE_HOST="https://doryhub.com"
export DRONE_GITHUB_CLIENT="doryhub"
export DRONE_GITHUB_SECRET="doryhubpwd"
export DRONE_SECRET="drone"

