resource "aws_vpc" "arda_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "${var.env_prefix}-vpc"
  }
}

resource "aws_subnet" "arda_subnet" {
  vpc_id            = aws_vpc.arda_vpc.id
  cidr_block        = var.subnet_cidr_block
  availability_zone = var.avail_zone

  tags = {
    Name = "${var.env_prefix}-subnet-subnet-1"
  }
}

# resource "aws_route_table" "arda_route_table" {
#   vpc_id = aws_vpc.arda_vpc.id

#   route {
#     cidr_block = "0.0.0.0/0"
#     gateway_id = aws_internet_gateway.arda_igw.id
#   }
# }

resource "aws_default_route_table" "main-rtb" {
  default_route_table_id = aws_vpc.arda_vpc.default_route_table_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.arda_igw.id
  }
  tags = {
    Name = "${var.env_prefix}-main-rtb"
  }
}
resource "aws_internet_gateway" "arda_igw" {
  vpc_id = aws_vpc.arda_vpc.id

  tags = {
    Name = "${var.env_prefix}-subnet-subnet-1"
  }
}

# resource "aws_route_table_association" "arda_rt_associate" {
#   subnet_id      = aws_subnet.arda_subnet.id
#   route_table_id = aws_route_table.arda_route_table.id
# }
# resource "aws_security_group" "terraform-sg" {
#   name        = "iac-sg"
#   description = "iac-sg-http-https-ssh"
#   vpc_id      = aws_vpc.arda_vpc.id

resource "aws_default_security_group" "default-sg" {
  vpc_id = aws_vpc.arda_vpc.id


  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "custom-8080"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH"
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

  # tags = {
  #   Name = "${var.env_prefix}-sg-arda-demo1"
  # }

  tags = {
    Name : "${var.env_prefix}-default-sg"
  }

}

# resource "aws_key_pair" "terraformkey" {
#   key_name   = "tfkey"
#   public_key = file("C:\\Users\\Arda\\.ssh\\tfkey.pub")
# }

# data "aws_ami" "most_recent_ubuntu" {
#   most_recent = true
#   owners      = ["099720109477"]

#   filter {
#     name   = "name"
#     values = ["ubuntu/images/hvm-ssd/ubuntu-focal*22.04*"]
#   }

#   filter {
#     name   = "root-device-type"
#     values = ["ebs"]
#   }

#   filter {
#     name   = "virtualization-type"
#     values = ["hvm"]
#   }
# }

# output "aws_ami_id" {
#   value = data.aws_ami.most_recent_ubuntu.id
# }

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-20230919"]
  }
 }


resource "aws_instance" "web" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t2.micro"
  key_name                    = var.my_private_key
  associate_public_ip_address = true
  availability_zone           = var.avail_zone
  subnet_id                   = aws_subnet.arda_subnet.id
  user_data                   = file("userdata")
  # Run a script after apply
  provisioner "local-exec" {
    command = "echo ${self.public_ip} ${data.aws_ami.ubuntu.id} >output.txt"
    }

  tags = {
    Name = "${var.env_prefix}-IAC-Instance"
  }

}


