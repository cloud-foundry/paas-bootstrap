#!/bin/bash

set -euo pipefail

output() {
    FILE=$1
    QUERY=$2

    bin/outputs.sh $FILE | jq -r "$QUERY"
}

bosh int \
  bosh-deployment/bosh.yml \
  --vars-store data/$ENVIRONMENT-bosh-variables.yml \
  -o bosh-deployment/aws/cpi.yml \
  -o bosh-deployment/misc/external-db.yml \
  -o operations/bosh/tags.yml \
  -o operations/bosh/dns-resolution.yml \
  -o operations/bosh/certificate.yml \
  -v director_name=bosh \
  -v internal_cidr="$(output base .bosh_subnet_cidr_block)" \
  -v internal_gw="$(output base .bosh_gateway_ip)" \
  -v internal_ip="$(output base .bosh_private_ip)" \
  -v bosh_director_fqdn="$(output base .bosh_director_fqdn)" \
  -v private_dns_nameserver="$(output base .vpc_dns_nameserver)" \
  -v region="$(jq -r .region < data/$ENVIRONMENT.tfvars)" \
  -v bosh_iam_instance_profile="$(output base .bosh_iam_instance_profile)" \
  -v az="$(jq -r .availability_zones[0] < data/$ENVIRONMENT.tfvars)" \
  -v default_key_name="$(output base .bosh_key_name)" \
  -v default_security_groups="$(output base .bosh_security_group_ids)" \
  --var-file private_key=<(output base .bosh_private_key) \
  -v subnet_id="$(output base .bosh_subnet_id)" \
  -v environment="${ENVIRONMENT}" \
  -v external_db_host="$(output rds .bosh_rds_fqdn)" \
  -v external_db_port="$(output rds .bosh_db_port)" \
  -v external_db_user="$(output rds .bosh_db_username)" \
  -v external_db_password="$(output rds .bosh_rds_password)" \
  -v external_db_adapter="$(output rds .bosh_db_type)" \
  -v external_db_name='bosh' \
  -v access_key_id="$AWS_ACCESS_KEY_ID" \
  -v secret_access_key="$AWS_SECRET_ACCESS_KEY" \
  > data/$ENVIRONMENT-bosh-manifest.yml


JUMPBOX_IP=$(output base .jumpbox_public_ip)
JUMPBOX_KEY=~/.ssh/$ENVIRONMENT.jumpbox.$$.pem
output base .jumpbox_private_key >$JUMPBOX_KEY
chmod 600 $JUMPBOX_KEY

cleanup() {
    rm -f $JUMPBOX_KEY
}
trap cleanup EXIT

export BOSH_ALL_PROXY=ssh+socks5://ubuntu@$JUMPBOX_IP:22?private-key=$JUMPBOX_KEY

bosh create-env \
  data/$ENVIRONMENT-bosh-manifest.yml \
  --state data/$ENVIRONMENT-bosh-state.json