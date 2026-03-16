#!/bin/bash

set -e

test -f "$1" || (date -u "+%Y-%m-%d %T.%N" > "$1")
