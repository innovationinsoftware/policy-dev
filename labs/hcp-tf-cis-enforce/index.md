# Lab 14: Enforcing Standard Security Policies for AWS with Sentinel and CIS Policy Set

---

### Overview

In this lab, you will learn how to enforce standard security and compliance policies for AWS resources using pre-written Sentinel policies from the [CIS Policy Set for AWS Terraform](https://github.com/hashicorp/policy-library-CIS-Policy-Set-for-AWS-Terraform). These policies help ensure your infrastructure meets industry best practices for network security, encryption, and resource tagging.

---

### Context

Manually implementing security controls across cloud resources is error-prone and difficult to scale. HashiCorp provides a library of pre-written Sentinel policies based on the CIS AWS Foundations Benchmark, which can be attached to your HCP Terraform workspaces to automatically enforce security, compliance, and operational standards.

---

### Key Policy Categories

#### 1. Network Security Rules
- Restrict security group ingress from 0.0.0.0/0 or ::/0 to ports 22 (SSH) and 3389 (RDP)
- Require VPC flow logging to be enabled
- Ensure default security groups do not allow any traffic

**Example:**
```hcl
policy "sg-no-ssh-from-anywhere" {
  source = "./policies/sg/sg-no-ssh-from-anywhere.sentinel"
  enforcement_level = "hard-mandatory"
}
```

#### 2. Encryption Requirements
- Enforce encryption at rest for S3 buckets, EBS volumes, and RDS instances
- Require KMS key rotation

**Example:**
```hcl
policy "ebs-encrypted" {
  source = "./policies/ebs/ebs-encrypted.sentinel"
  enforcement_level = "hard-mandatory"
}
```

---

### Hands-On Tasks

#### 1. Fork and Clone the CIS Policy Set Repository
- Go to [https://github.com/hashicorp/policy-library-CIS-Policy-Set-for-AWS-Terraform](https://github.com/hashicorp/policy-library-CIS-Policy-Set-for-AWS-Terraform)
- Click **Fork** to create your own copy
- Clone your fork locally:
```sh
git clone https://github.com/<your-username>/policy-library-CIS-Policy-Set-for-AWS-Terraform.git
cd policy-library-CIS-Policy-Set-for-AWS-Terraform
```

#### 2. Attach the Policy Set to Your HCP Terraform Organization
- In the HCP Terraform UI, navigate to your organization's **Settings** > **Policy Sets**.
- Click **Connect a new policy set**.
- Select **Version Control provider**
- On the settings page:
  - Name your policy 'cis-benchmarks-policy'
  - Select **Sentinel** as the policy framework.
  - Under **Scope of Policies**, select the workspaces you want this policy set to apply to (i.e. your workspace).
  - Untick the **Overrides** 'This policy set can be overridden in the event of mandatory failures.' checkbox.
  - Click **Next**
- Then select **github app** and select your forked 'learn-terraform-enforce-policies' repository.
- Click **Next** and finally select **Connect Policy Set**

#### 3. Test Policy Enforcement
- Trigger a Terraform run in your workspace.
- There should be **36 policy checks in total**, including **4 advisories**.
- Review the run output:
  - Examine which policies passed and which advisories were issued.
  - Advisories are informational and do not block the run, but highlight recommended best practices.
  - Passed policies confirm your configuration is compliant with those checks.

---

### Expected Results
- Sentinel policies from the CIS Policy Set are evaluated on every Terraform run
- Non-compliant resources are flagged or blocked according to enforcement level
- Your AWS infrastructure is automatically checked for compliance

---

### Reflection & Challenge
- **Reflection:** How do pre-written policy libraries accelerate security and compliance in cloud environments?
- **Challenge:**
  - Customize a policy (e.g., change enforcement level)

---

#### 4. Intentionally Violate CIS Policies in main.tf

To see the CIS policy set in action, make sure your `main.tf` in the `learn-terraform-variables` repository includes the following:

**a. Security Group Rule Allowing SSH from Anywhere**

Ensure you have a security group module with a rule that allows SSH (port 22) from `0.0.0.0/0`. For example:

```hcl
module "lb_security_group" {
  source  = "terraform-aws-modules/security-group/aws//modules/web"
  version = "3.17.0"

  name        = "lb-sg-project-alpha-dev"
  description = "Security group for load balancer with HTTP ports open within VPC"
  vpc_id      = module.vpc.vpc_id

  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["ssh-tcp"]
  ingress_with_cidr_blocks = [
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      description = "SSH open to the world"
      cidr_blocks = "0.0.0.0/0"
    }
  ]

  tags = {
    project     = "project-alpha",
    environment = "development"
  }
}
```

**b. Unencrypted EBS Volume**

Add the following resource to create an unencrypted EBS volume:

```hcl
resource "aws_ebs_volume" "unencrypted" {
  availability_zone = "us-west-1a"
  size              = 8
  encrypted         = false # Intentional violation: unencrypted EBS volume
}
```

---

After making these changes, commit and push them to your repository, then trigger a run in HCP Terraform. You should see policy violations flagged in the run output.

**After making these changes and triggering a run, you should now see 6 advisories in the run output. Carefully review the policy check results:**
- Look for the **encryption enabled policies** (such as EBS, S3, and RDS encryption) which should flag your unencrypted EBS volume.
- Look for the **security group policies** which should flag your SSH rule open to the world.

#### 5. Remediate the CIS Advisories

Now, update your Terraform configuration to resolve the advisories for SSH open to the world and unencrypted EBS volumes.

**a. Restrict SSH Access to Internal Network**

Update your security group so that SSH (port 22) is only allowed from your internal network (e.g., `10.0.0.0/16`):

```hcl
module "lb_security_group" {
  source  = "terraform-aws-modules/security-group/aws//modules/web"
  version = "3.17.0"

  name        = "lb-sg-project-alpha-dev"
  description = "Security group for load balancer with HTTP ports open within VPC"
  vpc_id      = module.vpc.vpc_id

  ingress_cidr_blocks = ["10.0.0.0/16"]
  ingress_rules       = ["ssh-tcp"]
  ingress_with_cidr_blocks = [
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      description = "SSH restricted to internal network"
      cidr_blocks = "10.0.0.0/16"
    }
  ]

  tags = {
    project     = "project-alpha",
    environment = "development"
  }
}
```

**b. Enable Encryption on EBS Volume**

Update your EBS volume resource to enable encryption:

```hcl
resource "aws_ebs_volume" "unencrypted" {
  availability_zone = "us-west-1a"
  size              = 8
  encrypted         = true # Remediated: enable encryption
}
```

---

After making these changes, commit and push them to your repository, then trigger a run in HCP Terraform. **There should now be 3 advisories in the run output.**
