resource "aws_vpc" "new_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  tags = {
    Name = "alt_vpc"
  }
}

# resource "aws_subnet" "req_subnets" {
#   count = 2

#   cidr_block = "10.0.${count.index + 1}.0/24"
#   vpc_id     = aws_vpc.new_vpc.id

#   tags = {
#     Name = "req_subnets_${count.index + 1}"
#   }
# }

resource "aws_subnet" "subnet1" {
  vpc_id                  = aws_vpc.new_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1a"

  tags = {
    Name = "subnet1"
  }
}
resource "aws_subnet" "subnet2" {
  vpc_id                  = aws_vpc.new_vpc.id
  cidr_block              = "10.0.2.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1b"
  tags = {
    Name = "subnet2"
  }
}

resource "aws_internet_gateway" "new_igw" {
  vpc_id = aws_vpc.new_vpc.id
  tags = {
    Name = "new_igw"
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.new_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.new_igw.id
  }
  tags = {
    Name = "public_rt"
  }
}

resource "aws_route_table_association" "public_rta_1" {
  subnet_id      = aws_subnet.subnet1.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public_rta_2" {
  subnet_id      = aws_subnet.subnet2.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_network_acl" "a_nacl" {
  vpc_id     = aws_vpc.new_vpc.id
  subnet_ids = [aws_subnet.subnet1.id, aws_subnet.subnet2.id]
  egress {
    protocol   = -1
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }
  ingress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }
  tags = {
    Name = "a_nacl"
  }
}

resource "aws_security_group" "new_sg_lb" {
  name        = "new_sg_lb"
  description = "Security group for the load balancer"
  vpc_id      = aws_vpc.new_vpc.id
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }
  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "new_sg_instance" {
  name        = "new_sg_instance"
  description = "Allow SSH, HTTP and HTTPS inbound traffic for private instances"
  vpc_id      = aws_vpc.new_vpc.id
  ingress {
    description     = "HTTP"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    cidr_blocks     = ["0.0.0.0/0"]
    security_groups = [aws_security_group.new_sg_lb.id]
  }
  ingress {
    description     = "HTTPS"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    cidr_blocks     = ["0.0.0.0/0"]
    security_groups = [aws_security_group.new_sg_lb.id]
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
  tags = {
    Name = "new_sg_instance"
  }
}

#  resource "aws_instance" "instances" {
#   ami           = "ami-0ff8a91507f77f867"
#   instance_type = "t2.micro"
#     subnet_id = aws_subnet.alt_subnet.id

#     vpc_security_group_ids = [aws_security_group.new_sg.id]

#   tags = {
#     Name = "instance_1"
# }
#create 2 more instances with for_each
#   for_each = {
#      "instance_1" = "ami-0778521d914d23bc1"
#      "instance_2" = "ami-0778521d914d23bc1"
#      "instance_3" = "ami-0778521d914d23bc1"
#    }
#    ami = each.value
#    instance_type = "t2.micro"
#    tags = {
#      Name = each.key
#    }
#  }
# resource "aws_instance" "instances" {
#   count                  = 3
#   ami                    = "ami-0778521d914d23bc1"
#   instance_type          = "t2.micro"
#   key_name               = "alt"
#   security_groups        = [aws_security_group.new_sg_instance.id]
#   subnet_id              = aws_subnet.subnet1.id
#   vpc_security_group_ids = [aws_security_group.new_sg_instance.id]
#   availability_zone      = "us-east-1a"
#   # for_each = toset(range(3)) 
#   tags = {
#     Name   = "instance_${count.index + 1}"
#     source = "terraform"
#     # subnet_id = aws_subnet.subnet2.id
#     availability_zone = "us-east-1b"
#   }
# }

resource "aws_instance" "instance_1" {
  ami             = "ami-0778521d914d23bc1"
  instance_type   = "t2.micro"
  key_name        = "alt"
  security_groups = [aws_security_group.new_sg_instance.id]
  subnet_id       = aws_subnet.subnet1.id
  availability_zone = "us-east-1a"
  tags = {
    Name   = "instance_1"
    source = "terraform"
  }
}
# creating instance 2
 resource "aws_instance" "instance_2" {
  ami             = "ami-0778521d914d23bc1"
  instance_type   = "t2.micro"
  key_name        = "alt"
  security_groups = [aws_security_group.new_sg_instance.id]
  subnet_id       = aws_subnet.subnet1.id
  availability_zone = "us-east-1a"
  tags = {
    Name   = "instance_2"
    source = "terraform"
  }
}
# creating instance 3
resource "aws_instance" "instance_3" {
  ami             = "ami-0778521d914d23bc1"
  instance_type   = "t2.micro"
  key_name        = "alt"
  security_groups = [aws_security_group.new_sg_instance.id]
  subnet_id       = aws_subnet.subnet2.id
  availability_zone = "us-east-1b"
  tags = {
    Name   = "instance_3"
    source = "terraform"
  }
}

resource "local_file" "inventory" {
  filename = "/mnt/c/Users/AVOSE PEACE/Desktop/terraform/inventory"
  content  = <<EOT
${aws_instance.instance_1.public_ip}
${aws_instance.instance_2.public_ip}
${aws_instance.instance_3.public_ip}
  EOT
}

resource "aws_lb" "elb" {
  name                       = "elb"
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = [aws_security_group.new_sg_lb.id]
  subnets                    = [aws_subnet.subnet1.id, aws_subnet.subnet2.id]
  enable_deletion_protection = false
  depends_on                 = [aws_instance.instance_1, aws_instance.instance_2, aws_instance.instance_3]
}

resource "aws_lb_target_group" "new_tg" {
  name        = "new-tg"
  target_type = "instance"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.new_vpc.id
  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 15
    timeout             = 3
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }
}

resource "aws_lb_listener" "elb_listener" {
  load_balancer_arn = aws_lb.elb.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.new_tg.arn
  }
}
# Create the listener rule
resource "aws_lb_listener_rule" "elb_listener_rule" {
  listener_arn = aws_lb_listener.elb_listener.arn
  priority     = 1
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.new_tg.arn
  }
  condition {
    path_pattern {
      values = ["/"]
    }
  }
}


resource "aws_lb_target_group_attachment" "elb_tg_attachment_1" {
  target_group_arn = aws_lb_target_group.new_tg.arn
  target_id        = aws_instance.instance_1.id
  port             = 80
}
resource "aws_lb_target_group_attachment" "elb_tg_attachment_2" {
  target_group_arn = aws_lb_target_group.new_tg.arn
  target_id        = aws_instance.instance_2.id
  port             = 80
}
resource "aws_lb_target_group_attachment" "elb_tg_attachment_3" {
  target_group_arn = aws_lb_target_group.new_tg.arn
  target_id        = aws_instance.instance_3.id
  port             = 80
}

#Route 53
variable "domain" {
  default     = "Ekoyon.me"
  type        = string
  description = "My Domain Name"
}

# get hosted zone details
resource "aws_route53_zone" "hosting_zone" {
  name = var.domain
  tags = {
    Environment = "production"
  }
}
# create a record set in route 53

# terraform aws route 53 record
resource "aws_route53_record" "my_domain" {
  zone_id = aws_route53_zone.hosting_zone.zone_id
  name    = "terraform-config.${var.domain}"
  type    = "A"
  alias {
    name                   = aws_lb.elb.dns_name
    zone_id                = aws_lb.elb.zone_id
    evaluate_target_health = true
  }
}