# HashiCorp Sentinel Lab 2: Language Basics – Syntax and Structure

## Overview
In this lab, you'll dive deep into the foundational elements of the Sentinel language: its syntax and structure. You'll learn not just how to write valid Sentinel, but also how to organize, document, and experiment with your policies. By the end, you'll be comfortable reading and writing Sentinel code, and you'll understand how structure impacts maintainability and clarity.

---

## Lab Setup

Create and move into a working directory for this lab:

```bash
mkdir lab2
cd lab2
```
All commands and files in this lab should be created and run inside the `lab2` directory.

---

## Part 1: Understanding Sentinel File Structure

Sentinel policies are written in files with the `.sentinel` extension. Each file typically contains one or more rules, and may include functions, imports, and other constructs. Good structure makes policies easier to read, debug, and share.

### 1. Explore a Minimal Policy
Let's start by creating the simplest possible policy to see the basic structure.

1. Create a file named `minimal.sentinel` with this content:
   ```hcl
   main = rule { true }
   ```
2. Run:
   ```bash
   sentinel apply minimal.sentinel
   ```
You should see `PASS`. This shows that the policy's main rule evaluated to true.

**Now try the following:**
- Edit `minimal.sentinel` and change `true` to `false`, so it reads:
  ```hcl
  main = rule { false }
  ```
  Run:
  ```bash
  sentinel apply minimal.sentinel
  ```
  You should see `FAIL`.
- Edit `minimal.sentinel` and remove the `main =` line entirely, so the file is empty. Run:
  ```bash
  sentinel apply minimal.sentinel
  ```
  Observe the error message. Sentinel requires a `main` rule to evaluate the policy.

**Reflection:**
Why do you think Sentinel requires a `main` rule?

---

### 2. Add Comments
Comments help document your policies. Sentinel supports single-line comments using `#`.

1. Edit `minimal.sentinel` to add a comment at the top:
   ```hcl
   # This is a minimal passing policy
   main = rule { true }
   ```
2. Run the policy again:
   ```bash
   sentinel apply minimal.sentinel
   ```
   Confirm that comments do not affect execution.

**Now try the following:**
- Add a comment after the rule, like this:
  ```hcl
  main = rule { true } # always pass
  ```
  Run the policy and confirm it still passes.
- Try using `//` or `/* ... */` as comments in the file. For example:
  ```hcl
  // This is a comment
  main = rule { true }
  ```
  or
  ```hcl
  /* This is a comment */
  main = rule { true }
  ```
  Run the policy and observe what happens. Sentinel only supports `#` for comments; other styles will cause errors.

**Best Practice:**
Always document the purpose of your policy and any non-obvious logic using `#` comments.

---

## Part 2: Expressions and Operators

Sentinel supports a variety of expressions and operators for logic and comparison. Mastering these lets you write more expressive policies.

### 3. Try Boolean Expressions
1. Create a file named `logic.sentinel`:
   ```hcl
   main = rule { 1 < 2 and true }
   ```
2. Run:
   ```bash
   sentinel apply logic.sentinel
   ```
   You should see `PASS`.

**Now try the following:**
- Edit `logic.sentinel` and change the expression to `1 > 2`, so it reads:
  ```hcl
  main = rule { 1 > 2 }
  ```
  Run the policy and observe the result (`FAIL`).
- Edit `logic.sentinel` and change the expression to `false`, so it reads:
  ```hcl
  main = rule { false }
  ```
  Run the policy and observe the result (`FAIL`).
- Edit `logic.sentinel` and use `or` instead of `and`, like this:
  ```hcl
  main = rule { 1 < 2 or false }
  ```
  Run the policy and observe the result (`PASS`).
- Edit `logic.sentinel` and combine multiple expressions:
  ```hcl
  main = rule { (1 < 2) and (2 < 3) }
  ```
  Run the policy and observe the result (`PASS`).

**Reflection:**
How does Sentinel handle complex boolean logic?

---

### 4. Use Arithmetic and Comparison
1. Edit `logic.sentinel` to:
   ```hcl
   main = rule { (3 * 2) == 6 }
   ```
2. Run the policy:
   ```bash
   sentinel apply logic.sentinel
   ```
   You should see `PASS`.

**Now try the following:**
- Edit `logic.sentinel` and use other operators, such as:
  ```hcl
  main = rule { 5 + 2 == 7 }
  ```
  or
  ```hcl
  main = rule { 10 / 2 == 5 }
  ```
  Run the policy and observe the result.
- Try using the modulo operator:
  ```hcl
  main = rule { 5 % 2 == 1 }
  ```
  Run the policy and observe the result (`PASS`).

**Did you know?**
Sentinel supports all standard arithmetic and comparison operators.

---

## Part 3: Policy Structure Best Practices

Organizing your policy files with clear structure and comments makes them easier to read and maintain.

### 5. Add a Header Comment and Multiple Rules
1. Create a file named `structure.sentinel`:
   ```hcl
   # Policy to demonstrate structure
   allow = rule { true }
   deny = rule { false }
   main = rule { allow and not deny }
   ```
2. Run:
   ```bash
   sentinel apply structure.sentinel
   ```
   You should see `PASS`.

**Now try the following:**
- Edit `structure.sentinel` and add another rule:
  ```hcl
  maybe = rule { 1 == 2 }
  ```
  Then update `main` to use it:
  ```hcl
  main = rule { allow and not deny and not maybe }
  ```
  Run the policy and observe the result (`PASS`).
- Edit `structure.sentinel` and swap the logic in `main` to:
  ```hcl
  main = rule { allow and deny }
  ```
  Run the policy and observe the result (`FAIL`).

**Challenge:**
Write a policy in `structure.sentinel` with three rules: `allow`, `deny`, and `maybe`. Set them as follows:
```hcl
allow = rule { true }
deny = rule { false }
maybe = rule { false }
main = rule { allow and not deny and not maybe }
```
Run the policy and confirm it passes. Then, try changing one of the rules to `true` and see how it affects the result.

---

## Part 4: Advanced Syntax Exploration

### 6. Use Nested Expressions
1. Edit `structure.sentinel` to:
   ```hcl
   allow = rule { (2 + 2 == 4) and (3 > 1) }
   main = rule { allow }
   ```
2. Run the policy:
   ```bash
   sentinel apply structure.sentinel
   ```
   You should see `PASS`.

**Now try the following:**
- Edit `structure.sentinel` and nest more expressions, for example:
  ```hcl
  allow = rule { ((2 + 2 == 4) and (3 > 1)) or (1 == 0) }
  main = rule { allow }
  ```
  Run the policy and observe the result (`PASS`).
- Edit `structure.sentinel` and use parentheses to change evaluation order, for example:
  ```hcl
  allow = rule { (2 + 2 == 5) or (3 > 1 and 1 == 1) }
  main = rule { allow }
  ```
  Run the policy and observe the result (`PASS`).

### 7. Explore Error Handling
1. Create a file `error.sentinel`:
   ```hcl
   main = rule { 1 / 0 == 0 }
   ```
2. Run:
   ```bash
   sentinel apply error.sentinel
   ```
   You should see an error message about division by zero. Sentinel will report a runtime error and the policy will fail.

---

## Lab Completion

In this lab, you:
- Explored Sentinel file structure and syntax
- Used comments, expressions, and operators
- Practiced organizing policies for clarity
- Experimented with advanced syntax and error handling

You now have a strong foundation in Sentinel's language basics. Next, you'll dive deeper into rules and functions! 