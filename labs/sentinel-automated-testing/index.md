# Automated Sentinel Policy Testing with GitHub Actions

---

## Overview

In this lab, you'll set up automated testing for your Sentinel policies using GitHub Actions. This ensures that every change to your policies or mock data is automatically tested in CI, and that pull requests cannot be merged unless all policy tests pass.

---

## Prerequisites

- **You must use your forked `learn-terraform-enforce-policies` GitHub repository, which contains your Sentinel policies, test cases, and mock data from previous labs.**
- Your repo includes a `sentinel.hcl` file and a `test/` directory with `.hcl` test files.
- This repository will be referred to as your **Sentinel policy repository** throughout this lab.

---

## 1. Create a GitHub Actions Workflow

1. In your forked `learn-terraform-enforce-policies` repository, create the directory structure:
   ```
   .github/workflows/
   ```
2. Create a new file/folder structure: `.github/workflows/sentinel-test.yml`

---

## 2. Add the Workflow YAML

Paste the following example workflow into `sentinel-test.yml`:

```yaml
name: Sentinel Policy Tests

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  sentinel-test:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout repository
        uses: actions/checkout@v3

      - name: Download Sentinel CLI
        run: |
          curl -sLo sentinel.zip https://releases.hashicorp.com/sentinel/0.24.0/sentinel_0.24.0_linux_amd64.zip
          unzip sentinel.zip
          sudo mv sentinel /usr/local/bin/
          sentinel version

      - name: Run Sentinel tests
        run: |
          sentinel test
```

---

## 3. How It Works

- The workflow runs on every push and pull request to the `main` branch of your forked `learn-terraform-enforce-policies` repository.
- It checks out your code, downloads and installs the Sentinel CLI, and runs `sentinel test`.
- If any policy test fails, the workflow fails and the PR cannot be merged until all tests pass.

---

## 4. View Results in GitHub Actions

- Go to the **Actions** tab in your forked `learn-terraform-enforce-policies` repository on GitHub.
- Click on the latest workflow run to see the output of the `sentinel test` step.
- You will see which tests passed or failed, just like running locally.
- Because we have fail.hcl configured for the terraform version check, the tests will fail and also trigger a pipeline failure

---

## 5. Fix Failing Tests and Re-run the Pipeline

- Delete the `fail.hcl` file from your test directory (e.g., `test/allowed-terraform-version/fail.hcl`).
- Commit and push this change to your forked `learn-terraform-enforce-policies` repository.
- The GitHub Actions pipeline will re-run and should now succeed, since all remaining tests are expected to pass.
- This demonstrates how fixing or removing failing tests results in a passing CI pipeline.

---

## 5. Best Practices

- Require the Sentinel test workflow to pass before merging pull requests (set this in your repo's branch protection rules).
- Keep your mock data and test cases up to date with your policies.
- Use separate jobs or matrix builds if you want to test multiple policy sets or configurations.

---

## Summary

You now have automated Sentinel policy testing in GitHub Actions for your forked `learn-terraform-enforce-policies` repository. This ensures your policies are always tested and helps prevent broken or untested policies from being merged. 