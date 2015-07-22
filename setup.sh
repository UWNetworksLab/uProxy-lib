#!/bin/bash

# Get the directory where this script is and set ROOT_DIR to that path. This
# allows script to be run from different directories but always act on the
# directory it is within.
ROOT_DIR="$(cd "$(dirname $0)"; pwd)";
NPM_BIN_DIR="$ROOT_DIR/node_modules/.bin"

# A simple bash script to run commands to setup and install all dev dependencies
# (including non-npm ones)
function runAndAssertCmd ()
{
    echo "Running: $1"
    echo
    # We use set -e to make sure this will fail if the command returns an error
    # code.
    set -e && cd $ROOT_DIR && eval $1
}

# Just run the command, ignore errors (e.g. cp fails if a file already exists
# with "set -e")
function runCmd ()
{
    echo "Running: $1"
    echo
    cd $ROOT_DIR && eval $1
}

function buildTools ()
{
  runCmd "mkdir -p build/dev/uproxy-lib/build-tools/"
  runCmd "cp src/build-tools/*.ts build/dev/uproxy-lib/build-tools/"
  runAndAssertCmd "$NPM_BIN_DIR/tsc --module commonjs --noImplicitAny ./build/dev/uproxy-lib/build-tools/*.ts"
  runCmd "mkdir -p ./build/tools/"
  runCmd "cp build/dev/uproxy-lib/build-tools/*.js build/tools/"
}

function thirdParty ()
{
  runAndAssertCmd "$NPM_BIN_DIR/bower install --allow-root --config.interactive=false"
  runAndAssertCmd "mkdir -p build/third_party"
  runAndAssertCmd "$NPM_BIN_DIR/tsd reinstall --config ./third_party/tsd.json"
  runAndAssertCmd "cp -r third_party/* build/third_party/"
  runAndAssertCmd "mkdir -p build/third_party/freedom-pgp-e2e"
  runAndAssertCmd "cp -r node_modules/freedom-pgp-e2e/dist build/third_party/freedom-pgp-e2e/"
  runAndAssertCmd "mkdir -p build/third_party/freedom-port-control"
  runAndAssertCmd "cp -r node_modules/freedom-port-control/dist build/third_party/freedom-port-control/"
}

function clean ()
{
  runCmd "rm -r $ROOT_DIR/node_modules $ROOT_DIR/build $ROOT_DIR/.tscache"
}

function installDevDependencies ()
{
  runAndAssertCmd "npm install"
  thirdParty
  buildTools
}

if [ "$1" == 'install' ]; then
  installDevDependencies
elif [ "$1" == 'third_party' ]; then
  thirdParty
elif [ "$1" == 'tools' ]; then
  buildTools
elif [ "$1" == 'clean' ]; then
  clean
else
  echo
  echo "Usage: setup.sh [install|third_party|tools|clean]"
  echo
  echo "  install      - Runs npm install and creates all needed files to build"
  echo "                 with grunt"
  echo "  third_party  - Installs all the files for 'build/third_party' needed"
  echo "                 by our grunt build rules (This is part of the "
  echo "                 'setup.sh install' process)"
  echo "  tools        - Builds just the tools into build/tools (This part of "
  echo "                 the 'setup.sh install' process)"
  echo "  clean        - Removes all dependencies installed by this script."
  echo
  exit 0
fi
