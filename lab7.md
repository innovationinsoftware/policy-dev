# HashiCorp Sentinel Lab 7: Enforcement Levels in Terraform Cloud

## Overview
In this lab, you'll learn how to use Sentinel enforcement levels—advisory, soft-mandatory, and hard-mandatory—in Terraform Cloud. You'll upload policies, set enforcement levels, and observe their real effects on Terraform runs. By the end, you'll understand how enforcement levels impact workflow and compliance in a real platform.

---

## Part 1: Preparing Your Environment

Before you begin, make sure you have:
- Access to a Terraform Cloud organization and workspace
- The Terraform CLI installed
- A Sentinel policy and test input files from previous labs

**Why?**
Terraform Cloud is required to set and observe enforcement levels in action. The CLI alone cannot demonstrate these features.

---

## Part 2: Uploading a Sentinel Policy to Terraform Cloud

### 1. Create or Choose a Policy
Use a simple policy, such as restricting CPU count:
```hcl
main = rule { input.cpu <= 4 }
```
Save this as `cpu-policy.sentinel`.

### 2. Log in to Terraform Cloud
If you haven't already, log in:
```bash
tfc login
```
Or use the web UI at https://app.terraform.io

### 3. Create a Policy Set
1. In the Terraform Cloud UI, go to your organization.
2. Click **Policy Sets** > **Create a new policy set**.
3. Connect your policy set to your VCS repo or upload the policy file directly.
4. Add `cpu-policy.sentinel` to the policy set.

### 4. Attach the Policy Set to a Workspace
1. In the policy set settings, attach it to your target workspace.
2. Save changes.

---

## Part 3: Setting Enforcement Levels

Terraform Cloud lets you set the enforcement level for each policy:
- **Advisory:** Failing policy is a warning, run continues.
- **Soft-mandatory:** Failing policy blocks the run, but can be overridden.
- **Hard-mandatory:** Failing policy blocks the run, cannot be overridden.

### 5. Set Enforcement Level to Advisory
1. In the policy set, set the enforcement level for `cpu-policy.sentinel` to **Advisory**.
2. Save changes.

---

## Part 4: Observing Advisory Policy Behavior

### 6. Trigger a Run That Fails the Policy
1. In your workspace, change the Terraform configuration or variables so that `input.cpu` is greater than 4.
2. Queue a plan or apply in Terraform Cloud.

**Expected Result:**
- The run completes, but you see a warning in the UI that the policy failed.
- The warning does not block the run.

**Try this:**
- Change the input to pass the policy and rerun. The warning should disappear.

---

## Part 5: Observing Soft-Mandatory Policy Behavior

### 7. Set Enforcement Level to Soft-Mandatory
1. Change the enforcement level for `cpu-policy.sentinel` to **Soft-mandatory**.
2. Save changes.

### 8. Trigger a Failing Run
1. Set `input.cpu` to a value greater than 4.
2. Queue a plan or apply.

**Expected Result:**
- The run is blocked.
- The UI shows a policy failure and an option for an admin to override and continue.

**Try this:**
- As an admin, override the policy and continue the run.
- Change the input to pass the policy and rerun. The run should proceed without needing an override.

---

## Part 6: Observing Hard-Mandatory Policy Behavior

### 9. Set Enforcement Level to Hard-Mandatory
1. Change the enforcement level for `cpu-policy.sentinel` to **Hard-mandatory**.
2. Save changes.

### 10. Trigger a Failing Run
1. Set `input.cpu` to a value greater than 4.
2. Queue a plan or apply.

**Expected Result:**
- The run is blocked.
- The UI shows a policy failure and **no option to override**.

**Try this:**
- Change the input to pass the policy and rerun. The run should proceed.

---

## Part 7: Reflection and Best Practices

- How did each enforcement level affect the workflow?
- When would you use each enforcement level in your organization?
- What are the risks of using too many hard-mandatory policies?

**Challenge:**
- Try attaching multiple policies with different enforcement levels to the same workspace. Observe how each one affects the run.
- Document your findings and recommendations for your team.

---

## Lab Completion

In this lab, you:
- Uploaded and attached Sentinel policies in Terraform Cloud
- Set and tested advisory, soft-mandatory, and hard-mandatory enforcement levels
- Observed the real impact of enforcement levels on Terraform runs
- Reflected on best practices for policy enforcement

You now have hands-on experience using Sentinel enforcement levels in Terraform Cloud! 