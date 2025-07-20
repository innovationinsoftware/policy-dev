# Lab 13: Enforcing Sentinel Policies in HCP Terraform

---

### Overview

In this lab, you will learn how to enforce Sentinel policies in HCP Terraform. You will fork an example policy repository, connect it to HCP Terraform as a policy set, and apply it to a workspace. This process enables automated policy checks on every Terraform run, ensuring your infrastructure changes comply with organizational requirements.

---

### Context

Policy as code allows you to define, version, and enforce rules for your infrastructure in a programmatic way. Sentinel is HashiCorp’s policy-as-code framework, integrated with HCP Terraform, that enables fine-grained, logic-based policy decisions. By enforcing policies in HCP Terraform, you can prevent misconfigurations, enforce compliance, and automate governance across your infrastructure workflows.

---

### Hands-On Tasks

#### 1. Fork the Example Policy Repository

- Go to [https://github.com/hashicorp/learn-terraform-enforce-policies](https://github.com/hashicorp/learn-terraform-enforce-policies) in your web browser.
- Click the **Fork** button in the top right to create a copy of the repository under your own GitHub account.
- Once forked, clone your forked repository to your local machine:

```sh
git clone https://github.com/<your-username>/learn-terraform-enforce-policies.git
cd learn-terraform-enforce-policies
```

This repository contains two files: `sentinel.hcl` (the policy set definition) and `allowed-terraform-version.sentinel` (the policy code).

---

#### 2. Explore the Policy Set and Policy Files

- Open `sentinel.hcl` to see how the policy set is defined. For example:

```hcl
policy "allowed-terraform-version" {
  enforcement_level = "soft-mandatory"
}
```

- Open `allowed-terraform-version.sentinel` to review the policy logic. For example:

```hcl
import "tfplan"
import "version"

main = rule {
  version.new(tfplan.terraform_version).greater_than("1.1.0")
}
```

---

#### 3. Connect the Policy Set to HCP Terraform

- In the HCP Terraform UI, navigate to your organization's **Settings** > **Policy Sets**.
- Click **Connect a new policy set**.
- Select **GitHub** as the VCS provider and choose your forked repository.
- On the settings page:
  - Select **Sentinel** as the policy framework.
  - Under **Scope of Policies**, select the workspaces you want this policy set to apply to (e.g., your `learn-terraform` workspace).
  - Click **Connect policy set** to finish.

---

#### 4. Run a Plan to Trigger the Policy Check

- In your connected workspace, start a new run (e.g., **Start new run** > **Plan only**).
- Observe the policy check step in the run output. If the policy passes, the run will proceed; if it fails, the enforcement level will determine whether you can override or must fix the issue.

---

### Expected Results

- The Sentinel policy set is connected to your HCP Terraform organization and applied to your workspace.
- Terraform runs in the workspace now include a policy check step, enforcing the rules defined in your Sentinel policy.
- You can see pass/fail results for the policy check in the run output.

---

### Reflection & Challenge

- **Reflection:** How does enforcing Sentinel policies in HCP Terraform improve compliance and governance for your infrastructure?
- **Challenge:**
  - Try editing the Sentinel policy to require a different Terraform version, push the change, and observe the effect on your next run.

---