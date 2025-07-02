# HashiCorp Sentinel Lab 6: Policy Testing and Simulation

## Overview
In this lab, you'll learn how to thoroughly test and simulate Sentinel policies before enforcing them in production. You'll use Sentinel's built-in testing framework to write test cases, simulate different inputs, organize your tests, and ensure your policies behave as expected in a variety of scenarios. By the end, you'll be able to confidently validate policies, catch issues early, and follow best practices for policy testing.

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

Sentinel test files use the `.test` extension and are placed alongside your policy files. Test files define cases with input data and expected results. You can write as many test cases as you need to cover different scenarios.

### 1. Create a Policy to Test
Let's start with a simple policy to restrict CPU count.

1. Create a file named `cpu-policy.sentinel`:
   ```hcl
   main = rule { input.cpu <= 4 }
   ```

---

### 2. Write a Test File
Test files use the `.test` extension and specify cases for your policy.

1. Create a file named `cpu-policy.test`:
   ```hcl
   test { input = { "cpu": 2 } expect = true }
   test { input = { "cpu": 8 } expect = false }
   ```
2. Run the tests:
   ```bash
   sentinel test cpu-policy.sentinel
   ```
You should see output indicating which tests passed or failed.

**Try this:**
- Add another test case with `cpu` set to 4.
- Change the policy to restrict CPUs to 2 and rerun the tests.
- Add a test with a missing `cpu` field. What happens?

**Reflection:**
How does writing tests help you catch policy errors early?

---

## Part 3: Simulating Policy Inputs

You can use the `sentinel apply` command with different input files to simulate how your policy behaves with real data. This is useful for ad-hoc testing and for simulating edge cases.

### 3. Simulate Different Inputs
1. Create a mock data file named `cpu-mock.json`:
   ```json
   { "cpu": 3 }
   ```
2. Run:
   ```bash
   sentinel apply cpu-policy.sentinel -input cpu-mock.json
   ```
Try changing the value of `cpu` and rerun to see how the policy responds.

**Try this:**
- Simulate edge cases, such as `cpu` set to 0, a negative number, or a very high number.
- Use input files from previous labs to test other policies.
- Try omitting the `cpu` field entirely. What error do you get?

**Challenge:**
Write a script that runs `sentinel apply` with a range of input values and summarizes the results.

---

## Part 4: Advanced Testing Features

Sentinel's testing framework supports more advanced features, such as multiple test files, custom messages, negative tests, and test file organization.

### 4. Add Custom Messages and Negative Tests
1. Edit `cpu-policy.test` to:
   ```hcl
   test { input = { "cpu": 2 } expect = true  message = "Should pass for 2 CPUs" }
   test { input = { "cpu": 8 } expect = false message = "Should fail for 8 CPUs" }
   test { input = { "cpu": -1 } expect = false message = "Should fail for negative CPU count" }
   test { input = { } expect = false message = "Should fail for missing CPU field" }
   ```
2. Rerun the tests and observe the output messages.

**Try this:**
- Add a test with a non-integer value for `cpu` (e.g., a string or null).
- Add a test with extra fields in the input. Does it affect the result?

**Reflection:**
Why is it important to test negative and edge cases?

---

### 5. Organizing and Running Multiple Test Files

As your policy library grows, you may want to organize tests for different policies or scenarios.

1. Create a directory called `tests/` and move your `.test` files there.
2. Place related test files together (e.g., `cpu-policy.test`, `region-policy.test`).
3. Run all tests in the directory:
   ```bash
   sentinel test tests/
   ```

**Try this:**
- Add a new test file for a data validation policy from a previous lab.
- Organize your test files by policy type or feature.

**Best Practice:**
Keep your tests organized and named clearly so you can quickly find and run them as your policy codebase grows.

---

## Part 5: Test Coverage and Best Practices

Testing is most effective when you cover a wide range of scenarios:
- Valid and invalid inputs
- Edge cases (minimum, maximum, missing values)
- Typical real-world data

**Challenge:**
Review a policy from a previous lab. Write a comprehensive test file that covers:
- All valid cases
- All expected failure cases
- At least one edge case

**Reflection:**
- How confident are you that your policy will behave correctly in production?
- What additional tests could you add to increase your confidence?

---

## Part 6: Debugging and Test Output

Sentinel provides detailed output for failed tests, including which rule failed and why. You can use the `-verbose` flag for more information.

1. Run:
   ```bash
   sentinel test cpu-policy.sentinel -verbose
   ```
2. Examine the output for failed tests. What information is provided?

**Try this:**
- Use the `-run` flag to run only a specific test case by name (if you've named your tests).
- Deliberately introduce a bug in your policy and see how the test output helps you debug it.

---

## Lab Completion

In this lab, you:
- Wrote and ran comprehensive Sentinel policy tests
- Simulated policy behavior with a variety of inputs
- Explored advanced testing features and test organization
- Practiced debugging and interpreting test output
- Reflected on best practices for policy testing

You now have the skills to confidently test, simulate, and maintain Sentinel policies in real-world environments! 