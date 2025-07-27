# HashiCorp Sentinel Lab 4: Imports and Modules

## Overview
In this lab, you'll learn how to extend Sentinel's capabilities using imports and modules. Imports let you use built-in libraries for common operations, while modules help you organize and reuse policy code. You'll practice using both in hands-on exercises.

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

**How this works:**
- `import "strings"` brings in the built-in `strings` library, which provides functions for working with text.
- `main = rule { strings.has_suffix("sentinel", "nel") }` defines the main rule for the policy. It uses the `has_suffix` function from the `strings` import to check if the string `"sentinel"` ends with the substring `"nel"`.
- If `strings.has_suffix("sentinel", "nel")` returns `true`, the rule passes and you see `PASS`. If you change the suffix to something that doesn't match, the rule will fail and you'll see `FAIL`.

**Now try the following:**
- Edit `strings-import.sentinel` to use `strings.has_prefix` instead:
  ```hcl
  import "strings"
  main = rule { strings.has_prefix("sentinel", "sen") }
  ```
  Run the policy and observe the result.

**Explanation:**
String operations help you write more flexible policies by allowing you to check for patterns, prefixes, or substrings in resource names, user roles, or other data.

---

### 2. Explore Other Imports (Runnable Example)
Sentinel allows you to use imports to access external data and functions, but the available imports depend on your environment. Here is an example using the real 'time' import, which is available in the open-source Sentinel CLI:

1. Create a file named `time-import.sentinel`:
   ```hcl
   import "time"

   is_weekday = rule { true }
   is_open_hours = rule { true }
   main = rule { is_open_hours and is_weekday }
   ```
2. Run:
   ```bash
   sentinel apply time-import.sentinel
   ```

**How this works:**
- `import "time"` brings in the built-in `time` library, which provides functions for working with time and dates.
- `is_weekday = rule { true }` and `is_open_hours = rule { true }` are rules that always evaluate to `true`.
- The `main` rule combines both and will always be `true`, so the policy will always pass.

**Explanation:**
By setting both `is_weekday` and `is_open_hours` to `true`, the `main` rule will always be `true`, so the policy will always pass. This is useful for testing or demonstration purposes.

---

## Part 2: Understanding and Using Modules

Modules let you organize and reuse code across multiple policies. While advanced usage is rare in simple policies, it's important to know the basics.

### 3. Using Modules Locally with the Sentinel CLI (Runnable Example)

You can use modules locally with the open-source Sentinel CLI by configuring them in a Sentinel configuration file. Here’s how to do it:

1. Create a module file at `lab4/modules/foo.sentinel`:
   ```hcl
   // modules/foo.sentinel
   hello = func() {
     print("hello world!")
     return undefined
   }
   ```

2. Create a policy file named `lab4/policy.sentinel`:
   ```hcl
   import "foo"

   foo.hello()

   main = true
   ```

3. In the same directory as your policy, create a Sentinel configuration file named `sentinel.hcl`:
   ```hcl
   import "module" "foo" {
     source = "./modules/foo.sentinel"
   }
   ```

4. Run your policy:
   ```bash
   sentinel apply policy.sentinel
   ```
   You should see `hello world!` printed in the trace output and the policy should pass.

**How this works:**
- The `sentinel.hcl` configuration file tells Sentinel to load the module from `modules/foo.sentinel` and make it available as `foo` in your policy.
- In your policy, you import the module with `import "foo"` and call its function with `foo.hello()`.
- The `main = true` rule ensures the policy always passes.

---

## Lab Completion

In this lab, you:
- Used built-in imports for common operations
- Explored other available imports
- Created and used simple modules

You now have a working knowledge of Sentinel's imports and modules. You're ready for more advanced policy development and integration! 