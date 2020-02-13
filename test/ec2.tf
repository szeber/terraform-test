resource "aws_launch_configuration" "instance" {
  image_id                    = data.aws_ami.latestUbuntuBionic.id
  instance_type               = "t2.micro"
  associate_public_ip_address = true
  name_prefix                 = "TerraformTest-instance"
  key_name                    = var.sshKeyName
  security_groups             = [
    aws_security_group.instance.id
  ]

  lifecycle {
    create_before_destroy = true
  }

  user_data_base64 = base64encode(
  <<EOF
#!/bin/bash -xe

apt-get update
apt-get upgrade -y
apt-get install -y nginx
rm -rf /var/www/html
mkdir -p /var/www/html
echo "<h1>Terraform test</h1>" > /var/www/html/index.html
echo "Served by <b>$(hostname)</b>" >> /var/www/html/index.html
service nginx restart
EOF
  )
}

resource "aws_autoscaling_group" "instance" {
  min_size             = 0
  max_size             = local.instanceCount
  desired_capacity     = local.instanceCount
  launch_configuration = aws_launch_configuration.instance.id
  name                 = "TerraformTest instance ASG"

  availability_zones  = data.aws_availability_zones.available.names
  vpc_zone_identifier = [for subnet in aws_subnet.instances: subnet.id]

  tag {
    key                 = "Name"
    value               = "TerraformTest instance ASG"
    propagate_at_launch = true
  }
}

resource "aws_security_group" "instance" {
  vpc_id = aws_vpc.test.id

  tags = {
    Name = "TerraformTest instance SG"
  }
}

resource "aws_security_group_rule" "instance-ingress-http" {
  security_group_id        = aws_security_group.instance.id
  type                     = "ingress"
  protocol                 = "TCP"
  from_port                = 80
  to_port                  = 80
  description              = "Allow only the LB to connect"
  source_security_group_id = aws_security_group.elb.id
}

resource "aws_security_group_rule" "instance-ingress-ssh" {
  security_group_id = aws_security_group.instance.id
  type              = "ingress"
  protocol          = "TCP"
  from_port         = 22
  to_port           = 22
  description       = "Allow SSH access from the admin IP"

  cidr_blocks = [
    "${var.sshAllowedIp}/32"
  ]
}

resource "aws_security_group_rule" "instance-egress-allowAll" {
  security_group_id = aws_security_group.instance.id
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  description       = "Allow all egress rule"

  cidr_blocks = [
    "0.0.0.0/0"
  ]
}

