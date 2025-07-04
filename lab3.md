# HashiCorp Sentinel Lab 3: Rules and Functions

## Overview
In this lab, you'll explore the heart of Sentinel policies: rules and functions. Rules determine whether a policy passes or fails, while functions let you encapsulate and reuse logic. You'll learn how to define, use, and test both, and you'll practice combining them for more complex logic. By the end, you'll be able to write expressive, maintainable Sentinel policies.

---

## Part 1: Working with Rules

Rules are the primary building blocks of Sentinel policies. Each rule evaluates to either true or false, and the `main` rule determines the policy's outcome.

### 1. Define Multiple Rules (Practical Example)
Let's see how you can define and use more than one rule in a policy, using a more practical scenario.

1. Create a file named `rules.sentinel`:
   ```hcl
   is_admin = rule { "admin" in ["admin", "user", "guest"] }
   has_access = rule { is_admin or (5 < 10) }
   main = rule { has_access }
   ```
2. Run:
   ```bash
   sentinel apply rules.sentinel
   ```
You should see `PASS`. The `main` rule allows access if the user is an admin or another condition is met.

**Now try the following to see both PASS and FAIL outcomes:**

- Edit `rules.sentinel` and change `is_admin` to check for a different role:
  ```hcl
  is_admin = rule { "user" in ["admin"] }
  has_access = rule { is_admin or (5 < 10) }
  main = rule { has_access }
  ```
  Run the policy. You should see `PASS` (because `5 < 10` is true).

- Now, change `has_access` so both conditions are false:
  ```hcl
  is_admin = rule { "user" in ["admin"] }
  has_access = rule { is_admin or (5 > 10) }
  main = rule { has_access }
  ```
  Run the policy. You should see `FAIL`.

- Add a third rule, `quota_ok`, and use it in `main`:
  ```hcl
  is_admin = rule { "admin" in ["admin", "user", "guest"] }
  has_access = rule { is_admin or (5 < 10) }
  quota_ok = rule { 100 > 200 }
  main = rule { has_access and quota_ok }
  ```
  Run the policy. You should see `FAIL` (because `quota_ok` is false).

- Change `quota_ok` to be true:
  ```hcl
  quota_ok = rule { 100 < 200 }
  ```
  Run the policy. You should see `PASS`.

**Explanation:**
This shows how you can model real access control or resource checks with multiple rules.

---

### 2. Rule Dependencies and Evaluation (Policy Scenario)
Let’s make rules depend on each other in a more policy-like way.

1. Edit `rules.sentinel` to:
   ```hcl
   is_weekend = rule { false }
   is_holiday = rule { true }
   can_deploy = rule { !is_weekend and !is_holiday }
   main = rule { can_deploy }
   ```
2. Run the policy and observe the result.

**Explanation:**
With these values, `is_weekend` is `false` (so `!is_weekend` is `true`), but `is_holiday` is `true` (so `!is_holiday` is `false`). Since `can_deploy` requires both to be true, the result is `false` and the policy fails. This is expected.

**Now try the following to see how rule dependencies work:**
- Add a rule for `maintenance_mode`:
  ```hcl
  maintenance_mode = rule { false }
  ```
  Update `can_deploy` to:
  ```hcl
  can_deploy = rule { !is_weekend and !is_holiday and !maintenance_mode }
  ```
  Run the policy and see how toggling these rules affects the outcome.

**Explanation:**
With the current values, `can_deploy` is still `false` because `!is_holiday` is `false`. To make the policy pass, set all three to `false` so that all the `!` conditions are `true`. This demonstrates how changing the values of dependent rules directly affects the policy outcome.

**Challenge:**
Write a policy where `main` passes only if at least two out of three conditions (`is_weekend`, `is_holiday`, `maintenance_mode`) are false. For example:
```hcl
is_weekend = rule { false }
is_holiday = rule { true }
maintenance_mode = rule { false }
main = rule {
  (!is_weekend and !is_holiday) or
  (!is_weekend and !maintenance_mode) or
  (!is_holiday and !maintenance_mode)
}
```
Run the policy and confirm it passes. Try changing the values of the rules and see how it affects the result.

**Explanation:**
This models a deployment policy that depends on multiple environment factors.

---

## Part 2: Defining and Using Functions

Functions let you encapsulate logic and reuse it in rules. Sentinel supports both built-in and user-defined functions.

### 3. Create a Simple Function

**About Sentinel functions:**
In Sentinel, you can define your own functions to encapsulate logic and reuse it in rules. Every function must include an explicit `return` statement to specify what value the function should output. If you forget the `return`, Sentinel will produce a runtime error and your policy will fail.

Let's practice creating and using a simple function.

1. Create a file named `functions.sentinel`:
   ```hcl
   double = func(x) { return x * 2 }
   main = rule { double(3) == 6 }
   ```
2. Run:
   ```bash
   sentinel apply functions.sentinel
   ```
   You should see `PASS`. The function `double` is used in the `main` rule to check if doubling 3 equals 6.

**Now try the following to see how functions can be reused:**
- Edit `functions.sentinel` and change the argument to `double(5)`:
  ```hcl
  double = func(x) { return x * 2 }
  main = rule { double(5) == 10 }
  ```
  Run the policy and confirm it passes. This shows how you can reuse the same function with different inputs.
- Add another function to `functions.sentinel`:
  ```hcl
  double = func(x) { return x * 2 }
  triple = func(x) { return x * 3 }
  main = rule { triple(2) == 6 }
  ```
  Run the policy and confirm it passes.

**Explanation:**
Functions help you avoid repeating logic and make your policies easier to maintain. Always remember to use `return` in your function definitions to avoid runtime errors.

---

### 4. Functions with Multiple Arguments and Return Types

