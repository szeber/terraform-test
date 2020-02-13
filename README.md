# Terraform test

## Applying the manifest

To run this project and set up the test infrastructure do the following steps:

* clone this repository 
* cd into the `test` directory 
* copy the `terraform.tfvars.example` file to `terraform.tfvars` and fill in the variables
* run `terraform init` to initialise the .terraform directory
* run `terraform plan` to see the execution plan
* run `terraform apply` to apply the manifest

## Changing configuration values

All user configurable values are stored in the `locals.tf` file. By default we use `ap-southeast-2` (Sydney) for the 
deployment. The VPC uses the `10.0.0.0/16` range, and 8 extra bits for the subnets (`10.x.0.0/24`). We limit the number 
of used availability zones to 4 by default. The infrastructure contains 3 web servers behind the load balancer.

## Infrastructure

### Networking

All availability zones in the specified region (up to the max defined in `maxAzCount`) will be utilised for failover. 

Each region will have 2 subnets:
* an instance subnet for non managed instances
* a managed service subnet (usable for ELBs, RDS instances, etc)

All subnets are associated with the route table, which routes all internet traffic through an internet gateway.


### Load balancer

A single HTTP application load balancer is configured, which uses the managed service subnets in all utilised AZs. The 
target group targets port 80 on all instances in the autoscaling group. Though using HTTPS would be easy enough, this 
was not added because of the additional complexity setting up certificates, DNS addresses, etc.

There is a security group associated with the load balancer, which allows ingress traffic to port 80, and allows all 
egress traffic. In a production environment it would be worth to limit the egress traffic as well.

### Autoscale group

A launch configuration is set up that is used by a single autoscale group. The ASG is associated with all instance 
subnets for fault tolerance. There is a security group associated with the ASG instances, which only allows ingress 
traffic to port 80 from the load balancers, SSH traffic from the specified admin IP, and all egress traffic. As with the 
LB in production it would be worthwhile to limit the egress traffic as well.

For setting up the ASGs a pre-existing SSH keypair must be configured in the used region, and it's name must be set as 
a variable. This SSH key will be allowed to connect to all created instances.

The instances are configured via user data and the page will contain the hostname of the instance fulfilling the request.

## Accessing the website after applying the manifest

The manifest will output the FQDN for the website in the following form: 
`elbFqdn = TerraformTest-1693079202.ap-southeast-2.elb.amazonaws.com`. To access the website, just visit 
`http://<elbFqdn>`. Refreshing the page should display a different server hostname on page refreshes (assuming the 
`instanceCount` is greater than 1) 
