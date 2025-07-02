# HashiCorp Sentinel Lab 5: Writing Basic Policies

## Overview
In this lab, you'll put together everything you've learned so far to write real-world Sentinel policies. You'll focus on two common types: resource restriction policies and data validation policies. By the end, you'll be able to write policies that enforce limits and validate input data, preparing you for practical policy-as-code scenarios.

---

## Part 1: Resource Restriction Policies

Resource restriction policies are used to enforce limits on infrastructure resources, such as the number of CPUs, memory size, or allowed regions. These policies help ensure compliance with organizational standards and cost controls.

### 1. Restricting CPU Count
Let's start by writing a policy that restricts the number of CPUs a resource can have.

1. Create a file named `cpu-restriction.sentinel`:
   ```hcl
   main = rule { input.cpu <= 4 }
   ```
2. Create a mock data file named `mock.json`:
   ```json
   { "cpu": 2 }
   ```
3. Run:
   ```bash
   sentinel apply cpu-restriction.sentinel -input mock.json
   ```
You should see `PASS`. Try changing the value of `cpu` in `mock.json` to 8 and rerun. What happens?

**Try this:**
- Change the policy to restrict CPUs to 2 or fewer.
- Add a comment explaining the policy's purpose.

**Reflection:**
Why might an organization want to restrict CPU counts?

---

### 2. Restricting Allowed Regions
Sometimes, you want to ensure resources are only created in approved regions.

1. Create a file named `region-restriction.sentinel`:
   ```hcl
   allowed_regions = ["us-east1", "us-west1"]
   main = rule { input.region in allowed_regions }
   ```
2. Create a mock data file named `region-mock.json`:
   ```json
   { "region": "us-east1" }
   ```
3. Run:
   ```bash
   sentinel apply region-restriction.sentinel -input region-mock.json
   ```
You should see `PASS`. Change the region to `europe-west1` and rerun. What result do you get?

**Try this:**
- Add another allowed region to the list.
- Make the policy fail if the region is not in the list and print a custom error message (hint: use the `print` function).

**Challenge:**
Write a policy that restricts both CPU count and region in the same file.

---

## Part 2: Data Validation Policies

Data validation policies ensure that input data meets certain criteria before resources are created or modified. This helps catch errors early and enforce standards.

### 3. Validating Required Fields
Let's write a policy that checks for the presence of required fields in the input.

1. Create a file named `required-fields.sentinel`:
   ```hcl
   main = rule { input.name is not null and input.env is not null }
   ```
2. Create a mock data file named `fields-mock.json`:
   ```json
   { "name": "web-server", "env": "prod" }
   ```
3. Run:
   ```bash
   sentinel apply required-fields.sentinel -input fields-mock.json
   ```
Try removing one of the fields from the mock data and rerun. What happens?

**Try this:**
- Add a check that `input.env` must be either `prod` or `dev`.
- Add a comment explaining why required fields are important.

**Reflection:**
How does data validation help prevent misconfigurations?

---

### 4. Validating Value Ranges
You can also validate that input values fall within acceptable ranges.

1. Create a file named `range-validation.sentinel`:
   ```hcl
   main = rule { input.replicas >= 1 and input.replicas <= 5 }
   ```
2. Create a mock data file named `range-mock.json`:
   ```json
   { "replicas": 3 }
   ```
3. Run:
   ```bash
   sentinel apply range-validation.sentinel -input range-mock.json
   ```
Try setting `replicas` to 0 or 10 and rerun. What result do you get?

**Try this:**
- Change the allowed range and test different values.
- Add a function to check if a value is within a range and use it in your rule.

**Challenge:**
Write a policy that validates both required fields and value ranges in the same file.

---

## Part 3: Reflection and Best Practices

- Why is it important to write clear, well-documented policies?
- How can you make your policies more reusable and maintainable?
- What are some real-world scenarios where resource restriction and data validation policies are critical?

---

## Lab Completion

In this lab, you:
- Wrote resource restriction policies
- Wrote data validation policies
- Practiced using mock data to test your policies
- Reflected on best practices for policy writing

You now have practical experience writing basic Sentinel policies. You're ready to tackle more advanced policy scenarios! 