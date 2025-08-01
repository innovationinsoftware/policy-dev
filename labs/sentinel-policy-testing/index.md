# HashiCorp Sentinel Lab: Policy Testing and Simulation

## Overview
In this lab, you'll learn how to thoroughly test and simulate Sentinel policies using the officially supported `time` import and mock data, as shown in the [Sentinel documentation](https://developer.hashicorp.com/sentinel/docs/writing/testing). You'll use Sentinel's built-in testing framework to write test cases, simulate different times, organize your tests, and ensure your policies behave as expected in a variety of scenarios. By the end, you'll be able to confidently validate policies, catch issues early, and follow best practices for policy testing—all with fully runnable examples in the open-source CLI.

---

## Lab Setup

Create and move into a working directory for this lab:

```bash
mkdir policy-testing
cd policy-testing
```
All commands and files in this lab should be created and run inside the `policy-testing` directory.

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

Sentinel is opinionated about test organization. **Test files must be placed in a `test/<policy>/` directory, where `<policy>` is the name of your policy file without the extension.** Each test case is a separate `.hcl` file in that directory. See the [official documentation](https://developer.hashicorp.com/sentinel/docs/writing/testing) for details.

### 1. Create a Time-Based Policy to Test

**What we're doing:**
We'll write a policy that only allows actions before noon, using the `time` import. This is a common pattern for restricting operations to business hours or maintenance windows.

1. Create a file named `time-policy.sentinel`:
   ```hcl
   import "time"
   main = rule { time.now.hour < 12 }
   ```
   **Explanation:**
   This policy will return `true` if the current (mocked) hour is less than 12, and `false` otherwise. We'll use this to test different time scenarios.

---

### 2. Create the Test Directory and Test Cases

**What we're doing:**
We'll create a directory for our policy's tests and add individual test case files. Each test will specify a different time and the expected result for `main`.

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
   **Explanation:**
   Here, the mocked time is 9:42am. Since 9 < 12, the policy will return `true` for `main`. The test expects `main = true`, so this test will PASS.

3. Create a test case file for 1pm (should pass, expect `main = false`):
   Create `test/time-policy/pass-1pm.hcl`:
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
   **Explanation:**
   Here, the mocked time is 1:00pm (13:00). Since 13 >= 12, the policy will return `false` for `main`. The test expects `main = false`, so this test will PASS.

4. Create a test case file for noon (should pass, expect `main = false`):
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
   **Explanation:**
   Here, the mocked time is exactly noon (12:00). Since 12 is not less than 12, the policy will return `false` for `main`. The test expects `main = false`, so this test will PASS.

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
   **Explanation:**
   Here, the mocked time is midnight (0:00). Since 0 < 12, the policy will return `true` for `main`. The test expects `main = true`, so this test will PASS.

**Summary:**
- Each test file sets a different time and specifies the expected result for `main`.
- If the policy returns the expected value, the test will PASS.
- If the policy returns a different value, the test will FAIL.

---

## Part 3: Demonstrating a Failing Test

**What we're doing:**
We'll create a test case that is intentionally incorrect (the expected value does not match what the policy will return), to show how Sentinel reports a FAIL.

1. Create a test case file for 9am (should FAIL):
   Create `test/time-policy/fail-9am.hcl`:
   ```hcl
   mock "time" {
     data = {
       now = {
         hour = 9
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
   **Explanation:**
   Here, the mocked time is 9:00am. The policy will return `true` for `main` (since 9 < 12), but the test expects `main = false`. This mismatch will cause Sentinel to report this test as FAIL.

**Summary:**
- If the expected value in the test file does not match the policy's output, Sentinel will report a FAIL for that test case.
- This is useful for verifying that your policy fails when it should, and for catching mistakes in your logic or test setup.

---

## Part 4: Running the Tests

**What we're doing:**
We'll run all the test cases for our policy using the Sentinel CLI.

1. From the `policy-testing` directory, run:
   ```bash
   sentinel test
   ```
   or to test a specific policy:
   ```bash
   sentinel test time-policy.sentinel
   ```
   You should see output indicating which tests passed or failed, along with the test file names. If you included the intentionally failing test, you will see a FAIL for that case.

**Why this is useful:**
This lets you quickly verify your policy logic for a variety of scenarios, and the test output will show you exactly which cases pass or fail.

---

## Part 5: Debugging and Test Output

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
- Demonstrated both passing and failing test cases

You now have the skills to confidently test, simulate, and maintain Sentinel policies in real-world environments using the open-source CLI! 
