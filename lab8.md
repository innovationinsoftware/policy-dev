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

### 2. Boolean Expressions in Sentinel (Based on Official Documentation)

Sentinel supports a rich set of boolean expressions for policy logic. Here are several focused examples, each as a separate policy file:

#### a. Basic Boolean Logic

**boolexpr-basic.sentinel**
```sentinel
main = rule {
  (4 + 5 * 2 == 14) and (10 > 2) or (false)
}
```
- Run: `sentinel apply boolexpr-basic.sentinel`
- This will PASS because the expression evaluates to true.

#### b. Set Operators

**boolexpr-set.sentinel**
```sentinel
main = rule {
  [1, 2, 3] contains 2 and {"a": 1, "b": 2} contains "a" and 2 in [1, 2, 3]
}
```
- Run: `sentinel apply boolexpr-set.sentinel`
- This will PASS because the set operators all return true.

#### c. Any/All Expressions

**boolexpr-anyall.sentinel**
```sentinel
main = rule {
  all [1, 2, 3] as n { n > 0 } and any [1, 2, 3] as n { n == 2 }
}
```
- Run: `sentinel apply boolexpr-anyall.sentinel`
- This will PASS because all numbers are > 0 and at least one is 2.

#### d. Emptiness Comparison

**boolexpr-emptiness.sentinel**
```sentinel
main = rule {
  [] is empty and [1] is not empty and {} is empty
}
```
- Run: `sentinel apply boolexpr-emptiness.sentinel`
- This will PASS because the emptiness checks are correct.

#### e. Defined Comparison

**boolexpr-defined.sentinel**
```sentinel
main = rule {
  4 is defined and undefined is not defined and [] is defined
}
```
- Run: `sentinel apply boolexpr-defined.sentinel`
- This will PASS because the defined checks are correct.

**Explanation:**
- Each example demonstrates a different aspect of boolean expressions in Sentinel, as shown in the [official documentation](https://developer.hashicorp.com/sentinel/docs/language/boolexpr).
- All are minimal, focused, and runnable in the open-source CLI.

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