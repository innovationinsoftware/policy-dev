# HashiCorp Sentinel Lab 5: Writing Policies with the Time Import

## Overview
In this lab, you'll learn how to write and test Sentinel policies using the officially supported `time` import and mock data, as shown in the [Sentinel documentation](https://developer.hashicorp.com/sentinel/docs/configuration#mock-imports). All examples are runnable in the open-source Sentinel CLI.

---

## Lab Setup

### Create the Lab Directory

1. Right-click inside the VS Code **Explorer** pane and select **New Folder**.
2. Name this folder `lab5`.
3. Right-click the folder and click "Open in Integrated Terminal."

All commands and files in this lab should be created and run inside the `lab5` directory.

---

## Part 1: Using the Time Import

Sentinel's open-source CLI supports mocking the `time` import, which allows you to write policies based on the current (mocked) time. This is useful for simulating time-based access controls, maintenance windows, or any policy that depends on the time of day.

### 1. Basic Time Policy

**What we're doing:**
This example shows how to write a policy that only allows actions before noon. This is a common pattern for restricting operations to business hours or maintenance windows.

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

**Why this is useful:**
This policy could be used to restrict deployments, updates, or other sensitive operations to morning hours only. By changing the mock data, you can test how your policy behaves at different times of day.

---

### 2. Policy with Minutes

**What we're doing:**
This example demonstrates how to check the current minute value. You might use this to allow or deny actions during certain parts of an hour, such as only allowing changes during the last half of each hour.

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

**Why this is useful:**
This policy could be used to allow certain operations only during specific windows within each hour. By adjusting the mock minute, you can test your policy's response to different times.

---

### 3. Combining Hour and Minute

**What we're doing:**
This example shows how to combine hour and minute checks for more precise control. For example, you might want to allow an operation only at a specific time, such as during a scheduled maintenance window.

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

**Why this is useful:**
This policy could be used to enforce a very specific time window for an operation, such as a nightly backup or a scheduled update. By changing the mock data, you can verify that your policy only passes at the intended time.

---

## Reflection and Best Practices

- **Why use time-based policies?** Time-based policies are useful for enforcing business rules, maintenance windows, or compliance requirements that depend on the time of day.
- **Why use mocks?** Mocks let you test your policies for different scenarios without waiting for the real time to change. This makes your policy development faster and more reliable.
- **How to test?** Always provide a `sentinel.hcl` file with a `mock "time"` block for your test data, and adjust the mock data to test different policy outcomes.

---

## Lab Completion

In this lab, you:
- Wrote policies using the `time` import
- Used mock data in `sentinel.hcl` to test different scenarios
- Practiced hands-on, fully runnable Sentinel policy development
- Learned why and how to use time-based checks in real policies

You now have practical experience writing Sentinel policies that are guaranteed to work in the open-source CLI! 