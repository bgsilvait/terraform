#-------- Networking ------------

# ---- VPC ----

resource "aws_vpc" "VPC_Terraform" {
  cidr_block           = "${var.vpc_cidr}"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags {
    Name = "VPC_Terraform"
  }
}

# --- IGW ----

resource "aws_internet_gateway" "bgs_internet_gateway" {
  vpc_id = "${aws_vpc.VPC_Terraform.id}"

  tags {
    Name = "bgs_igw"
  }
}

# --- Nat Gtw

resource "aws_eip" "bgsnatgw" {
  count      = 1
  vpc        = true
  depends_on = ["aws_internet_gateway.bgs_internet_gateway"]
}

resource "aws_nat_gateway" "gw" {
  count         = 1
  subnet_id     = "${aws_subnet.bgs_subpbc1.id}"
  allocation_id = "${aws_eip.bgsnatgw.id}"
}

# --- RTs ---

resource "aws_route_table" "bgs_pbc_rt" {
  vpc_id = "${aws_vpc.VPC_Terraform.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.bgs_internet_gateway.id}"
  }

  tags {
    Name = "bgs_pbc"
  }
}

resource "aws_default_route_table" "bgs_pvt_rt" {
  default_route_table_id = "${aws_vpc.VPC_Terraform.default_route_table_id}"

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = "${aws_nat_gateway.gw.id}"
  }

  tags {
    Name = "bgs_pvt"
  }
}

# ---- Subnets ---
# Não esquecer da Fase 2 do Desafio!!!!!!!!

# ---- Public ---
resource "aws_subnet" "bgs_subpbc1" {
  vpc_id                  = "${aws_vpc.VPC_Terraform.id}"
  cidr_block              = "${var.cidrs["subpbc1"]}"
  map_public_ip_on_launch = true
  availability_zone       = "${data.aws_availability_zones.avaible.names[0]}"

  tags {
    Name = "bgs_subpbc1"
  }
}

resource "aws_subnet" "bgs_subpbc2" {
  vpc_id                  = "${aws_vpc.VPC_Terraform.id}"
  cidr_block              = "${var.cidrs["subpbc2"]}"
  map_public_ip_on_launch = true
  availability_zone       = "${data.aws_availability_zones.avaible.names[1]}"

  tags {
    Name = "bgs_subpbc2"
  }
}

# ---- Private ---

resource "aws_subnet" "bgs_subpvt1" {
  vpc_id                  = "${aws_vpc.VPC_Terraform.id}"
  cidr_block              = "${var.cidrs["subpvt1"]}"
  map_public_ip_on_launch = false
  availability_zone       = "${data.aws_availability_zones.avaible.names[0]}"

  tags {
    Name = "bgs_subpvt1"
  }
}

resource "aws_subnet" "bgs_subpvt2" {
  vpc_id                  = "${aws_vpc.VPC_Terraform.id}"
  cidr_block              = "${var.cidrs["subpvt2"]}"
  map_public_ip_on_launch = false
  availability_zone       = "${data.aws_availability_zones.avaible.names[1]}"

  tags {
    Name = "bgs_subpvt2"
  }
}

# --------- RT's Association

resource "aws_route_table_association" "bgs_subpbc1_acc" {
  subnet_id      = "${aws_subnet.bgs_subpbc1.id}"
  route_table_id = "${aws_route_table.bgs_pbc_rt.id}"
}

resource "aws_route_table_association" "bgs_subpbc2_acc" {
  subnet_id      = "${aws_subnet.bgs_subpbc2.id}"
  route_table_id = "${aws_route_table.bgs_pbc_rt.id}"
}

resource "aws_route_table_association" "bgs_subpvt1" {
  subnet_id      = "${aws_subnet.bgs_subpvt1.id}"
  route_table_id = "${aws_default_route_table.bgs_pvt_rt.id}"
}

resource "aws_route_table_association" "bgs_subpvt2" {
  subnet_id      = "${aws_subnet.bgs_subpvt2.id}"
  route_table_id = "${aws_default_route_table.bgs_pvt_rt.id}"
}

# --------- SG's

resource "aws_security_group" "bgs_wan_sg" {
  name        = "bgs_wan_sg"
  description = "Allow Wan access resources By Load Balancer"
  vpc_id      = "${aws_vpc.VPC_Terraform.id}"

  #HTTP

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "bgs_wanadm_sg" {
  name        = "bgs_wanadm_sg"
  description = "Allow Wan ADM access resources"
  vpc_id      = "${aws_vpc.VPC_Terraform.id}"

  #HTTP

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  #SSH

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
}

resource "aws_security_group" "bgs_lan_sg" {
  name        = "bgs_lan_sg"
  description = "Allow lan access "
  vpc_id      = "${aws_vpc.VPC_Terraform.id}"

  #HTTP

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = ["${aws_security_group.bgs_wan_sg.id}"]
    self            = true
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}