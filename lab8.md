# HashiCorp Sentinel Lab 8: Complex Policy Logic

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

Conditional statements let you write policies that behave differently based on input values. Sentinel supports `if`, `else if`, and `else` just like many programming languages.

### 1. Using If/Else in Policies

Let's start with a policy that enforces different CPU limits based on the environment.

1. Create a file named `conditional-cpu.sentinel`:
   ```hcl
   main = rule {
     if input.env == "prod" {
       input.cpu <= 4
     } else {
       input.cpu <= 2
     }
   }
   ```
2. Create a mock data file named `prod-mock.json`:
   ```json
   { "env": "prod", "cpu": 3 }
   ```
3. Run:
   ```bash
   sentinel apply conditional-cpu.sentinel -input prod-mock.json
   ```
You should see `PASS`. Try changing `cpu` to 5 and rerun. What happens?

4. Create a mock data file named `dev-mock.json`:
   ```json
   { "env": "dev", "cpu": 2 }
   ```
5. Run:
   ```bash
   sentinel apply conditional-cpu.sentinel -input dev-mock.json
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

1. Create a file named `tags-iteration.sentinel`:
   ```hcl
   main = rule {
     all_owners = [
       foreach vm in input.vms :
         "owner" in vm.tags
     ]
     all(all_owners)
   }
   ```
2. Create a mock data file named `vms-mock.json`:
   ```json
   {
     "vms": [
       { "name": "vm1", "tags": ["owner", "prod"] },
       { "name": "vm2", "tags": ["owner"] },
       { "name": "vm3", "tags": ["dev"] }
     ]
   }
   ```
3. Run:
   ```bash
   sentinel apply tags-iteration.sentinel -input vms-mock.json
   ```
You should see `FAIL` because `vm3` is missing the `owner` tag.

**Try this:**
- Add the `owner` tag to `vm3` and rerun. The policy should pass.
- Print the names of VMs missing the `owner` tag.

**Challenge:**
Write a policy that ensures all VMs have both an `owner` and an `environment` tag.

---

### 3. Filtering and Counting

You can use `filter` to select items from a list that meet a condition, and `length` to count them.

1. Edit `tags-iteration.sentinel` to:
   ```hcl
   missing_owners = filter vm in input.vms : !("owner" in vm.tags)
   main = rule { length(missing_owners) == 0 }
   ```
2. Run the policy. Try removing the `owner` tag from one or more VMs and observe the result.

**Try this:**
- Print the number of VMs missing the `owner` tag.
- Use a function to encapsulate the check for required tags.

---

## Part 3: Advanced Iteration and Conditionals

### 4. Nested Conditionals and Loops

Combine conditionals and iteration for more advanced logic.

1. Create a file named `complex-policy.sentinel`:
   ```hcl
   main = rule {
     all([
       foreach vm in input.vms :
         if "prod" in vm.tags {
           "owner" in vm.tags and "environment" in vm.tags
         } else {
           true
         }
     ])
   }
   ```
2. Test with a mix of prod and non-prod VMs, some missing tags.

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