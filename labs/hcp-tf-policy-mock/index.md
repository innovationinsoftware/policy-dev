# Developing and Testing Sentinel Policies with Mock Data

---

### Overview

In this lab, you will learn how to use **policy mocking** to safely develop and test Sentinel policies for HCP Terraform. You’ll generate mock data from a real Terraform run, use it to simulate policy checks locally with the Sentinel CLI, and write test cases to validate your policy logic. This approach allows you to catch errors and edge cases before enforcing policies in your organization.

---

### Prerequisites

- Completion of the day 3 labs:
    - HCP Terraform CLI authentication and workspace setup
    - Enforcing Sentinel policies in HCP Terraform
    - Using the CIS Policy Set for AWS
- A working HCP Terraform workspace with at least one successful run
- Sentinel CLI installed locally ([download here](https://developer.hashicorp.com/sentinel/downloads))
- Access to your policy repository (forked from previous labs)

---

### Hands-On Tasks

#### 1. Generate Mock Data from a Terraform Run

1. In the HCP Terraform UI, navigate to your workspace and select a recent successful run (a run that has been successfully applied).
2. Expand the **Plan** section of the run details.
3. Click the **Download Sentinel mocks** button.
   - This will download a tarball containing files like `mock-tfplan-v2.sentinel`, `mock-tfconfig-v2.sentinel`, `mock-tfstate-v2.sentinel`, and `mock-tfrun.sentinel`.
   - **Note:** If the button is not visible, ensure you have the correct permissions and the run completed successfully. See [official docs](https://developer.hashicorp.com/terraform/cloud-docs/policy-enforcement/test-sentinel) for troubleshooting.
4. Extract the tarball into a `testdata/` directory in the `learn-terraform-enforce-policies` directory (your policy repository root). The structure should look like this:
   ```
   learn-terraform-enforce-policies/
   ├── allowed-terraform-version.sentinel
   ├── sentinel.hcl
   ├── testdata/
   │   ├── mock-tfplan-v2.sentinel
   │   ├── mock-tfconfig-v2.sentinel
   │   ├── mock-tfstate-v2.sentinel
   │   └── mock-tfrun.sentinel
   └── test/
       └── allowed-terraform-version/
           ├── pass.hcl
           └── fail.hcl
   ```

#### 2. Organize Your Policy Test Structure

1. Ensure your `sentinel.hcl` file is configured to reference the mock data for local testing. Add the following content to your `sentinel.hcl` file (replace any existing mock blocks for these sources):
   ```hcl
   mock "tfplan/v2" {
     module {
       source = "testdata/mock-tfplan-v2.sentinel"
     }
   }
   mock "tfconfig/v2" {
     module {
       source = "testdata/mock-tfconfig-v2.sentinel"
     }
   }
   mock "tfstate/v2" {
     module {
       source = "testdata/mock-tfstate-v2.sentinel"
     }
   }
   mock "tfrun" {
     module {
       source = "testdata/mock-tfrun.sentinel"
     }
   }
   ```

#### 3. Update Your Policy to Use v2 Imports

1. Open the `allowed-terraform-version.sentinel` file in your policy repository.
2. **Change the import statement to use the v2 import, matching the mock files.** Replace any line like:
   ```sentinel
   import "tfplan"
   ```
   with:
   ```sentinel
   import "tfplan/v2" as tfplan
   ```
   This ensures your policy uses the correct import for the v2 mock data.

#### 4. Write and Run Policy Tests with Mocks

1. Create or open the file `test/allowed-terraform-version/pass.hcl` and **replace its contents** with the following:
   ```hcl
   mock "tfplan/v2" {
     module {
       source = "../../testdata/mock-tfplan-v2.sentinel"
     }
   }
   mock "tfconfig/v2" {
     module {
       source = "../../testdata/mock-tfconfig-v2.sentinel"
     }
   }
   mock "tfstate/v2" {
     module {
       source = "../../testdata/mock-tfstate-v2.sentinel"
     }
   }
   mock "tfrun" {
     module {
       source = "../../testdata/mock-tfrun.sentinel"
     }
   }

   test {
     rules = {
       main = true
     }
   }
   ```
   > **Copy and paste the entire block above into `test/allowed-terraform-version/pass.hcl`.**

2. To simulate a failing scenario, create or open `test/allowed-terraform-version/fail.hcl` and add similar mock blocks, but set `main = false` in the `test` block:
   ```hcl
   mock "tfplan/v2" {
     module {
       source = "../../testdata/mock-tfplan-v2.sentinel"
     }
   }
   mock "tfconfig/v2" {
     module {
       source = "../../testdata/mock-tfconfig-v2.sentinel"
     }
   }
   mock "tfstate/v2" {
     module {
       source = "../../testdata/mock-tfstate-v2.sentinel"
     }
   }
   mock "tfrun" {
     module {
       source = "../../testdata/mock-tfrun.sentinel"
     }
   }

   test {
     rules = {
       main = false
     }
   }
   ```
   > **Copy and paste the entire block above into `test/allowed-terraform-version/fail.hcl` if you want to test a failing scenario.**

3. Run your tests locally from the root of your policy repository:
   ```sh
   sentinel test
   ```
   - You will see results for both pass.hcl and fail.hcl in the output because Sentinel runs each test file in the directory and reports the result for each.
   - Each test result corresponds to a .hcl file (like pass.hcl or fail.hcl).
   - **PASS** means the policy returned the expected result for that test case.
   - **FAIL** means the policy did not return the expected result—usually because the mock data in that .hcl file does not trigger the expected policy outcome.

#### 5. Modify the Policy and Observe Test Results

1. Open `allowed-terraform-version.sentinel` and change the version check to require a higher version (for example, `greater_than("9.9.9")`).
2. Rerun `sentinel test` and observe that pass.hcl now fails, but fail.hcl passes.
   
   When you make the policy stricter, the mock data in pass.hcl no longer meets the requirement (so it fails), while fail.hcl now matches the expected failure (so it passes). This demonstrates how changing policy logic affects which test cases pass or fail.
3. Restore the original logic and confirm the test passes again.

#### 6. Create Edge Case Mocks

- Edit the mock files in `testdata/` to simulate unusual or edge-case scenarios (e.g., missing attributes, unexpected values).
- Add new test cases in the `test/allowed-terraform-version/` directory to cover these scenarios, using the same structure as above.

---

### Expected Results

- You can generate and use mock data from real Terraform runs.
- You can run Sentinel policy tests locally using the CLI and mock data.
- You understand how to simulate both passing and failing scenarios before enforcing policies in HCP Terraform.

---

### Reflection & Challenge

- **Reflection:** How does policy mocking improve the safety and reliability of Sentinel policy enforcement in your organization?
- **Challenge:** Create a new mock scenario that would cause your policy to fail, and write a test case to assert the expected outcome.

---

### References

- [HashiCorp Docs: Test Sentinel policies & generate mock data](https://developer.hashicorp.com/terraform/cloud-docs/policy-enforcement/test-sentinel) 

#### 7. Add and Test a New Basic Policy: Require Owner Tag

In this section, you'll create and test a new Sentinel policy that enforces all resources must have an "owner" tag.

1. **Create a new policy file:**
   - In your policy repo, create `require-owner-tag.sentinel`.

2. **Write the policy logic:**
   ```sentinel
   import "tfplan/v2" as tfplan

   # Get all resources in the plan
   resources = tfplan.resource_changes

   # Check if every resource has an "owner" tag (if tags exist)
   main = rule {
     all resources as r {
       not r.change.after is undefined and
       ("tags" in r.change.after ? "owner" in r.change.after.tags : true)
     }
   }
   ```
   - This policy passes if every resource either has no tags (optional) or has an "owner" tag.

3. **Create mock data:**
   - Copy your existing `mock-tfplan-v2.sentinel` to `mock-tfplan-owner-tag.sentinel`.
   - Edit the resource(s) in the mock so that in one version, all resources have an `owner` tag (for pass), and in another, at least one resource is missing the `owner` tag (for fail).

4. **Write test cases:**
   - Create a directory: `test/require-owner-tag/`
   - Create `pass.hcl`:
     ```hcl
     mock "tfplan/v2" {
       module {
         source = "../../testdata/mock-tfplan-owner-tag.sentinel"
       }
     }
     mock "tfconfig/v2" {
       module {
         source = "../../testdata/mock-tfconfig-v2.sentinel"
       }
     }
     mock "tfstate/v2" {
       module {
         source = "../../testdata/mock-tfstate-v2.sentinel"
       }
     }
     mock "tfrun" {
       module {
         source = "../../testdata/mock-tfrun.sentinel"
       }
     }

     test {
       rules = {
         main = true
       }
     }
     ```
   - Create `fail.hcl` (point to a mock where at least one resource is missing the owner tag, or edit the mock accordingly):
     ```hcl
     mock "tfplan/v2" {
       module {
         source = "../../testdata/mock-tfplan-owner-tag.sentinel"
       }
     }
     mock "tfconfig/v2" {
       module {
         source = "../../testdata/mock-tfconfig-v2.sentinel"
       }
     }
     mock "tfstate/v2" {
       module {
         source = "../../testdata/mock-tfstate-v2.sentinel"
       }
     }
     mock "tfrun" {
       module {
         source = "../../testdata/mock-tfrun.sentinel"
       }
     }

     test {
       rules = {
         main = false
       }
     }
     ```

5. **Run your tests:**
   - From your repo root, run:
     ```sh
     sentinel test
     ```
   - You should see results for both `pass.hcl` and `fail.hcl` for the new policy.

6. **Explanation:**
   - This demonstrates how to add and test a new, basic Sentinel policy locally using custom mock data and test cases. 