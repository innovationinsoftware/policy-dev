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
1. Create a file named `functions.sentinel`:
   ```hcl
   double = func(x) { x * 2 }
   main = rule { double(3) == 6 }
   ```
2. Run:
   ```bash
   sentinel apply functions.sentinel
   ```
You should see `PASS`. The function `double` is used in the `main` rule.

**Now try the following to see how functions can be reused:**
- Edit `functions.sentinel` and change the argument to `double(5)`:
  ```hcl
  main = rule { double(5) == 10 }
  ```
  Run the policy and confirm it passes. This shows how you can reuse the same function with different inputs.
- Add another function to `functions.sentinel`:
  ```hcl
  triple = func(x) { x * 3 }
  ```
  Then use it in a rule:
  ```hcl
  main = rule { triple(2) == 6 }
  ```
  Run the policy and confirm it passes.

**Explanation:**
Functions help you avoid repeating logic and make your policies easier to maintain.

---

### 4. Functions with Multiple Arguments and Return Types
Functions can take multiple arguments and return different types.

1. Edit `functions.sentinel` to:
   ```hcl
   add = func(a, b) { a + b }
   main = rule { add(2, 3) == 5 }
   ```
2. Run the policy and confirm it passes.

**Now try the following to practice writing different functions:**
- Write a function that returns a boolean:
  ```hcl
  is_even = func(x) { x % 2 == 0 }
  main = rule { is_even(4) }
  ```
  Run the policy and confirm it passes.

**Challenge:**
Write a function that returns the maximum of two numbers and use it in a rule. For example:
```hcl
max = func(a, b) { if a > b { return a } else { return b } }
main = rule { max(3, 5) == 5 }
```
Run the policy and confirm it passes. Try changing the arguments to see different results.

**Explanation:**
Functions with multiple arguments let you write more flexible and powerful logic in your policies.

---

## Part 3: Combining Rules and Functions

You can use functions inside rules and combine multiple rules for more complex logic.

### 5. Build a Composite Policy
1. Create a file named `composite.sentinel`:
   ```hcl
   is_even = func(x) { x % 2 == 0 }
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
  allow = rule { is_even(5) }
  main = rule { allow }
  ```
  Run the policy and observe the result (`FAIL`).
- Combine multiple functions in a rule:
  ```hcl
  double = func(x) { x * 2 }
  triple = func(x) { x * 3 }
  main = rule { double(2) == 4 and triple(2) == 6 }
  ```
  Run the policy and confirm it passes.
- Use a function to determine the outcome of more than one rule:
  ```hcl
  is_even = func(x) { x % 2 == 0 }
  allow = rule { is_even(2) }
  deny = rule { !is_even(3) }
  main = rule { allow and deny }
  ```
  Run the policy and confirm it passes.

**Challenge:**
Write a policy in `composite.sentinel` where `main` passes only if a function returns true for at least two different inputs. For example:
```hcl
is_even = func(x) { x % 2 == 0 }
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
   add = func(a, b) { a + b }
   is_sum_even = func(a, b) { add(a, b) % 2 == 0 }
   main = rule { is_sum_even(2, 4) }
   ```
2. Run the policy and observe the result.

**Now try the following to practice nesting functions:**
- Edit `composite.sentinel` and nest more functions or use more complex logic, for example:
  ```hcl
  add = func(a, b) { a + b }
  multiply = func(a, b) { a * b }
  main = rule { multiply(add(2, 3), 2) == 10 }
  ```
  Run the policy and confirm it passes.

**Explanation:**
Nesting functions allows you to build up more advanced logic and reuse smaller pieces of code.

### 7. Error Handling in Functions
1. Create a file `error-func.sentinel`:
   ```hcl
   divide = func(a, b) { a / b }
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