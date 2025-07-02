# Lab 10: Performance Optimization Techniques
## Version Control for Sentinel Policies

---

### Overview

In this lab, you will learn **Sentinel-specific version control techniques**. You'll see how to structure, version, and manage Sentinel policies using Git, and how to integrate with Terraform Cloud/Enterprise for automated policy deployment and auditing. This ensures your policy-as-code workflow is robust, traceable, and easy to maintain.

---

### Context

Sentinel policies are code, and should be managed like any other codebase. Using version control (Git) with Sentinel policies allows you to:
- Track every change to your policies
- Roll back to previous versions if a policy causes issues
- Audit who changed what and when (for compliance)
- Deploy policy sets automatically to Terraform Cloud/Enterprise via VCS integration

---

### Hands-On Tasks

#### 1. Organize Your Sentinel Policy Repository

Structure your repo for clarity and versioning:

```
.
├── policies/
│   ├── v1/
│   │   ├── restrict-instance-type.sentinel
│   │   └── ...
│   └── v2/
│       ├── restrict-instance-type.sentinel
│       └── ...
├── test/
│   └── ...
└── README.md
```

- Use versioned folders (`v1/`, `v2/`) for major policy changes.
- Document policy changes in `README.md` or a `CHANGELOG.md`.

#### 2. Tag Policy Versions in Git

After making significant changes, tag your repository:

```sh
git add policies/v2/*
git commit -m "Add v2 of Sentinel policies: updated restrict-instance-type logic"
git tag v2.0.0
git push --tags
```

#### 3. Integrate with Terraform Cloud/Enterprise

1. In Terraform Cloud, create or select a **Policy Set**.
2. Connect your Git repository as the source for the policy set.
3. Choose a branch or tag (e.g., `main` or `v2.0.0`) to deploy specific policy versions.
4. When you push changes or new tags, Terraform Cloud will automatically update the policy set.

#### 4. Roll Back a Policy Version

If a new policy version causes issues, you can roll back:

```sh
git checkout v1.0.0
# Or, in Terraform Cloud, point the policy set to the previous tag/commit
```

#### 5. Audit Policy Changes

View the history of a specific policy file:

```sh
git log -- policies/v2/restrict-instance-type.sentinel
```

See what changed between versions:

```sh
git diff v1.0.0 v2.0.0 -- policies/restrict-instance-type.sentinel
```

#### 6. (Optional) Automate Policy Testing in CI

Set up a CI workflow (e.g., GitHub Actions) to run `sentinel test` on every pull request:

```yaml
# .github/workflows/sentinel-test.yml
name: Sentinel Policy Test
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Install Sentinel
        run: |
          curl -sLo sentinel.zip https://releases.hashicorp.com/sentinel/0.18.10/sentinel_0.18.10_linux_amd64.zip
          unzip sentinel.zip
          sudo mv sentinel /usr/local/bin/
      - name: Run Sentinel tests
        run: sentinel test
```

---

### Expected Results

- Sentinel policies are organized and versioned in Git.
- You can tag, roll back, and audit policy changes.
- Policy sets in Terraform Cloud/Enterprise update automatically from your VCS.
- Policy changes are tested and reviewed before deployment.

---

### Reflection & Challenge

- **Reflection:** How does versioning and VCS integration improve Sentinel policy reliability and compliance?
- **Challenge:**
  - Set up a branch protection rule to require policy test passing before merging.
  - Try deploying a breaking policy change, then roll back using Git and confirm the rollback in Terraform Cloud.

---

You have now learned Sentinel-specific best practices for version control, policy set management, and automated deployment, ensuring your policy-as-code workflow is robust and auditable. 