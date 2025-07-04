# HashiCorp Sentinel Lab 4: Imports and Modules

## Overview
In this lab, you'll learn how to extend Sentinel's capabilities using imports and modules. Imports let you use built-in libraries for common operations, while modules help you organize and reuse policy code. You'll practice using both in hands-on exercises and explore best practices for modular policy design.

---

## Lab Setup

Create and move into a working directory for this lab:

```bash
mkdir lab4
cd lab4
```
All commands and files in this lab should be created and run inside the `lab4` directory.

---

## Part 1: Using Built-in Imports

Sentinel provides several built-in imports (libraries) for tasks like string manipulation, math, and collections. Let's see how to use them and why they're useful.

### 1. Use the Strings Import
1. Create a file named `strings-import.sentinel`:
   ```hcl
   import "strings"
   main = rule { strings.has_suffix("sentinel", "nel") }
   ```
2. Run:
   ```bash
   sentinel apply strings-import.sentinel
   ```
You should see `PASS`. Try changing the suffix to something else and observe the result.

**Now try the following:**
- Edit `strings-import.sentinel` to use `strings.has_prefix` instead:
  ```hcl
  import "strings"
  main = rule { strings.has_prefix("sentinel", "sen") }
  ```
  Run the policy and observe the result.
- Try using `strings.contains("sentinel", "tin")` in the rule and see if it passes.

**Explanation:**
String operations help you write more flexible policies by allowing you to check for patterns, prefixes, or substrings in resource names, user roles, or other data.

---

### 2. Explore Other Imports
Sentinel includes imports for math, collections, and more. Let's try them out.

1. Create a file named `math-import.sentinel`:
   ```hcl
   import "math"
   main = rule { math.abs(-5) == 5 }
   ```
2. Run:
   ```bash
   sentinel apply math-import.sentinel
   ```
Try using other math functions, such as `math.max(3, 7)`.

1. Create a file named `collections-import.sentinel`:
   ```hcl
   import "collections"
   main = rule { collections.length([1,2,3]) == 3 }
   ```
2. Run:
   ```bash
   sentinel apply collections-import.sentinel
   ```
Try using `collections.contains([1,2,3], 2)`.

**Challenge:**
Write a policy that uses both `math` and `collections` imports in the same rule. For example:
```hcl
import "math"
import "collections"
main = rule { math.max(collections.length([1,2,3]), 2) == 3 }
```
Save this as `math-collections-challenge.sentinel` and run:
```bash
sentinel apply math-collections-challenge.sentinel
```
You should see `PASS`. Try changing the list or the comparison value to see different results.

---

## Part 2: Understanding and Using Modules

Modules let you organize and reuse code across multiple policies. While advanced usage is rare in simple policies, it's important to know the basics and best practices.

### 3. Create and Use a Simple Module
1. Create a file named `util.sentinel`:
   ```hcl
   double = func(x) { return x * 2 }
   triple = func(x) { return x * 3 }
   ```
2. In another file, `use-module.sentinel`, import and use the module:
   ```hcl
   import "./util.sentinel" as util
   main = rule { util.double(4) == 8 and util.triple(3) == 9 }
   ```
3. Run:
   ```bash
   sentinel apply use-module.sentinel
   ```
You should see `PASS`. This demonstrates how to import and use a local module.

**Now try the following:**
- Add another function to `util.sentinel`, for example:
  ```hcl
  quadruple = func(x) { return x * 4 }
  ```
  Then use it in `use-module.sentinel`:
  ```hcl
  main = rule { util.quadruple(2) == 8 }
  ```
  Run the policy and confirm it passes.
- Try importing the same module in multiple policy files to see how code reuse works.

**Explanation:**
Using modules helps you avoid code duplication and makes it easier to update logic in one place for all policies that use it.

---

### 4. Best Practices for Modular Policy Design

Organizing your policies into modules can make them easier to maintain and reuse. Let's explore some best practices.

1. Create a module `mathutils.sentinel` with several math functions. For example:
   ```hcl
   add = func(a, b) { return a + b }
   subtract = func(a, b) { return a - b }
   multiply = func(a, b) { return a * b }
   ```
2. Create a policy that imports `mathutils.sentinel` and uses multiple functions. For example, in `use-mathutils.sentinel`:
   ```hcl
   import "./mathutils.sentinel" as mathutils
   main = rule { mathutils.add(2, 3) == 5 and mathutils.multiply(2, 3) == 6 }
   ```
3. Run:
   ```bash
   sentinel apply use-mathutils.sentinel
   ```
   You should see `PASS`.
4. Try updating a function in the module (e.g., change `add` to return `a + b + 1`) and see how it affects all policies that import it.

**Challenge:**
Refactor a previous policy to use a module for all custom functions. For example, move your `double`, `triple`, and `quadruple` functions into a module called `customfuncs.sentinel`, then import and use them in a new policy file:
```hcl
# customfuncs.sentinel

double = func(x) { return x * 2 }
triple = func(x) { return x * 3 }
quadruple = func(x) { return x * 4 }
```
```hcl
# use-customfuncs.sentinel
import "./customfuncs.sentinel" as cf
main = rule { cf.double(2) == 4 and cf.triple(2) == 6 and cf.quadruple(2) == 8 }
```
Run:
```bash
sentinel apply use-customfuncs.sentinel
```
You should see `PASS`.

---

## Part 3: Advanced Import and Module Patterns

### 5. Nested Imports and Error Handling
1. Create a module that imports another module (if supported in your Sentinel version).
2. Try to import a non-existent module and observe the error.

**Now try the following:**
- Experiment with import paths (relative, absolute).
- Try importing a module with a syntax error and see what happens.

**Explanation:**
These steps help you understand how Sentinel handles import errors and how to structure your modules for maintainability.

---

## Lab Completion

In this lab, you:
- Used built-in imports for common operations
- Explored other available imports
- Created and used simple modules
- Practiced best practices for modular policy design
- Explored advanced import and module patterns

You now have a working knowledge of Sentinel's imports and modules. You're ready for more advanced policy development and integration! 