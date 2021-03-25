#!/bin/bash -xe

MY_DIR=$(dirname $(readlink --canonicalize $BASH_SOURCE))
${MY_DIR}/build_all.sh
