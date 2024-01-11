# AWS Auto Scaling Group Proof of Concept (ASG-PoC) 🚀

This Terraform project sets up an AWS Auto Scaling Group (ASG) with an associated load balancer and VPC. It's designed to demonstrate autoscaling capabilities on AWS.

## Prerequisites 📋

- Terraform installed (v1.2.0 or higher recommended).
- AWS CLI installed and configured with appropriate credentials.
- Access to an AWS account with permissions to create ASGs, Load Balancers, and VPCs or you can use the IAM Policy below:
```
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "autoscaling:*",
                "elasticloadbalancing:*",
                "ec2:Describe*",
                "ec2:AllocateAddress",
                "ec2:AssociateRouteTable",
                "ec2:AttachInternetGateway",
                "ec2:AuthorizeSecurityGroupIngress",
                "ec2:CreateInternetGateway",
                "ec2:CreateRoute",
                "ec2:CreateRouteTable",
                "ec2:CreateSecurityGroup",
                "ec2:CreateSubnet",
                "ec2:CreateTags",
                "ec2:CreateVpc",
                "ec2:ModifyVpcAttribute",
                "ec2:ReleaseAddress",
                "ec2:RunInstances",
                "ec2:TerminateInstances",
                "ec2:DeleteInternetGateway",
                "ec2:DeleteRouteTable",
                "ec2:DeleteSecurityGroup",
                "ec2:DeleteSubnet",
                "ec2:DeleteVpc",
                "ec2:DetachInternetGateway",
                "ec2:DisassociateRouteTable"
            ],
            "Resource": "*"
        }
    ]
}
```

## Easy Configuration with `config.yaml` 🛠️

The `config.yaml` file simplifies the management of Terraform configurations. This single file contains all the necessary configurations and variables for the project. You can easily modify this file to customize resource properties such as sizes, names, and policies. This approach centralizes configuration management, making it more straightforward and maintainable.

## Setup 🚀

1. **Initialize Terraform**: Navigate to the root of the Terraform project and run `terraform init`. This will download the necessary Terraform providers and modules.

2. **Review the Plan**: Execute `terraform plan` to review the resources that will be created in your AWS account.

3. **Apply Configuration**: Run `terraform apply` to create the resources. Confirm the action by typing `yes` when prompted or you run easyly `terraform apply --auto-approve` to skip prompt step or run in CI/CD pipeline if you need it.

4. **Access the Application**: After the apply completes, Terraform will output the DNS name of the load balancer. Use this DNS name in a web browser to access the application.

5. **Monitoring and Scaling**: Monitor the ASG behavior in the AWS Management Console. The ASG should scale up or down based on the defined policies.

## Clean Up 🧹

To remove all resources created by this Terraform configuration:

- Run `terraform destroy` and confirm with `yes` when prompted or you run easyly `terraform apply --auto-approve` to skip prompt step or run in CI/CD pipeline if you need it. This will tear down all resources managed by Terraform in this project.

## Modules Used 📦

- `autoscaling`: Manages the Auto Scaling Group and its policies.
- `load_balancer`: Sets up the application load balancer.
- `vpc`: Creates the VPC where the ASG and load balancer reside.

## Outputs 📤

- `app_load_balancer_dns`: The DNS name of the application load balancer.
