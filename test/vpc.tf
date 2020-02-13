resource "aws_vpc" "test" {
  cidr_block           = local.vpcCidr
  enable_dns_hostnames = true

  tags = {
    Name = "TerraformTest"
  }
}

// Subnets for EC2 instances
resource "aws_subnet" "instances" {
  // Make sure that we don't exceed the maximum number of AZs here as we don't want to overlap with subnets for managed resources
  count = min(length(data.aws_availability_zones.available.names), local.maxAzCount)

  availability_zone = data.aws_availability_zones.available.names[count.index]
  cidr_block        = cidrsubnet(local.vpcCidr, local.subnetExtraBits, count.index)
  vpc_id            = aws_vpc.test.id

  tags = {
    Name = "TerraformTest-instance-${data.aws_availability_zones.available.names[count.index]}"
  }
}

// Subnets for any managed resources, say ELB, RDS, ElastiCache, etc.
resource "aws_subnet" "managedResources" {
  // Make sure that we don't exceed the maximum number of AZs here as we don't want to overlap with subnets for managed resources
  count = min(length(data.aws_availability_zones.available.names), local.maxAzCount)

  availability_zone = data.aws_availability_zones.available.names[count.index]
  cidr_block        = cidrsubnet(local.vpcCidr, local.subnetExtraBits, count.index + local.maxAzCount)
  vpc_id            = aws_vpc.test.id

  tags = {
    Name = "TerraformTest-managed-${data.aws_availability_zones.available.names[count.index]}"
  }
}

resource "aws_internet_gateway" "test" {
  vpc_id = aws_vpc.test.id

  tags = {
    Name = "TerraformTest"
  }
}

resource "aws_route_table" "test" {
  vpc_id = aws_vpc.test.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.test.id
  }

  tags = {
    Name = "TerraformTest"
  }
}

resource "aws_route_table_association" "cluster" {
  count = length(data.aws_availability_zones.available.names)

  subnet_id      = aws_subnet.instances.*.id[count.index]
  route_table_id = aws_route_table.test.id
}

resource "aws_route_table_association" "resources" {
  count = length(data.aws_availability_zones.available.names)

  subnet_id      = aws_subnet.managedResources.*.id[count.index]
  route_table_id = aws_route_table.test.id
}
