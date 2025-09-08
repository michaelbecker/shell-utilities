#!/bin/bash

if [ -z "$1" ]; then
    echo "What do I trim?"
    exit 1
fi

sed -i 's/[[:space:]]\+$//' $1

