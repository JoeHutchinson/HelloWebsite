# Hello Website

This project demonstrates how to host a simple website using Terraform.

It's a simple example creating a VPC with public and private subnets, an internet gateway, and a load balancer to host a website on ECS Fargate.

Fargate vs Lambda is a often discussed topic, Fargate was chosen in this case under the assumtpion the website will see steady predictable load and that response times are important. Lambda is a better choice for sporadic traffic or where cold starts are not a concern.

API Gateway vs ALB, would use API Gateway if we were hosting using a Lambda function, and cared about caching request etc. For the purpose of this project ALB was chosen for it's simplicity.

VPC flow logs are in place, more for compliance and auditing than anything else.

VPC endpoints to ECS and ECR are in place, to ensure traffic doesn't leave the VPC when accessing these services.

Dependabot config in place to keep all the modules up to date. Pre-commit hooks in place to ensure code quality.

## Installation

1. Install and configure the required dependencies:
  * [Terraform](https://www.terraform.io/downloads.html)
  * [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html)
  * [Git](https://git-scm.com/downloads)

1. Clone the repository:

  ```bash
  git clone https://github.com/your-username/HelloWebsite.git
  ```

1. Change into the project directory:

  ```bash
  cd HelloWebsite
  ```

## Usage

1. Add your AWS access and secret keys to the `./variables/default.tfvars` file:

  ```hcl
  access_key = "YOUR_ACCESS_KEY"
  secret_key = "YOUR_SECRET_KEY"
  ```

2. Deploy the website infrastructure in ascending order:
  e.g.
  ```bash
  terraform -chdir=components\200-network\ init
  terraform -chdir=components\200-network\ apply --var-file=.\..\variables\default.tfvars
  terraform -chdir=components\300-app\ init
  terraform -chdir=components\300-app\ apply --var-file=.\..\variables\default.tfvars
  ```

3. Access the website by to the provided URL in the output `service_address` field of of the `300-app` component.
e.g. curl ex-HelloWebsite-1825686964.eu-west-1.elb.amazonaws.com

## Limitations / Future Improvements

There's many. But to list the main ones:
1. Initialising the AWS provider with credentials is not the best idea, better to assume IAM role of the agent executing the Terraform commands
1. Env tag should be based off the terraform workspace, as this project shouldn't have a CICD system I had to just have it passed in
1. VPC should be using IPAM to avoid CIDR clash, in this example I only have one VPC so risk is limited, in production environment this would be required
1. VPC should have infra and DB subnets, in this example I don't need a DB so I didn't create one, I also didn't require subnets without internet access
1. ALB should have a WAF attached to it, to protect against common web attacks
1. ALB should have a Route53 domain and SSL certificate attached to it, to allow for a custom domain
1. If for a production system I'd build opinionated TF modules instead of using the AWS modules, this would allow for more control, improved readability and easier to maintain. I chose to use the AWS modules more out of curiosity to see how much they've improved in 4 years since I last used them, turns out not much, they're still far too complex and somewhat overcomplicate the solution.
1. Outbound traffic proxied through security gateway to ensure no data exfiltration, specified via an AWS prefix list
1. A CI/CD pipeline in place to deploy the infrastructure, this would allow for better testing and more frequent deployments
1. A `400-monitoring` component defining alerts and dashboards, to alert on any issues with the service
1. A backup and restore system in place, to ensure data is not lost
1. A disaster recovery plan in place, to ensure the system can be restored in the event of a disaster
1. A security plan in place, to ensure the system is secure and compliant with industry standards

## License

Apache 2 Licensed. See [LICENSE](./LICENSE) for full details.
