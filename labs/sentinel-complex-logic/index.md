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

## Part 3: Collection Operations (Based on Official Documentation)

Sentinel supports collection operations such as `filter` and `map` for lists and maps ([see docs](https://developer.hashicorp.com/sentinel/docs/language/collection-operations)). Here are several focused examples, each as a separate policy file:

### a. Filtering a List

**filter-list.sentinel**
```sentinel
l = [1, 1, 2, 3, 5, 8]
evens = filter l as v { v % 2 is 0 }

main = rule { evens == [2, 8] }
```
- Run: `sentinel apply filter-list.sentinel`
- This will PASS because the filter returns only even numbers.

### b. Filtering a Map

**filter-map.sentinel**
```sentinel
m = { "a": "foo", "b": "bar" }
matched_foo = filter m as _, v { v is "foo" }

main = rule { length(matched_foo) == 1 && matched_foo["a"] == "foo" }
```
- Run: `sentinel apply filter-map.sentinel`
- This will PASS because only the key/value pair with value "foo" is returned.

### c. Mapping a List

**map-list.sentinel**
```sentinel
l = [1, 2]
r = map l as v { v % 2 }

# This rule will FAIL because r == [false, true], not [true, true]
main = rule { r == [true, true] }
```
- Run: `sentinel apply map-list.sentinel`
- This will FAIL because the rule expects [true, true] but gets [false, true].

### d. Mapping a Map

**map-map.sentinel**
```sentinel
m = { "a": "foo", "b": "bar" }
r = map m as k, v { v }

# This rule will FAIL because r contains "foo" and "bar", but we check for "baz"
main = rule { length(r) == 2 && "baz" in r }
```
- Run: `sentinel apply map-map.sentinel`
- This will FAIL because "baz" is not in the list of values.

**Explanation:**
- Each example demonstrates a different aspect of collection operations in Sentinel, as shown in the [official documentation](https://developer.hashicorp.com/sentinel/docs/language/collection-operations).
- All are minimal, focused, and runnable in the open-source CLI.

--- 