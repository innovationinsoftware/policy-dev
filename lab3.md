# HashiCorp Sentinel Lab 3: Rules and Functions

## Overview
In this lab, you'll explore the heart of Sentinel policies: rules and functions. Rules determine whether a policy passes or fails, while functions let you encapsulate and reuse logic. You'll learn how to define, use, and test both, and you'll practice combining them for more complex logic. By the end, you'll be able to write expressive, maintainable Sentinel policies.

---

## Part 1: Working with Rules

Rules are the primary building blocks of Sentinel policies. Each rule evaluates to either true or false, and the `main` rule determines the policy's outcome.

### 1. Define Multiple Rules
Let's see how you can define and use more than one rule in a policy.

1. Create a file named `rules.sentinel`:
   ```hcl
   allow = rule { 2 + 2 == 4 }
   deny = rule { false }
   main = rule { allow and not deny }
   ```
2. Run:
   ```bash
   sentinel apply rules.sentinel
   ```
You should see `PASS`. The `main` rule combines the results of `allow` and `deny`.

**Try this:**
- Change `allow` to `allow = rule { false }` and rerun. What happens?
- Add a third rule, e.g., `maybe = rule { 1 == 2 }`, and use it in `main`.

**Reflection:**
How does combining rules help you express more complex policy logic?

---

### 2. Rule Dependencies and Evaluation
Rules can depend on each other. Let's explore how Sentinel evaluates them.

1. Edit `rules.sentinel` to:
   ```hcl
   allow = rule { 5 > 3 }
   deny = rule { !allow }
   main = rule { allow and not deny }
   ```
2. Run the policy and observe the result.

**Try this:**
- Make `allow` depend on another rule, e.g., `maybe = rule { 2 < 3 }` and use `allow = rule { maybe }`.

**Challenge:**
Write a policy where `main` passes only if two out of three rules are true.

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

**Try this:**
- Change the argument to `double(5)` and update the rule.
- Add another function, e.g., `triple = func(x) { x * 3 }`, and use it in a rule.

**Reflection:**
How do functions help you avoid repeating logic in your policies?

---

### 4. Functions with Multiple Arguments and Return Types
Functions can take multiple arguments and return different types.

1. Edit `functions.sentinel` to:
   ```hcl
   add = func(a, b) { a + b }
   main = rule { add(2, 3) == 5 }
   ```
2. Run the policy and confirm it passes.

**Try this:**
- Write a function that returns a boolean, e.g., `is_even = func(x) { x % 2 == 0 }`.
- Use it in a rule: `main = rule { is_even(4) }`.

**Challenge:**
Write a function that returns the maximum of two numbers and use it in a rule.

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
Try changing the argument to `is_even(5)` and see what happens.

**Try this:**
- Combine multiple functions in a rule.
- Use a function to determine the outcome of more than one rule.

**Challenge:**
Write a policy where `main` passes only if a function returns true for at least two different inputs.

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

**Try this:**
- Nest more functions or use more complex logic in your rules.

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
What error do you see? How does Sentinel handle invalid operations in functions?

---

## Lab Completion

In this lab, you:
- Defined and tested rules
- Created and used functions
- Combined rules and functions for more complex logic
- Explored advanced patterns and error handling

You're now ready to explore imports and modules in Sentinel! 