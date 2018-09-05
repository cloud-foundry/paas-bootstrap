locals {
  account_id = "${data.aws_caller_identity.current.account_id}"
  num_azs = "${length(var.availability_zones)}"
  public_subnets = "${var.cidr_blocks["public"]}"
  internal_subnets = "${var.cidr_blocks["internal"]}"
  services_subnets = "${var.cidr_blocks["services"]}"
  rds_subnets = "${var.cidr_blocks["rds"]}"

  bosh_subnet_id = "${aws_subnet.public.*.id[var.bosh_availability_zone_index]}"

  bosh_subnet_cidr_block = "${aws_subnet.public.*.cidr_block[var.bosh_availability_zone_index]}"
  bosh_private_ip = "${cidrhost(aws_subnet.public.*.cidr_block[var.bosh_availability_zone_index], 6)}"
  bosh_gateway_ip = "${cidrhost(aws_subnet.public.*.cidr_block[var.bosh_availability_zone_index], 1)}"
}