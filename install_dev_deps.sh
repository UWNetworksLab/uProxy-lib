#!/bin/bash
set -e

# A simple bash script to run commands to setup and install all dev dependencies
# (including non-npm ones)
function runCmd ()
{
    echo "Running: $1"
    echo
    $1
}

function installDevDependencies ()
{
  runCmd "npm install"
  runCmd "tsd reinstall --config third_party/tsd.json"
}

installDevDependencies

echo
echo "Successfully completed install of dev dependencies."
