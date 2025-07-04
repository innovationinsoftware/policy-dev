# HashiCorp Sentinel Lab 6: Policy Testing and Simulation

## Overview
In this lab, you'll learn how to thoroughly test and simulate Sentinel policies using the officially supported `time` import and mock data, as shown in the [Sentinel documentation](https://developer.hashicorp.com/sentinel/docs/writing/testing). You'll use Sentinel's built-in testing framework to write test cases, simulate different times, organize your tests, and ensure your policies behave as expected in a variety of scenarios. By the end, you'll be able to confidently validate policies, catch issues early, and follow best practices for policy testing—all with fully runnable examples in the open-source CLI.

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
- Simulate real-world scenarios (like different times of day)
- Ensure policies are robust and reliable
- Build confidence in your policy-as-code workflows

Sentinel provides a testing framework that lets you define test cases and expected outcomes for your policies. Good testing is essential for safe, predictable infrastructure changes.

---

## Part 2: Writing Policy Tests

Sentinel is opinionated about test organization. **Test files must be placed in a `test/<policy>/` directory, where `<policy>` is the name of your policy file without the extension.** Each test case is a separate `.hcl` file in that directory. See the [official documentation](https://developer.hashicorp.com/sentinel/docs/writing/testing) for details.

### 1. Create a Time-Based Policy to Test

**What we're doing:**
We'll write a policy that only allows actions before noon, using the `time` import. This is a common pattern for restricting operations to business hours or maintenance windows.

1. Create a file named `time-policy.sentinel`:
   ```hcl
   import "time"
   main = rule { time.now.hour < 12 }
   ```

---

### 2. Create the Test Directory and Test Cases

**What we're doing:**
We'll create a directory for our policy's tests and add individual test case files.

1. Create the test directory:
   ```bash
   mkdir -p test/time-policy
   ```
2. Create a test case file for 9am (should pass):
   Create `test/time-policy/pass-9am.hcl`:
   ```hcl
   mock "time" {
     data = {
       now = {
         hour = 9
         minute = 42
       }
     }
   }
   test {
     rules = {
       main = true
     }
   }
   ```
3. Create a test case file for 1pm (should fail):
   Create `test/time-policy/fail-1pm.hcl`:
   ```hcl
   mock "time" {
     data = {
       now = {
         hour = 13
         minute = 0
       }
     }
   }
   test {
     rules = {
       main = false
     }
   }
   ```
4. Create a test case file for noon (should fail):
   Create `test/time-policy/edge-noon.hcl`:
   ```hcl
   mock "time" {
     data = {
       now = {
         hour = 12
         minute = 0
       }
     }
   }
   test {
     rules = {
       main = false
     }
   }
   ```
5. Create a test case file for midnight (should pass):
   Create `test/time-policy/pass-midnight.hcl`:
   ```hcl
   mock "time" {
     data = {
       now = {
         hour = 0
         minute = 0
       }
     }
   }
   test {
     rules = {
       main = true
     }
   }
   ```

**Why this is useful:**
By writing separate test files for different times, you can be sure your policy behaves as expected for all relevant scenarios, not just the current time.

---

## Part 3: Running the Tests

**What we're doing:**
We'll run all the test cases for our policy using the Sentinel CLI.

1. From the `lab6` directory, run:
   ```bash
   sentinel test
   ```
   or to test a specific policy:
   ```bash
   sentinel test time-policy.sentinel
   ```
   You should see output indicating which tests passed or failed, along with the test file names.

**Why this is useful:**
This lets you quickly verify your policy logic for a variety of scenarios, and the test output will show you exactly which cases pass or fail.

---

## Part 4: Simulating Policy Inputs (with the Time Import)

You can use the `sentinel apply` command with different mock data in `sentinel.hcl` to simulate how your policy behaves at different times. This is useful for ad-hoc testing and for simulating edge cases.

### 4. Simulate Different Times

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

## Part 5: Advanced Testing Features (with the Time Import)

Sentinel's testing framework supports more advanced features, such as custom messages, negative tests, and test file organization.

### 5. Add More Test Cases and Edge Cases

**What we're doing:**
We'll add more test case files to cover edge times and clarify the expected outcome.

1. Add a test case for 11:59am (should pass):
   Create `test/time-policy/pass-1159am.hcl`:
   ```hcl
   mock "time" {
     data = {
       now = {
         hour = 11
         minute = 59
       }
     }
   }
   test {
     rules = {
       main = true
     }
   }
   ```
2. Add a test case for 12:01pm (should fail):
   Create `test/time-policy/fail-1201pm.hcl`:
   ```hcl
   mock "time" {
     data = {
       now = {
         hour = 12
         minute = 1
       }
     }
   }
   test {
     rules = {
       main = false
     }
   }
   ```
3. Rerun the tests and observe the output messages.

**Why this is useful:**
Testing edge cases (like just before and after noon) ensures your policy logic is robust and behaves as intended in all scenarios.

---

## Part 6: Organizing and Running Multiple Policies

As your policy library grows, you may want to organize tests for different policies or scenarios. Repeat the above structure for each policy you want to test.

**What we're doing:**
We'll show how to organize and run multiple test files for different time-based policies.

1. For each policy (e.g., `minute-policy.sentinel`), create a corresponding test directory (e.g., `test/minute-policy/`) and add `.hcl` test case files there.
2. Run all tests in the directory:
   ```bash
   sentinel test
   ```

**Why this is useful:**
Keeping your tests organized makes it easier to maintain and expand your policy codebase as it grows.

---

## Part 7: Test Coverage and Best Practices

Testing is most effective when you cover a wide range of scenarios:
- Valid and invalid times
- Edge cases (just before/after a threshold)
- Typical real-world times

**Challenge:**
Write a comprehensive set of test files for a time-based policy that covers:
- All valid cases
- All expected failure cases
- At least one edge case

**Reflection:**
- How confident are you that your policy will behave correctly in production?
- What additional tests could you add to increase your confidence?

---

## Part 8: Debugging and Test Output

Sentinel provides detailed output for failed tests, including which rule failed and why. You can use the `-verbose` flag for more information.

**What we're doing:**
We'll run tests in verbose mode to see more details about failures.

1. Run:
   ```bash
   sentinel test -verbose
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