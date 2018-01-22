# parsec-terraform
A simple Terraform template and automation tool to build a Parsec Server inside a VPC in AWS in the least expensive availability zone.

Only tested on OSX.

## How to use this
1. Create a spot instance from the Parsec AMI by following the directions on their blog post here <https://blog.parsecgaming.com/cloud-gaming-with-amazon-aws-g3-instance-dc9576718f86>. During step 6, also create an additional larger EBS that is set *NOT* to delete on termination because you never know if you spot instance will be terminated during price fluxations
2. Clone this repo.
3. [Install Terraform.](https://www.terraform.io/intro/getting-started/install.html)
4. Ensure you have [aws](https://docs.aws.amazon.com/cli/latest/userguide/installing.html) and [jq](https://stedolan.github.io/jq/download/) installed.
5. Update terraform.tfvars to match your requirements
6. Run `terraform init` in the root folder and inside the subdirectory `create-ami`
7. Run `./bin/parsecadm plan` from the root of the repo to find the cheapest availability zone, calculate a max bid price, and shows you what you'll be provisioning.
8. Run `./bin/parsecadm apply` from the root of the repo to to launch a spot instance from your AMI.
9. Before running `./bin/parsecadm destroy` for the first time, delete your existing AMI so that the the new AMI can be created without its name clashing with the existing one. The AMI will be automatically deleted with subsequent calls to destroy as Terraform will keep the last record of the AMI it creates. 
10. Run `./bin/parsecadm destroy` to create an AMI from your spot instance and replace your old AMI then remove all resources.