**How Sentinel functions work:**
Sentinel functions are reusable blocks of logic that you define with the `func` keyword. You can pass one or more arguments to a function, and the function will return a value based on those arguments. The value can be any type supported by Sentinel, such as a number, boolean, string, or even a collection. You must always use an explicit `return` statement to specify what the function outputs.

**Why use functions with multiple arguments or different return types?**
In real policies, you often need to perform calculations or checks that depend on more than one value. For example, you might want to compare two numbers, check if a user has a specific role, or validate that a resource meets certain criteria. By writing functions that accept multiple arguments, you can make your policies more flexible and avoid repeating similar logic in multiple places. Functions that return booleans are especially useful for rules, while functions that return numbers or strings can be used for calculations or further checks.

Let's practice writing and using such functions.

1. Edit `functions.sentinel` to:
   ```hcl
   add = func(a, b) { return a + b }
   main = rule { add(2, 3) == 5 }
   ```
2. Run the policy and confirm it passes.

**How this function works:**
- `add = func(a, b) { return a + b }` defines a function named `add` that takes two arguments, `a` and `b`.
- Inside the function, `a + b` adds the two arguments together.
- The `return` statement ensures the result of `a + b` is given back to wherever the function is called.
- In the rule `main = rule { add(2, 3) == 5 }`, the function is called with `2` and `3` as arguments, so it returns `5`.
- The rule checks if the result of `add(2, 3)` is equal to `5`. If it is, the rule passes.

This pattern lets you write reusable logic for any two numbers you want to add, and you can use the result in other rules or calculations.

**Now try the following to practice writing different functions:**
- Write a function that returns a boolean:
  ```hcl
  is_even = func(x) { return x % 2 == 0 }
  main = rule { is_even(4) }
  ```
  Run the policy and confirm it passes. Here, `is_even` checks if a number is divisible by 2 and returns `true` or `false`.

**Challenge:**
Write a function that returns the maximum of two numbers and use it in a rule. For example:
```hcl
max = func(a, b) { if a > b { return a } else { return b } }
main = rule { max(3, 5) == 5 }
```
Run the policy and confirm it passes. Try changing the arguments to see different results.

**Explanation:**
- You define a function with `func(name, ...) { ... }` and use `return` to specify the output.
- Arguments are passed in parentheses, e.g., `add(2, 3)`.
- The function can return any value, and you can use the result in rules or other functions.
- Functions with multiple arguments let you write more flexible and powerful logic, making your policies easier to maintain and adapt to new requirements.

---

## Part 3: Combining Rules and Functions

You can use functions inside rules and combine multiple rules for more complex logic.

### 5. Build a Composite Policy
1. Create a file named `composite.sentinel`:
   ```hcl
   is_even = func(x) { return x % 2 == 0 }
   allow = rule { is_even(4) }
   main = rule { allow }
   ```
2. Run:
   ```bash
   sentinel apply composite.sentinel
   ```
   You should see `PASS`.

**Now try the following to see how combining functions and rules works:**
- Edit `composite.sentinel` and change the argument to `is_even(5)`:
  ```hcl
  is_even = func(x) { return x % 2 == 0 }
  allow = rule { is_even(5) }
  main = rule { allow }
  ```
  Run the policy and observe the result (`FAIL`).
- Combine multiple functions in a rule:
  ```hcl
  double = func(x) { return x * 2 }
  triple = func(x) { return x * 3 }
  main = rule { double(2) == 4 and triple(2) == 6 }
  ```
  Run the policy and confirm it passes.
- Use a function to determine the outcome of more than one rule:
  ```hcl
  is_even = func(x) { return x % 2 == 0 }
  allow = rule { is_even(2) }
  deny = rule { !is_even(3) }
  main = rule { allow and deny }
  ```
  Run the policy and confirm it passes.

**Challenge:**
Write a policy in `composite.sentinel` where `main` passes only if a function returns true for at least two different inputs. For example:
```hcl
is_even = func(x) { return x % 2 == 0 }
main = rule { is_even(2) and is_even(4) }
```
Run the policy and confirm it passes. Try changing one of the arguments to an odd number and see how it affects the result.

**Explanation:**
Combining rules and functions lets you express complex requirements in a clear and reusable way.

---

## Part 4: Advanced Rule and Function Patterns

### 6. Nested Functions and Rule Logic
1. Edit `composite.sentinel` to:
   ```hcl
   add = func(a, b) { return a + b }
   is_sum_even = func(a, b) { add(a, b) % 2 == 0 }
   main = rule { is_sum_even(2, 4) }
   ```
2. Run the policy and observe the result.

**Now try the following to practice nesting functions:**
- Edit `composite.sentinel` and nest more functions or use more complex logic, for example:
  ```hcl
  add = func(a, b) { return a + b }
  multiply = func(a, b) { return a * b }
  main = rule { multiply(add(2, 3), 2) == 10 }
  ```
  Run the policy and confirm it passes.

**Explanation:**
Nesting functions allows you to build up more advanced logic and reuse smaller pieces of code.

### 7. Error Handling in Functions
1. Create a file `error-func.sentinel`:
   ```hcl
   divide = func(a, b) { return a / b }
   main = rule { divide(4, 0) == 0 }
   ```
2. Run:
   ```bash
   sentinel apply error-func.sentinel
   ```
   You should see an error message about division by zero. Sentinel will report a runtime error and the policy will fail.

**Explanation:**
This demonstrates how Sentinel handles invalid operations in functions. It's important to consider error cases when writing your own functions.

---

## Lab Completion

In this lab, you:
- Defined and tested rules
- Created and used functions
- Combined rules and functions for more complex logic
- Explored advanced patterns and error handling

You're now ready to explore imports and modules in Sentinel! 