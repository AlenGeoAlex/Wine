#!/bin/sh
MAIN_JS="dist/apps/wine-server/src/main.js"
COMMAND_JS="dist/apps/wine-server/src/command.js"

if [ "$#" -eq 0 ]; then
  echo "Starting server..."
  exec node ${MAIN_JS}
else
  echo "Executing command: $@"
  exec node ${COMMAND_JS} "$@"
fi