locals {
  // Which region to use
  awsRegion            = "ap-southeast-2"

  // The CIDR for the VPC network
  vpcCidr              = "10.0.0.0/16"

  // How many extra bits to add to the netmask of each subnet
  subnetExtraBits      = 8

  // Maximum number of AZs to support to avoid overlaping network ranges
  maxAzCount           = 4

  // How many instances to create
  instanceCount        = 3
}
