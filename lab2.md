# HashiCorp Sentinel Lab 2: Language Basics – Syntax and Structure

## Overview
In this lab, you'll dive deep into the foundational elements of the Sentinel language: its syntax and structure. You'll learn not just how to write valid Sentinel, but also how to organize, document, and experiment with your policies. By the end, you'll be comfortable reading and writing Sentinel code, and you'll understand how structure impacts maintainability and clarity.

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

**Try this:**  
- Change `true` to `false` and rerun. What happens?
- Remove the `main =` line and try to run the policy. What error do you get?

**Reflection:**  
Why do you think Sentinel requires a `main` rule?

---

### 2. Add Comments
Comments help document your policies. Sentinel supports single-line comments using `#`.

1. Edit `minimal.sentinel` to add a comment:
   ```hcl
   # This is a minimal passing policy
   main = rule { true }
   ```
2. Run the policy again to confirm comments don't affect execution.

**Try this:**  
- Add a comment after the rule, like `main = rule { true } # always pass`
- Try using `//` or `/* ... */` as comments. What happens?

**Best Practice:**  
Always document the purpose of your policy and any non-obvious logic.

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
Try changing the expression to `1 > 2` or `false` and observe the result.

**Try this:**  
- Use `or` instead of `and`.
- Combine multiple expressions: `main = rule { (1 < 2) and (2 < 3) }`

**Reflection:**  
How does Sentinel handle complex boolean logic?

---

### 4. Use Arithmetic and Comparison
1. Edit `logic.sentinel` to:
   ```hcl
   main = rule { (3 * 2) == 6 }
   ```
2. Run the policy and confirm it passes.

**Try this:**  
- Use other operators: `+`, `-`, `/`, `%`
- Try `main = rule { 5 % 2 == 1 }`

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
You should see `PASS`. This demonstrates how you can define multiple rules and use them in your main rule.

**Try this:**  
- Add another rule, e.g., `maybe = rule { 1 == 2 }`, and use it in `main`.
- Swap the logic in `main` to see how it affects the result.

**Challenge:**  
Write a policy with three rules: `allow`, `deny`, and `maybe`. Make `main` pass only if `allow` is true, `deny` is false, and `maybe` is false.

---

## Part 4: Advanced Syntax Exploration

### 6. Use Nested Expressions
1. Edit `structure.sentinel` to:
   ```hcl
   allow = rule { (2 + 2 == 4) and (3 > 1) }
   main = rule { allow }
   ```
2. Run the policy and observe the result.

**Try this:**  
- Nest more expressions or use parentheses to change evaluation order.

### 7. Explore Error Handling
1. Create a file `error.sentinel`:
   ```hcl
   main = rule { 1 / 0 == 0 }
   ```
2. Run:
   ```bash
   sentinel apply error.sentinel
   ```
What error do you see? How does Sentinel handle invalid operations?

---

## Lab Completion

In this lab, you:
- Explored Sentinel file structure and syntax
- Used comments, expressions, and operators
- Practiced organizing policies for clarity
- Experimented with advanced syntax and error handling

You now have a strong foundation in Sentinel's language basics. Next, you'll dive deeper into rules and functions! 