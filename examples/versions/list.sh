#!/usr/bin/env bash

go version
cue version
dagger version
hof version
python3 --version

tree -d /work/cue.mod

set +e
ls /localcue
exit 0
