# HashiCorp Sentinel Lab 6: Policy Testing and Simulation

## Overview
In this lab, you'll learn how to thoroughly test and simulate Sentinel policies using the officially supported `time` import and mock data, as shown in the [Sentinel documentation](https://developer.hashicorp.com/sentinel/docs/configuration#mock-imports). You'll use Sentinel's built-in testing framework to write test cases, simulate different times, organize your tests, and ensure your policies behave as expected in a variety of scenarios. By the end, you'll be able to confidently validate policies, catch issues early, and follow best practices for policy testing—all with fully runnable examples in the open-source CLI.

---

## Lab Setup

Create and move into a working directory for this lab:

```bash
mkdir lab6
cd lab6
```
All commands and files in this lab should be created and run inside the `lab6` directory.

---

## Part 1: Why Test Policies?

Testing policies helps you:
- Catch logic errors before deployment
- Simulate real-world scenarios
- Ensure policies are robust and reliable
- Build confidence in your policy-as-code workflows

Sentinel provides a testing framework that lets you define test cases and expected outcomes for your policies. Good testing is essential for safe, predictable infrastructure changes.

---

## Part 2: Writing Policy Tests

Sentinel test files use the `.test` extension and are placed alongside your policy files. Test files define cases with mock data and expected results. You can write as many test cases as you need to cover different scenarios.

### 1. Create a Time-Based Policy to Test

**What we're doing:**
We'll write a policy that only allows actions before noon, using the `time` import. This is a common pattern for restricting operations to business hours or maintenance windows.

1. Create a file named `time-policy.sentinel`:
   ```hcl
   import "time"
   main = rule { time.now.hour < 12 }
   ```

---

### 2. Write a Test File for the Time Policy

**What we're doing:**
We'll write test cases that simulate different times of day and check if the policy passes or fails as expected.

1. Create a file named `time-policy.test`:
   ```hcl
   test { mock = { "time": { "now": { "hour": 9, "minute": 42 } } } expect = true  message = "Should pass for 9am" }
   test { mock = { "time": { "now": { "hour": 13, "minute": 0 } } } expect = false message = "Should fail for 1pm" }
   test { mock = { "time": { "now": { "hour": 12, "minute": 0 } } } expect = false message = "Should fail for noon" }
   test { mock = { "time": { "now": { "hour": 0, "minute": 0 } } } expect = true  message = "Should pass for midnight" }
   ```
2. Run the tests:
   ```bash
   sentinel test time-policy.sentinel
   ```
   You should see output indicating which tests passed or failed, along with the custom messages.

**Why this is useful:**
By writing tests for different times, you can be sure your policy behaves as expected for all relevant scenarios, not just the current time.

---

## Part 3: Simulating Policy Inputs (with the Time Import)

You can use the `sentinel apply` command with different mock data in `sentinel.hcl` to simulate how your policy behaves at different times. This is useful for ad-hoc testing and for simulating edge cases.

### 3. Simulate Different Times

**What we're doing:**
We'll change the mock time in `sentinel.hcl` and see how the policy responds.

1. Edit or create `sentinel.hcl`:
   ```hcl
   mock "time" {
     data = {
       now = {
         hour = 10
         minute = 30
       }
     }
   }
   ```
2. Run:
   ```bash
   sentinel apply time-policy.sentinel
   ```
   You should see `PASS` (since 10 < 12).
3. Change the hour to 14 and rerun. You should see `FAIL`.

**Why this is useful:**
This lets you quickly test your policy for any time of day, without waiting for the real clock to change.

---

## Part 4: Advanced Testing Features (with the Time Import)

Sentinel's testing framework supports more advanced features, such as custom messages, negative tests, and test file organization.

### 4. Add Custom Messages and Edge Cases

**What we're doing:**
We'll add more test cases to cover edge times and use custom messages to clarify the expected outcome.

1. Edit `time-policy.test` to:
   ```hcl
   test { mock = { "time": { "now": { "hour": 9,  "minute": 42 } } } expect = true  message = "Should pass for 9am" }
   test { mock = { "time": { "now": { "hour": 13, "minute": 0  } } } expect = false message = "Should fail for 1pm" }
   test { mock = { "time": { "now": { "hour": 12, "minute": 0  } } } expect = false message = "Should fail for noon" }
   test { mock = { "time": { "now": { "hour": 0,  "minute": 0  } } } expect = true  message = "Should pass for midnight" }
   test { mock = { "time": { "now": { "hour": 11, "minute": 59 } } } expect = true  message = "Should pass for 11:59am" }
   test { mock = { "time": { "now": { "hour": 12, "minute": 1  } } } expect = false message = "Should fail for 12:01pm" }
   ```
2. Rerun the tests and observe the output messages.

**Why this is useful:**
Testing edge cases (like just before and after noon) ensures your policy logic is robust and behaves as intended in all scenarios.

---

### 5. Organizing and Running Multiple Test Files

As your policy library grows, you may want to organize tests for different policies or scenarios.

**What we're doing:**
We'll show how to organize and run multiple test files for different time-based policies.

1. Create a directory called `tests/` and move your `.test` files there.
2. Place related test files together (e.g., `time-policy.test`, `minute-policy.test`).
3. Run all tests in the directory:
   ```bash
   sentinel test tests/
   ```

**Why this is useful:**
Keeping your tests organized makes it easier to maintain and expand your policy codebase as it grows.

---

## Part 5: Test Coverage and Best Practices

Testing is most effective when you cover a wide range of scenarios:
- Valid and invalid times
- Edge cases (just before/after a threshold)
- Typical real-world times

**Challenge:**
Write a comprehensive test file for a time-based policy that covers:
- All valid cases
- All expected failure cases
- At least one edge case

**Reflection:**
- How confident are you that your policy will behave correctly in production?
- What additional tests could you add to increase your confidence?

---

## Part 6: Debugging and Test Output

Sentinel provides detailed output for failed tests, including which rule failed and why. You can use the `-verbose` flag for more information.

**What we're doing:**
We'll run tests in verbose mode to see more details about failures.

1. Run:
   ```bash
   sentinel test time-policy.sentinel -verbose
   ```
2. Examine the output for failed tests. What information is provided?

**Why this is useful:**
Verbose output helps you quickly identify and fix logic errors in your policies.

---

## Lab Completion

In this lab, you:
- Wrote and ran comprehensive Sentinel policy tests using the `time` import
- Simulated policy behavior with a variety of mocked times
- Explored advanced testing features and test organization
- Practiced debugging and interpreting test output
- Learned best practices for time-based policy testing

You now have the skills to confidently test, simulate, and maintain Sentinel policies in real-world environments using the open-source CLI! 