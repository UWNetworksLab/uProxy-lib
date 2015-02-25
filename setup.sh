#!/bin/bash

# Make sure an error in this script stops it running where the error happened.
set -e

# Get the directory where this script is and set ROOT_DIR to that path. This
# allows script to be run from different directories but always act on the
# directory it is within.
ROOT_DIR="$(cd "$(dirname $0)"; pwd)";

# A simple bash script to run commands to setup and install all dev dependencies
# (including non-npm ones)
function runCmd ()
{
    echo "Running: $1"
    echo
    $1
}

function buildTools ()
{
  runCmd "mkdir -p build/dev/uproxy-lib/build-tools/"
  runCmd "ln -s $ROOT_DIR/src/build-tools/*.ts build/dev/uproxy-lib/build-tools/" || true
  runCmd "./node_modules/.bin/tsc --module commonjs ./build/dev/uproxy-lib/build-tools/*.ts"
  runCmd "mkdir -p ./build/tools/"
  runCmd "cp ./build/dev/uproxy-lib/build-tools/*.js ./build/tools/"
}

function clean ()
{
  runCmd "rm -r cd $ROOT_DIR/node_modules cd $ROOT_DIR/build cd $ROOT_DIR/.tscache"
}

function installDevDependencies ()
{
  runCmd "cd $ROOT_DIR"
  runCmd "npm install"
  runCmd "node_modules/.bin/tsd reinstall --config ./third_party/tsd.json"
  buildTools
}

if [ "$1" == 'install' ]; then
  installDevDependencies
elif [ "$1" == 'tools' ]; then
  buildTools
elif [ "$1" == 'clean' ]; then
  clean
else
  echo "Usage: setup.sh [install|tools|clean]"
  echo "  install       Installs needed development dependencies into build/"
  echo "  tools         Builds just the tools into build/tools"
  echo "  clean         Removes all dependencies installed by this script."
  echo
  echo ""
  exit 0
fi
