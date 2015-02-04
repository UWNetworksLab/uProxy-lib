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
  runCmd "node_modules/.bin/tsc --module commonjs --outDir build/tools/ src/build-tools/taskmanager.ts"
  runCmd "node_modules/.bin/tsc --module commonjs --outDir build/tools/ src/build-tools/common-grunt-rules.ts"
}

function installDevDependencies ()
{
  runCmd "cd $ROOT_DIR"
  runCmd "npm install"
  runCmd "node_modules/.bin/tsd reinstall --config ./third_party/tsd.json"
  buildTools
}

if [ "$1" == 'tools' ]; then
  buildTools
else
  installDevDependencies
fi

echo
echo "Successfully completed install of dev dependencies."
