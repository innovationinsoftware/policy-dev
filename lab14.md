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
  enforcement_level = "soft-mandatory"
}
```

#### 3. Tagging Policies
- Ensure all resources have required tags (e.g., owner, environment, cost center)
- Enforce tag value formats or presence

**Example:**
```hcl
policy "require-resource-tags" {
  source = "./policies/tags/require-resource-tags.sentinel"
  enforcement_level = "advisory"
  params = {
    required_tags = ["Owner", "Environment", "CostCenter"]
  }
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
- In HCP Terraform, go to **Policy Sets**
- Click **Connect a new policy set** and select **VCS**
- Authorize and select your forked repository
- Choose to apply the policy set to all or specific workspaces
- Review and adjust the `sentinel.hcl` file to enable/disable policies or change enforcement levels as needed

#### 3. Test Policy Enforcement
- Trigger a Terraform run in a workspace attached to the policy set
- Observe policy checks in the run output (e.g., failures for unencrypted resources or missing tags)
- Try violating a policy (e.g., create an unencrypted S3 bucket) and confirm enforcement

---

### Expected Results
- Sentinel policies from the CIS Policy Set are evaluated on every Terraform run
- Non-compliant resources are flagged or blocked according to enforcement level
- Your AWS infrastructure is automatically checked for network security, encryption, and tagging compliance

---

### Reflection & Challenge
- **Reflection:** How do pre-written policy libraries accelerate security and compliance in cloud environments?
- **Challenge:**
  - Customize a policy (e.g., add a required tag or change enforcement level)
  - Add a new policy from the library and test its effect on your workspace

---

[Source: CIS Policy Set for AWS Terraform](https://github.com/hashicorp/policy-library-CIS-Policy-Set-for-AWS-Terraform)
