# HashiCorp Sentinel Lab 5: Writing Policies with the Time Import

## Overview
In this lab, you'll learn how to write and test Sentinel policies using the officially supported `time` import and mock data, as shown in the [Sentinel documentation](https://developer.hashicorp.com/sentinel/docs/configuration#mock-imports). All examples are runnable in the open-source Sentinel CLI.

---

## Lab Setup

Create and move into a working directory for this lab:

```bash
mkdir lab5
cd lab5
```
All commands and files in this lab should be created and run inside the `lab5` directory.

---

## Part 1: Using the Time Import

Sentinel's open-source CLI supports mocking the `time` import, which allows you to write policies based on the current (mocked) time.

### 1. Basic Time Policy

1. Create a file named `time-policy.sentinel`:
   ```hcl
   import "time"

   main = rule { time.now.hour < 12 }
   ```
2. Create or edit a configuration file named `sentinel.hcl`:
   ```hcl
   mock "time" {
     data = {
       now = {
         hour = 9
         minute = 42
       }
     }
   }
   ```
3. Run:
   ```bash
   sentinel apply time-policy.sentinel
   ```
   You should see `PASS` (since 9 < 12).
4. Change the `hour` value in `sentinel.hcl` to 13:
   ```hcl
   mock "time" {
     data = {
       now = {
         hour = 13
         minute = 42
       }
     }
   }
   ```
   Run the policy again. You should see `FAIL` (since 13 is not less than 12).

**Explanation:**
This policy checks if the current (mocked) hour is before noon.

---

### 2. Policy with Minutes

1. Create a file named `minute-policy.sentinel`:
   ```hcl
   import "time"

   main = rule { time.now.minute >= 30 }
   ```
2. Edit `sentinel.hcl` to set the minute value:
   ```hcl
   mock "time" {
     data = {
       now = {
         hour = 10
         minute = 45
       }
     }
   }
   ```
3. Run:
   ```bash
   sentinel apply minute-policy.sentinel
   ```
   You should see `PASS` (since 45 >= 30).
4. Change the `minute` value in `sentinel.hcl` to 15 and rerun. You should see `FAIL`.

**Explanation:**
This policy checks if the current (mocked) minute is at least 30.

---

### 3. Combining Hour and Minute

1. Create a file named `combined-policy.sentinel`:
   ```hcl
   import "time"

   main = rule { time.now.hour == 10 and time.now.minute == 45 }
   ```
2. Edit `sentinel.hcl` to:
   ```hcl
   mock "time" {
     data = {
       now = {
         hour = 10
         minute = 45
       }
     }
   }
   ```
3. Run:
   ```bash
   sentinel apply combined-policy.sentinel
   ```
   You should see `PASS`.
4. Change either the hour or minute in `sentinel.hcl` and rerun. You should see `FAIL`.

**Explanation:**
This policy checks for an exact hour and minute match.

---

## Reflection and Best Practices

- Use the `time` import and mock as shown in the official documentation for fully runnable, testable policies in the open-source CLI.
- Always provide a `sentinel.hcl` file with a `mock "time"` block for your test data.
- Adjust the mock data to test different policy outcomes.

---

## Lab Completion

In this lab, you:
- Wrote policies using the `time` import
- Used mock data in `sentinel.hcl` to test different scenarios
- Practiced hands-on, fully runnable Sentinel policy development

You now have practical experience writing Sentinel policies that are guaranteed to work in the open-source CLI! 