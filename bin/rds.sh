#!/bin/bash

set -euo pipefail

: $ENVIRONMENT

COMMAND=${1:-plan}
OPTS=
[ "$COMMAND" = plan ] || OPTS=-auto-approve

terraform init terraform/rds

terraform $COMMAND \
  $OPTS \
  -var-file="data/$ENVIRONMENT.tfvars" \
  -var-file=<(bin/outputs.sh) \
  -state="data/$ENVIRONMENT-rds.tfstate" terraform/rds/