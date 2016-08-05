variable "cidr" {
  description = "the CIDR block to provision for the VPC, if set to something other than the default, both internal_subnets and external_subnets have to be defined as well"
  default     = "10.30.0.0/16"
}

variable "internal_subnets" {
  description = "a comma-separated list of CIDRs for internal subnets in your VPC, must be set if the cidr variable is defined, needs to have as many elements as there are availability zones"
  default     = "10.30.0.0/19,10.30.64.0/19,10.30.128.0/19"
}

variable "external_subnets" {
  description = "a comma-separated list of CIDRs for external subnets in your VPC, must be set if the cidr variable is defined, needs to have as many elements as there are availability zones"
  default     = "10.30.32.0/20"
  //default     = "10.30.32.0/20,10.30.96.0/20,10.30.160.0/20"
}

variable "environment" {
  description = "Environment tag, e.g prod"
  default = "dev"
}

variable "availability_zones" {
  description = "Comma separated list of availability zones"
  default = "us-east-1a"
 // default = "us-east-1a,us-east-1c,us-east-1d"
}

variable "name" {
  description = "Name tag, e.g pango"
  default     = "pango"
}

# Configure the AWS Provider
provider aws {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region = "${var.region}"
}

/**
* VPC
*/
resource "aws_vpc" "main" {
  enable_dns_hostnames = true
  enable_dns_support = true
  cidr_block = "${var.cidr}"

  tags{
    Name = "${var.name}"
  }
}

/**
 * Gateways
 */

resource "aws_internet_gateway" "main" {
  vpc_id = "${aws_vpc.main.id}"

  tags {
    Name        = "${var.name}"
    Environment = "${var.environment}"
  }
}



/**
* You can now use Network Address Translation (NAT) Gateway,
* that makes it easy to connect to the Internet from instances within a private subnet in an AWS Virtual Private Cloud (VPC).
 *Previously, you needed to launch a NAT instance to enable NAT for instances in a private subnet.
*/

// Commented out all Internals for Dev

//resource "aws_nat_gateway" "main" {
//  count         = "${length(compact(split(",", var.internal_subnets)))}"
//  allocation_id = "${element(aws_eip.nat.*.id, count.index)}"
//  subnet_id     = "${element(aws_subnet.external.*.id, count.index)}"
//  depends_on    = ["aws_internet_gateway.main"]
//}
//
//resource "aws_eip" "nat" {
//  count = "${length(compact(split(",", var.internal_subnets)))}"
//  vpc   = true
//}


/**
 * Subnets.
 */

//resource "aws_subnet" "internal" {
//  vpc_id            = "${aws_vpc.main.id}"
//  cidr_block        = "${element(split(",", var.internal_subnets), count.index)}"
//  availability_zone = "${element(split(",", var.availability_zones), count.index)}"
//  count             = "${length(compact(split(",", var.internal_subnets)))}"
//
//  tags {
//    Name = "${var.name}-${format("internal-%03d", count.index+1)}"
//  }
//}

resource "aws_subnet" "external" {
  vpc_id                  = "${aws_vpc.main.id}"
  cidr_block              = "${element(split(",", var.external_subnets), count.index)}"
  availability_zone       = "${element(split(",", var.availability_zones), count.index)}"
  count                   = "${length(compact(split(",", var.external_subnets)))}"
  map_public_ip_on_launch = true

  tags {
    Name = "${var.name}-${format("external-%03d", count.index+1)}"
  }
}

/**
 * Route tables
 */

resource "aws_route_table" "external" {
  vpc_id = "${aws_vpc.main.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.main.id}"
  }

  tags {
    Name = "${var.name}-external-001"
  }
}

//resource "aws_route_table" "internal" {
//  count  = "${length(compact(split(",", var.internal_subnets)))}"
//  vpc_id = "${aws_vpc.main.id}"
//
//  route {
//    cidr_block     = "0.0.0.0/0"
//    nat_gateway_id = "${element(aws_nat_gateway.main.*.id, count.index)}"
//  }
//
//  tags {
//    Name = "${var.name}-${format("internal-%03d", count.index+1)}"
//  }
//}

/**
 * Route associations
 */

//resource "aws_route_table_association" "internal" {
//  count          = "${length(compact(split(",", var.internal_subnets)))}"
//  subnet_id      = "${element(aws_subnet.internal.*.id, count.index)}"
//  route_table_id = "${element(aws_route_table.internal.*.id, count.index)}"
//}

resource "aws_route_table_association" "external" {
  count          = "${length(compact(split(",", var.external_subnets)))}"
  subnet_id      = "${element(aws_subnet.external.*.id, count.index)}"
  route_table_id = "${aws_route_table.external.id}"
}


/**
*
* Security Groups
*/



resource "aws_security_group" "external_ssh" {
  name        = "${format("%s-%s-external-ssh", var.name, var.environment)}"
  description = "Allows ssh from the world"
  vpc_id      = "${var.vpc_id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  lifecycle {
    create_before_destroy = true
  }

  tags {
    Name        = "${format("%s external ssh", var.name)}"
    Environment = "${var.environment}"
  }
}

//resource "aws_security_group" "internal_ssh" {
//  name        = "${format("%s-%s-internal-ssh", var.name, var.environment)}"
//  description = "Allows ssh from bastion"
//  vpc_id      = "${var.vpc_id}"
//
//  ingress {
//    from_port       = 22
//    to_port         = 22
//    protocol        = "tcp"
//    security_groups = ["${aws_security_group.external_ssh.id}"]
//  }
//
//  egress {
//    from_port   = 0
//    to_port     = 0
//    protocol    = "tcp"
//    cidr_blocks = ["${var.cidr}"]
//  }
//
//  lifecycle {
//    create_before_destroy = true
//  }
//
//  tags {
//    Name        = "${format("%s internal ssh", var.name)}"
//    Environment = "${var.environment}"
//  }
//}

/**
** Bastion
*/
module "bastion" {
  source          = "../bastion"
  region          = "${var.region}"
  instance_type   = "${var.bastion_instance_type}"
  security_groups = "${aws_security_group.external_ssh.id}" //Comma separted external and interanl
  vpc_id          = "${aws_vpc.main.id}"
  subnet_id       = "${element(split(",",aws_subnet.external.*.id), 0)}"
  key_name        = "${var.key_pair_name}"
  environment     = "${var.environment}"
}


/**
 * Outputs
 */


// The VPC ID
output "id" {
  value = "${aws_vpc.main.id}"
}

// A comma-separated list of subnet IDs.
output "external_subnets" {
  value = "${join(",", aws_subnet.external.*.id)}"
}

// A comma-separated list of subnet IDs.
//output "internal_subnets" {
//  value = "${join(",", aws_subnet.internal.*.id)}"
//}

// The default VPC security group ID.
output "security_group" {
  value = "${aws_vpc.main.default_security_group_id}"
}

// The list of availability zones of the VPC.
output "availability_zones" {
  value = "${join(",", aws_subnet.external.*.availability_zone)}"
}

// External SSH allows ssh connections on port 22 from the world.
output "external_ssh" {
  value = "${aws_security_group.external_ssh.id}"
}

// Internal SSH allows ssh connections from the external ssh security group.
//output "internal_ssh" {
//  value = "${aws_security_group.internal_ssh.id}"
//}

// The bastion host IP.
output "bastion_ip" {
  value = "${module.bastion.external_ip}"
}