resource "aws_key_pair" "new_key_pair" {
  key_name = "IAAC"
  public_key = file("~/.ssh/id_rsa.pub")
}

resource "aws_vpc" "new_vpc" {
  tags = {
    Name = "vpc_1"
  }
  cidr_block = var.cidr
}

resource "aws_subnet" "new_subnet" {
  tags = {
    Name = "subnet_1"
  }
  vpc_id = aws_vpc.new_vpc.id
  availability_zone = "ap-south-1a"
  cidr_block = "10.0.0.0/24"
  map_public_ip_on_launch = true
}

resource "aws_internet_gateway" "new_gateway" {
  tags = {
    Name = "internet_gateway_1"
  }
  vpc_id = aws_vpc.new_vpc.id
}

resource "aws_route_table" "new_rt" {
  vpc_id = aws_vpc.new_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.new_gateway.id
  }
}

resource "aws_route_table_association" "new_rta" {
  subnet_id = aws_subnet.new_subnet.id
  route_table_id = aws_route_table.new_rt.id
}

resource "aws_security_group" "new_sg" {
  vpc_id = aws_vpc.new_vpc.id
  name = "new_security_group"
  
  ingress = [
    {
        description = "HTTP from VPC"
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
        ipv6_cidr_blocks = []
        prefix_list_ids = []
        security_groups = []
        self = false
    },
    {
        description = "SSH from VPC"
        from_port  = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
        ipv6_cidr_blocks = []
        prefix_list_ids = []
        security_groups = []
        self = false
    },
    {
        description = "SonarQube"
        from_port = 9000
        to_port = 9000
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
        ipv6_cidr_blocks = []
        prefix_list_ids = []
        security_groups = []
        self = false
    }
    ]

    egress = {
        description = "outbounds"
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
        ipv6_cidr_blocks = []
        prefix_list_ids = []
        security_groups = []
        self = false
    }
}

resource "aws_instance" "new_instance" {
  tags = {
    Name = "Instance_1"
  }
  ami = "ami-0a5ac53f63249fba0"
  instance_type = var.instance_type
  key_name = aws_key_pair.new_key_pair.key_name
  subnet_id = aws_subnet.new_subnet.id
  vpc_security_group_ids = [aws_security_group.new_sg.id]
}
