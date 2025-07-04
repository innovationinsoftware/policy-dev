# HashiCorp Sentinel Lab 8: Complex Policy Logic

> **NOTE:** The open-source Sentinel CLI does **not** support an `input` variable or import. All data must be provided via supported imports (like `time`), static imports (using `import "static"`), or parameters. This lab uses only features available in the open-source CLI. See [Sentinel documentation](https://developer.hashicorp.com/sentinel/docs/configuration#mock-imports) for details.

## Overview
In this lab, you'll learn how to write more complex Sentinel policies using conditional statements and iteration. These features allow you to express advanced logic, handle multiple resources, and enforce nuanced rules. By the end, you'll be able to write policies that adapt to different inputs and evaluate collections of data.

---

## Lab Setup

Create and move into a working directory for this lab:

```bash
mkdir lab8
cd lab8
```
All commands and files in this lab should be created and run inside the `lab8` directory.

---

## Part 1: Conditional Statements

Conditional statements let you write policies that behave differently based on data. Sentinel supports `if`, `else if`, and `else` just like many programming languages.

### 1. Using If/Else in Policies with Static Imports

Let's start with a policy that enforces different CPU limits based on the environment, using a static import for data.

1. Create a data file named `envdata.json`:
   ```json
   { "env": "prod", "cpu": 3 }
   ```
2. Create a policy file named `conditional-cpu.sentinel`:
   ```hcl
   import "static" "envdata"
   main = rule {
     if envdata.env == "prod" {
       envdata.cpu <= 4
     } else {
       envdata.cpu <= 2
     }
   }
   ```
3. Create or edit a configuration file named `sentinel.hcl`:
   ```hcl
   import "static" "envdata" {
     source = "./envdata.json"
     format = "json"
   }
   ```
4. Run:
   ```bash
   sentinel apply conditional-cpu.sentinel
   ```
   You should see `PASS`. Edit `envdata.json` and change `cpu` to 5, then rerun. What happens?

5. Edit `envdata.json` to:
   ```json
   { "env": "dev", "cpu": 2 }
   ```
6. Run:
   ```bash
   sentinel apply conditional-cpu.sentinel
   ```
   Try changing `cpu` to 3 and rerun. What result do you get?

**Try this:**
- Add an `else if` branch for a `test` environment with a different limit.
- Add a print statement to show which branch is being evaluated.

**Reflection:**
How do conditional statements help you write more flexible policies?

---

## Part 2: Loops and Iteration

Sentinel supports iteration over lists and maps using the `foreach` and `filter` constructs. This is useful for evaluating policies against collections of resources or attributes.

### 2. Enforcing a Rule Across Multiple Resources

Suppose you want to ensure all VMs in a list have a tag `"owner"`.

1. Create a data file named `vms.json`:
   ```json
   [
     { "name": "vm1", "tags": ["owner", "prod"] },
     { "name": "vm2", "tags": ["owner"] },
     { "name": "vm3", "tags": ["dev"] }
   ]
   ```
2. Create a policy file named `tags-iteration.sentinel`:
   ```hcl
   import "static" "vms"
   main = rule {
     all_owners = [
       foreach vm in vms :
         "owner" in vm.tags
     ]
     all(all_owners)
   }
   ```
3. Edit `sentinel.hcl` to:
   ```hcl
   import "static" "vms" {
     source = "./vms.json"
     format = "json"
   }
   ```
4. Run:
   ```bash
   sentinel apply tags-iteration.sentinel
   ```
   You should see `FAIL` because `vm3` is missing the `owner` tag.

**Try this:**
- Add the `owner` tag to `vm3` in `vms.json` and rerun. The policy should pass.
- Print the names of VMs missing the `owner` tag.

**Challenge:**
Write a policy that ensures all VMs have both an `owner` and an `environment` tag.

---

### 3. Filtering and Counting

You can use `filter` to select items from a list that meet a condition, and `length` to count them.

1. Edit `tags-iteration.sentinel` to:
   ```hcl
   import "static" "vms"
   missing_owners = filter vm in vms : !("owner" in vm.tags)
   main = rule { length(missing_owners) == 0 }
   ```
2. Run the policy. Try removing the `owner` tag from one or more VMs in `vms.json` and observe the result.

**Try this:**
- Print the number of VMs missing the `owner` tag.
- Use a function to encapsulate the check for required tags.

---

## Part 3: Advanced Iteration and Conditionals

### 4. Nested Conditionals and Loops

Combine conditionals and iteration for more advanced logic.

1. Edit `vms.json` to provide a mix of prod and non-prod VMs, some missing tags:
   ```json
   [
     { "name": "vm1", "tags": ["owner", "prod", "environment"] },
     { "name": "vm2", "tags": ["owner", "prod"] },
     { "name": "vm3", "tags": ["dev"] }
   ]
   ```
2. Create a policy file named `complex-policy.sentinel`:
   ```hcl
   import "static" "vms"
   main = rule {
     all([
       foreach vm in vms :
         if "prod" in vm.tags {
           "owner" in vm.tags and "environment" in vm.tags
         } else {
           true
         }
     ])
   }
   ```
3. Edit `sentinel.hcl` to:
   ```hcl
   import "static" "vms" {
     source = "./vms.json"
     format = "json"
   }
   ```
4. Run:
   ```bash
   sentinel apply complex-policy.sentinel
   ```
   Observe which VMs are non-compliant by adjusting the logic or adding print statements.

**Try this:**
- Add a print statement to show which VMs are non-compliant.
- Refactor the logic into a function for reuse.

**Challenge:**
Write a policy that enforces different tag requirements for prod and dev VMs using nested conditionals and iteration.

---

## Lab Completion

In this lab, you:
- Used conditional statements to write flexible policies
- Used loops and iteration to evaluate collections of resources
- Practiced advanced logic with nested conditionals and iteration

You now have the skills to write complex, real-world Sentinel policies! 