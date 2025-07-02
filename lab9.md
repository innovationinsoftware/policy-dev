# Lab 9: Working with External Data in Sentinel
## c. Mocking for Policy Testing

---

### Overview

In this lab, you will learn how to **mock external data sources** for Sentinel policy testing. This is essential for writing robust policies that depend on external data (such as Terraform plan data, cloud provider APIs, or custom imports). You'll use Sentinel's built-in test framework to simulate external data, ensuring your policies behave as expected in different scenarios.

---

### Context

Sentinel policies often rely on data from external sources, such as Terraform plans, state files, or custom imports. When testing policies, you need to control and simulate this data to verify your policy logic. Sentinel's test framework allows you to **mock** these data sources using JSON files, making your tests repeatable and reliable.

---

### Hands-On Tasks

#### 1. Prepare a Simple Policy

Create a file named `external-data-policy.sentinel` with the following content:

```hcl
import "tfplan/v2" as tfplan

main = rule {
  # Only allow t2.micro instances
  all tfplan.resource_changes as _, rc {
    rc.type is "aws_instance" and rc.change.after.instance_type is "t2.micro"
  }
}
```

#### 2. Create a Mock Data File

Create a directory called `test` and inside it, create a file named `mock-t2micro.json` with the following content:

```json
{
  "resource_changes": [
    {
      "type": "aws_instance",
      "change": {
        "after": {
          "instance_type": "t2.micro"
        }
      }
    }
  ]
}
```

#### 3. Write a Sentinel Test File

In the same `test` directory, create a file named `external-data-policy-test.sentinel`:

```hcl
# Test that passes when only t2.micro is used
test "allow t2.micro" {
  mock tfplan.v2 as "mock-t2micro.json"
  policy = import "../external-data-policy.sentinel"
  assert policy.main
}
```

#### 4. Add a Negative Test Case

Create another mock file, `mock-t2large.json`:

```json
{
  "resource_changes": [
    {
      "type": "aws_instance",
      "change": {
        "after": {
          "instance_type": "t2.large"
        }
      }
    }
  ]
}
```

Add a test case to `external-data-policy-test.sentinel`:

```hcl
# Test that fails when a non-t2.micro instance is used
test "deny t2.large" {
  mock tfplan.v2 as "mock-t2large.json"
  policy = import "../external-data-policy.sentinel"
  assert not policy.main
}
```

#### 5. Run the Tests

From the directory containing your policy and `test` folder, run:

```sh
sentinel test
```

You should see output indicating that both tests ran, with one passing and one failing as expected.

---

### Expected Results

- The test with `mock-t2micro.json` should **pass** (policy allows t2.micro).
- The test with `mock-t2large.json` should **fail** (policy denies t2.large).
- Output should clearly show which tests passed and failed.

---

### Reflection & Challenge

- **Reflection:** Why is mocking external data important for policy testing? How does it help ensure your policies are robust?
- **Challenge:**
  - Add a new test case for multiple resources, some allowed and some denied. Does your policy handle mixed cases correctly?
  - Try mocking other data sources (e.g., tfstate, custom imports) and write tests for those.

---

You have now learned how to mock external data for Sentinel policy testing, making your policy development process more reliable and repeatable. 