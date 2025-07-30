# Enforcing Sentinel Policies in HCP Terraform

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
- Select **Version Control provider**
- On the settings page:
  - Name your policy "{workspace-name}-policy"
  - Select **Sentinel** as the policy framework.
  - Under **Scope of Policies**, select the workspaces you want this policy set to apply to (i.e. your workspace).
  - Untick the **Overrides** ' This policy set can be overridden in the event of mandatory failures.' checkbox.
  - Click **Next**
- Then select **github app** and select your forked 'learn-terraform-enforce-policies' repository.
- Click **Next** and finally select **Connect Policy Set**


---

#### 4. Run a Plan to Trigger the Policy Check

- In your connected workspace, start a new run (e.g., **Start new run** > **Plan only**).
- Observe the policy check step in the run output. If the policy passes, the run will proceed; if it fails, the enforcement level will determine whether you can override or must fix the issue.
- **Note:** If you are using Terraform 1.5.7, this step should succeed with the default policy.

---

#### 5. Force the Policy to Fail by Requiring a Higher Terraform Version

To see the policy enforcement in action, edit the Sentinel policy to require a Terraform version greater than 1.5.7 (which will cause the policy to fail for your current setup):

1. Open the `allowed-terraform-version.sentinel` file in your forked policy repository.
2. Change the policy logic to require a higher version, for example:
   ```python
   import "tfplan"
   import "version"

   main = rule {
     version.new(tfplan.terraform_version).greater_than("1.5.8")
   }
   ```
3. Commit and push the change to your policy repository:
   ```sh
   git add .
   git commit -m "Require Terraform version > 1.5.8 to force policy failure"
   git push
   ```
4. In HCP Terraform, trigger a new 'plan only' run in your workspace.
5. Observe that the policy check now fails, demonstrating Sentinel's enforcement capabilities.

---

**Before proceeding to step 6:**

- After each run that demonstrates a policy check (advisory or hard-mandatory), be sure to **discard the run** after observing the policy check result. Do not proceed with 'apply'—this ensures you do not make unintended changes to your infrastructure while testing policy enforcement behaviors.

---

#### 6. Demonstrate Each Sentinel Enforcement Level

Sentinel supports  enforcement levels for policies: `advisory`, `soft-mandatory`, and `hard-mandatory`. Each level affects how policy failures impact Terraform runs. Let's demonstrate this.

##### a. Advisory

1. Edit the `sentinel.hcl` file in your policy repository and set the enforcement level to `advisory`:
   ```hcl
   policy "allowed-terraform-version" {
     enforcement_level = "advisory"
   }
   ```
2. Commit and push the change:
   ```sh
   git add sentinel.hcl
   git commit -m "Set enforcement level to advisory"
   git push
   ```
3. In HCP Terraform, trigger a new 'plan and apply' run in your workspace.
4. **Expected outcome:** The policy check will fail, but the run will proceed. The failure will be shown as a warning, and you can continue without intervention.

##### b. Hard-Mandatory

1. Edit the `sentinel.hcl` file and set the enforcement level to `hard-mandatory`:
   ```hcl
   policy "allowed-terraform-version" {
     enforcement_level = "hard-mandatory"
   }
   ```
2. Commit and push the change:
   ```sh
   git add sentinel.hcl
   git commit -m "Set enforcement level to hard-mandatory"
   git push
   ```
3. In HCP Terraform, trigger a new 'plan only' run in your workspace.
4. **Expected outcome:** The policy check will fail, and the run will be blocked. You cannot override the failure; you must fix the policy violation before proceeding.

##### c. Allow Overrides and Observe the Difference

1. In the HCP Terraform UI, go to your organization's **Policy Sets** settings.
2. Edit your policy set and enable the **Overrides** option: 'This policy set can be overridden in the event of mandatory failures.'
3. Trigger another run in your workspace (plan and apply).
4. **Expected outcome:** The policy check will fail, but now you will see an option to override the failure and proceed with the run. This demonstrates how the policy set override setting affects all mandatory enforcement levels.

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
  - Allow policy overrides for your workspace again.

---