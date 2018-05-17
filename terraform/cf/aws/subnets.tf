resource "aws_subnet" "az1" {
  vpc_id            = "${var.vpc_id}"
  cidr_block        = "10.0.4.0/24"
  availability_zone = "${var.az1}"

  tags {
    Name        = "${var.environment}-cf-az1-subnet"
    Environment = "${var.environment}"
  }
}

resource "aws_subnet" "az2" {
  vpc_id            = "${var.vpc_id}"
  cidr_block        = "10.0.5.0/24"
  availability_zone = "${var.az2}"

  tags {
    Name        = "${var.environment}-cf-az2-subnet"
    Environment = "${var.environment}"
  }
}

resource "aws_subnet" "az3" {
  vpc_id            = "${var.vpc_id}"
  cidr_block        = "10.0.6.0/24"
  availability_zone = "${var.az3}"

  tags {
    Name        = "${var.environment}-cf-az3-subnet"
    Environment = "${var.environment}"
  }
}
