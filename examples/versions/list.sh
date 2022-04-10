#!/usr/bin/env bash
set -eou pipefail

go version
cue version
dagger version
hof version

set +e
ls /localcue
exit 0
