# HashiCorp Sentinel Lab 4: Imports and Modules

## Overview
In this lab, you'll learn how to extend Sentinel's capabilities using imports and modules. Imports let you use built-in libraries for common operations, while modules help you organize and reuse policy code. You'll practice using both in hands-on exercises and explore best practices for modular policy design.

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

**Try this:**
- Use `strings.has_prefix` instead.
- Try `strings.contains("sentinel", "tin")`.

**Reflection:**
How can string operations help you write more flexible policies?

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
Write a policy that uses both `math` and `collections` imports in the same rule.

---

## Part 2: Understanding and Using Modules

Modules let you organize and reuse code across multiple policies. While advanced usage is rare in simple policies, it's important to know the basics and best practices.

### 3. Create and Use a Simple Module
1. Create a file named `util.sentinel`:
   ```hcl
   double = func(x) { x * 2 }
   triple = func(x) { x * 3 }
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

**Try this:**
- Add another function to `util.sentinel` and use it in `use-module.sentinel`.
- Try importing the same module in multiple policy files.

**Reflection:**
How does using modules help you avoid code duplication?

---

### 4. Best Practices for Modular Policy Design

Organizing your policies into modules can make them easier to maintain and reuse. Let's explore some best practices.

1. Create a module `mathutils.sentinel` with several math functions.
2. Create a policy that imports `mathutils.sentinel` and uses multiple functions.
3. Try updating a function in the module and see how it affects all policies that import it.

**Challenge:**
Refactor a previous policy to use a module for all custom functions.

---

## Part 3: Advanced Import and Module Patterns

### 5. Nested Imports and Error Handling
1. Create a module that imports another module (if supported in your Sentinel version).
2. Try to import a non-existent module and observe the error.

**Try this:**
- Experiment with import paths (relative, absolute).
- Try importing a module with a syntax error and see what happens.

---

## Lab Completion

In this lab, you:
- Used built-in imports for common operations
- Explored other available imports
- Created and used simple modules
- Practiced best practices for modular policy design
- Explored advanced import and module patterns

You now have a working knowledge of Sentinel's imports and modules. You're ready for more advanced policy development and integration! 