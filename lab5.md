# HashiCorp Sentinel Lab 5: Writing Basic Policies

## Overview
In this lab, you'll put together everything you've learned so far to write real-world Sentinel policies. You'll focus on two common types: resource restriction policies and data validation policies. By the end, you'll be able to write policies that enforce limits and validate input data, preparing you for practical policy-as-code scenarios.

---

## Important Note for Open-Source Sentinel CLI Users

The open-source Sentinel CLI does **not** support passing input data via command-line flags. To provide input data to your policies, you must use a `sentinel.hcl` configuration file with a `mock "input"` block. All examples in this lab use this method. See the [official documentation](https://developer.hashicorp.com/sentinel/docs/commands/apply) for details.

---

## Lab Setup

Create and move into a working directory for this lab:

```bash
mkdir lab5
cd lab5
```
All commands and files in this lab should be created and run inside the `lab5` directory.

---

## Part 1: Resource Restriction Policies

Resource restriction policies are used to enforce limits on infrastructure resources, such as the number of CPUs, memory size, or allowed regions. These policies help ensure compliance with organizational standards and cost controls.

### 1. Restricting CPU Count
Let's start by writing a policy that restricts the number of CPUs a resource can have.

1. Create a file named `cpu-restriction.sentinel`:
   ```hcl
   main = rule { input.cpu <= 4 }
   ```
2. Create or edit a configuration file named `sentinel.hcl`:
   ```hcl
   mock "input" {
     data = {
       cpu = 2
     }
   }
   ```
3. Run:
   ```bash
   sentinel apply cpu-restriction.sentinel
   ```
   You should see `PASS`.
4. Edit the `cpu` value in `sentinel.hcl` to 8:
   ```hcl
   mock "input" {
     data = {
       cpu = 8
     }
   }
   ```
   Run the policy again. You should see `FAIL` because the CPU count exceeds the allowed limit.
5. Edit `cpu-restriction.sentinel` to restrict CPUs to 2 or fewer:
   ```hcl
   // Only allow up to 2 CPUs for cost control
   main = rule { input.cpu <= 2 }
   ```
   Run the policy with `cpu` set to 2 and then to 3 in `sentinel.hcl`. Observe the results.

**Explanation:**
This policy enforces a maximum CPU count. Organizations use such policies to control costs and ensure resources are not over-provisioned.

---

### 2. Restricting Allowed Regions
Sometimes, you want to ensure resources are only created in approved regions.

1. Create a file named `region-restriction.sentinel`:
   ```hcl
   allowed_regions = ["us-east1", "us-west1"]
   main = rule { input.region in allowed_regions }
   ```
2. Edit `sentinel.hcl` to provide region input:
   ```hcl
   mock "input" {
     data = {
       region = "us-east1"
     }
   }
   ```
3. Run:
   ```bash
   sentinel apply region-restriction.sentinel
   ```
   You should see `PASS`.
4. Change the `region` value in `sentinel.hcl` to `europe-west1`:
   ```hcl
   mock "input" {
     data = {
       region = "europe-west1"
     }
   }
   ```
   Run the policy again. You should see `FAIL` because the region is not allowed.
5. Edit `region-restriction.sentinel` to add another allowed region:
   ```hcl
   allowed_regions = ["us-east1", "us-west1", "europe-west1"]
   main = rule { input.region in allowed_regions }
   ```
   Run the policy again with `region` set to `europe-west1`. You should now see `PASS`.
6. Edit `region-restriction.sentinel` to print a custom error message if the region is not allowed:
   ```hcl
   allowed_regions = ["us-east1", "us-west1"]
   main = rule {
     allowed = input.region in allowed_regions
     if not allowed {
       print("Region not allowed: " + input.region)
     }
     allowed
   }
   ```
   Run the policy with a disallowed region and observe the printed message.

7. Combine CPU and region restrictions in a single policy file named `cpu-region-restriction.sentinel`:
   ```hcl
   allowed_regions = ["us-east1", "us-west1"]
   main = rule { input.cpu <= 4 and input.region in allowed_regions }
   ```
   Edit `sentinel.hcl` to provide both values:
   ```hcl
   mock "input" {
     data = {
       cpu = 2
       region = "us-east1"
     }
   }
   ```
   Run:
   ```bash
   sentinel apply cpu-region-restriction.sentinel
   ```
   Try changing either value in `sentinel.hcl` to make the policy fail and observe the result.

**Explanation:**
This policy ensures resources are only created in approved regions and with an acceptable CPU count.

---

## Part 2: Data Validation Policies

Data validation policies ensure that input data meets certain criteria before resources are created or modified. This helps catch errors early and enforce standards.

### 3. Validating Required Fields
Let's write a policy that checks for the presence of required fields in the input.

1. Create a file named `required-fields.sentinel`:
   ```hcl
   main = rule { input.name is not null and input.env is not null }
   ```
2. Edit `sentinel.hcl` to provide the required fields:
   ```hcl
   mock "input" {
     data = {
       name = "web-server"
       env = "prod"
     }
   }
   ```
3. Run:
   ```bash
   sentinel apply required-fields.sentinel
   ```
   You should see `PASS`.
4. Remove the `env` field from `sentinel.hcl`:
   ```hcl
   mock "input" {
     data = {
       name = "web-server"
     }
   }
   ```
   Run the policy again. You should see `FAIL` because a required field is missing.
5. Edit `required-fields.sentinel` to require that `input.env` must be either `prod` or `dev`:
   ```hcl
   main = rule { input.name is not null and (input.env == "prod" or input.env == "dev") }
   ```
   Test with different values for `env` in `sentinel.hcl` and observe the results.
6. Add a comment at the top of the policy explaining why required fields are important:
   ```hcl
   // This policy ensures that required fields are present and valid to prevent misconfigurations.
   main = rule { input.name is not null and (input.env == "prod" or input.env == "dev") }
   ```

**Explanation:**
Validating required fields helps prevent misconfigurations and ensures that all necessary information is provided before resources are created.

---

### 4. Validating Value Ranges
You can also validate that input values fall within acceptable ranges.

1. Create a file named `range-validation.sentinel`:
   ```hcl
   main = rule { input.replicas >= 1 and input.replicas <= 5 }
   ```
2. Edit `sentinel.hcl` to provide the value:
   ```hcl
   mock "input" {
     data = {
       replicas = 3
     }
   }
   ```
3. Run:
   ```bash
   sentinel apply range-validation.sentinel
   ```
   You should see `PASS`.
4. Change `replicas` in `sentinel.hcl` to 0:
   ```hcl
   mock "input" {
     data = {
       replicas = 0
     }
   }
   ```
   Run the policy again. You should see `FAIL` because the value is out of range.
5. Change `replicas` in `sentinel.hcl` to 10 and run again. You should see `FAIL`.
6. Edit `range-validation.sentinel` to change the allowed range to 2-4:
   ```hcl
   main = rule { input.replicas >= 2 and input.replicas <= 4 }
   ```
   Test with different values in `sentinel.hcl` and observe the results.
7. Add a function to check if a value is within a range and use it in your rule:
   ```hcl
   in_range = func(x, min, max) { return x >= min and x <= max }
   main = rule { in_range(input.replicas, 1, 5) }
   ```
   Run the policy and test with different values for `replicas`.
8. Combine required field and value range validation in a single file named `validate-all.sentinel`:
   ```hcl
   in_range = func(x, min, max) { return x >= min and x <= max }
   main = rule { input.name is not null and in_range(input.replicas, 1, 5) }
   ```
   Edit `sentinel.hcl` to provide both values:
   ```hcl
   mock "input" {
     data = {
       name = "web-server"
       replicas = 3
     }
   }
   ```
   Run:
   ```bash
   sentinel apply validate-all.sentinel
   ```
   Try removing the `name` field or setting `replicas` out of range and observe the result.

**Explanation:**
This policy ensures that all required fields are present and that values fall within acceptable ranges, helping to prevent errors and enforce standards.

---

## Part 3: Reflection and Best Practices

- Write clear, well-documented policies so others can understand and maintain them.
- Use functions and modular logic to make your policies reusable and maintainable.
- Resource restriction and data validation policies are critical in real-world scenarios to control costs, enforce compliance, and prevent misconfigurations.

---

## Lab Completion

In this lab, you:
- Wrote resource restriction policies
- Wrote data validation policies
- Practiced using mock data to test your policies
- Reflected on best practices for policy writing

You now have practical experience writing basic Sentinel policies. You're ready to tackle more advanced policy scenarios! 