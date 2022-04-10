#!/usr/bin/env bash
set -eou pipefail

go version
cue version
dagger version
hof version

tree -d /work/cue.mod

set +e
ls /localcue
exit 0
