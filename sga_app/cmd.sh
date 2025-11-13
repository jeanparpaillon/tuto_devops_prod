#!/bin/sh

if [ -z "$WORLD_FILE" ]; then
  WORLD="world"
fi

find / -name "$WORLD_FILE" 

WORLD=$(cat $WORLD_FILE)

echo "Hello $WORLD"

java -jar /opt/app/app.jar