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
4. Extract the tarball into a `testdata/` directory in the `learn-terraform-enforce-policies` directory using:

   ```sh
   tar -zxvf <tarball-file> -C learn-terraform-enforce-policies/testdata/
   ```

6. Create a `test/allowed-terraform-version` directory, with a `pass.hcl` and `fail.hcl` underneath it. The structure should look like this:
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

#### 3. Update Your Policy to Use v2 Imports, and Reset the terraform version.

1. Open the `allowed-terraform-version.sentinel` file in your policy repository.
2. **Replace the contents with your 'allowed-terraform-version.sentinel' with the content below:**
   ```sentinel
   import "tfplan/v2" as tfplan
   import "version"

   # This regular expression checks whether the Terraform version used for the plan is 0.14+, 0.15+, or 1.0+

   main = rule {
       version.new(tfplan.terraform_version).greater_than("1.1.0")
   }
   ```
   This ensures your policy uses the correct import for the v2 mock data.

#### 4. Write and Run Policy Tests with Mocks

1. Open the file `test/allowed-terraform-version/pass.hcl` and **add the following content**:
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

---

### 6. Add and Test a Policy for a Security Group Resource

In this section, you'll create and test a Sentinel policy that checks that the specific security group resource `module.app_security_group.module.sg.aws_security_group.this_name_prefix[0]` has a description containing the word "web-servers".

1. **Create a new policy file:**
   - In the root of your policy repo, create `require-sg-description.sentinel`.

2. **Add the policy logic to the file:**
   ```sentinel
   import "tfplan/v2" as tfplan

   main = rule {
     all tfplan.resource_changes as _, rc {
       rc.address != "module.app_security_group.module.sg.aws_security_group.this_name_prefix[0]" or
       (rc.change.after.description is defined and rc.change.after.description contains "web-servers")
     }
   }
   ```
   - This policy only checks the description of the specific resource.

3. **Create test files:**
   - Create a directory: `test/require-sg-description/`
   - Create `pass.hcl` with the following content:
     ```hcl
     mock "tfplan/v2" {
       module {
         source = "../../testdata/mock-tfplan-v2.sentinel"
       }
     }
     test {
       rules = {
         main = true
       }
     }
     ```

4. **Run your tests:**
   - From your repo root, run:
     ```sh
     sentinel test
     ```
   - You should see a passing result for `pass.hcl` if your mock data for that resource matches the policy logic.

5. **Make the test fail by modifying the mock:**
   - Open `testdata/mock-tfplan-v2.sentinel` and find the resource with the address `module.app_security_group.module.sg.aws_security_group.this_name_prefix[0]`. Do this by searching for "resource_changes" within the mock file. It should be the first instance of this resource beneath the "resource_changes" heading.
   - Change its `description` value so it does **not** contain the string `web-servers`. For example:
     ```python
     "description": "Security group for application servers with HTTP ports open within VPC",
     ```
   - Save the file and rerun:
     ```sh
     sentinel test
     ```
   - Now, the test should fail, demonstrating that the policy correctly detects when the description does not match the requirement.

### Expected Results

- You can generate and use mock data from real Terraform runs.
- You can run Sentinel policy tests locally using the CLI and mock data.
- You understand how to simulate both passing and failing scenarios before enforcing policies in HCP Terraform.
---