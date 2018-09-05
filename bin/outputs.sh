#!/bin/bash

set -euo pipefail

: $ENVIRONMENT

STEP=${1:-base}

terraform output -state="data/$ENVIRONMENT-$STEP.tfstate" -json | jq '. | with_entries(.value = .value.value)'