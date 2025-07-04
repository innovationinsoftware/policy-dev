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

## Part 1: Conditionals in Sentinel (Based on Official Documentation)

Sentinel supports `if`, `else if`, and `else` statements in the global scope or in functions, but **not inside rule blocks** ([see docs](https://developer.hashicorp.com/sentinel/docs/language/conditionals)).

### 1. Using `if` to Set a Variable (from the docs)

This example demonstrates how to use an `if` statement in the global scope to set a variable, and then use that variable in a rule.

1. Create a policy file named `if-variable.sentinel`:
   ```sentinel
   value = 12
   if value == 18 {
     result = true
   } else {
     result = false
   }

   main = rule { result }
   ```
2. Run:
   ```bash
   sentinel apply if-variable.sentinel
   ```
   You should see `FAIL` because `value` is not 18. Try changing `value` to 18 and rerun. You should see `PASS`.

**Explanation:**
- The `if` statement sets `result` based on the value of `value`.
- The rule simply returns the value of `result`.

---

### 2. Using `case` Statements (from the docs)

This example demonstrates how to use a `case` statement in the global scope to set a variable, and then use that variable in a rule.

1. Create a policy file named `case-variable.sentinel`:
   ```sentinel
   x = "foo"
   case x {
     when "foo", "bar":
       result = true
     else:
       result = false
   }

   main = rule { result }
   ```
2. Run:
   ```bash
   sentinel apply case-variable.sentinel
   ```
   You should see `PASS` because `x` is "foo". Try changing `x` to something else (like "baz") and rerun. You should see `FAIL`.

**Explanation:**
- The `case` statement sets `result` to true if `x` is "foo" or "bar", otherwise false.
- The rule returns the value of `result`.

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