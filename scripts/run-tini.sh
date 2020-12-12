#!/bin/bash

# if `docker run` first argument start with `--` the user is passing launcher arguments
if [[ $# -lt 1 ]] || [[ "$1" == "--"* ]]; then
  exec \
    java $AEM_JVM_OPTS $AEM_RUNMODES \
    -jar $AEM_JARFILE \
    $AEM_START_OPTS \
    >>$AEM_STDOUT_LOG 2>&1 # redirect stdout and stderr to the file

fi

# if other params assume user want to run his own process, for example a `bash` shell to explore this image
exec "$@"
