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

### 1. Using `if` to Set a Variable

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

### 2. Using `case` Statements

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

## Part 2: Loops and Iteration (Based on Official Documentation)

Sentinel supports `for` loops in the global scope or in functions, but **not inside rule blocks** ([see docs](https://developer.hashicorp.com/sentinel/docs/language/loops)).

### 1. Summing a List

This example demonstrates how to use a `for` loop to sum the values in a list.

1. Create a policy file named `sum-list.sentinel`:
   ```sentinel
   numbers = [1, 2, 3]
   sum = 0
   for numbers as num {
     sum += num
   }

   main = rule { sum == 6 }
   ```
2. Run:
   ```bash
   sentinel apply sum-list.sentinel
   ```
   You should see `PASS` because the sum of [1, 2, 3] is 6. Try changing the list or the rule to experiment.

**Explanation:**
- The `for` loop iterates over each number in the list and adds it to `sum`.
- The rule checks if the sum is as expected.

---

### 2. Working with Maps

This example demonstrates how to create a map, access and modify elements, delete keys, and use the `keys()` and `values()` functions.

1. Create a policy file named `map-basics.sentinel`:
   ```sentinel
   // Create a map
   mymap = { "a": 2, "b": 3 }

   // Access elements
   a_val = mymap["a"]        // 2
   missing_val = mymap["z"]  // undefined

   // Add or modify elements
   mymap["c"] = 5            // Add new key
   mymap["a"] = 10           // Modify existing key

   // Delete an element
   delete(mymap, "b")

   // Get keys and values
   map_keys = keys(mymap)
   map_values = values(mymap)

   // Check map state
   main = rule {
     mymap["a"] == 10 &&
     mymap["c"] == 5 &&
     mymap["b"] is undefined &&
     length(map_keys) == 2 &&
     length(map_values) == 2
   }
   ```
2. Run:
   ```bash
   sentinel apply map-basics.sentinel
   ```
   You should see `PASS` if the map operations are correct. Try adding, modifying, or deleting keys and rerun to experiment.

**Explanation:**
- The example shows how to create, access, modify, and delete map elements.
- It demonstrates the use of `keys()` and `values()` to retrieve map keys and values as lists.
- The rule checks the final state of the map.

---

### 3. Summing Values from a Map

This example demonstrates how to use a `for` loop to sum the values in a map.

1. Create a policy file named `sum-map.sentinel`:
   ```sentinel
   mymap = { "a": 1, "b": 2 }
   total = 0
   for mymap as k, v {
     total += v
   }

   main = rule { total == 3 }
   ```
2. Run:
   ```bash
   sentinel apply sum-map.sentinel
   ```
   You should see `PASS` because the sum of the values is 3. Try changing the map or the rule to experiment.

**Explanation:**
- The `for` loop iterates over the map, adding each value to `total`.
- The rule checks if the total is as expected.

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