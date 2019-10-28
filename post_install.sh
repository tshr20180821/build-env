#!/bin/bash

set -x

date

chmod +x ./start_web.sh

pushd build_scripts
chmod +x ./${BUILD_SCRIPT_NAME}.sh
./${BUILD_SCRIPT_NAME}.sh
popd

date
