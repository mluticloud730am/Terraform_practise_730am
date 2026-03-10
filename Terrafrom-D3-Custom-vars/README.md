# Day 3 — Terraform: Multi-Provider Setup with Variables & tfvars

## Overview

This session focused on provisioning EC2 instances across **two different AWS environments (Dev & Test)** using multiple AWS provider aliases, variable files, and tfvars — with real issues encountered and resolved along the way.

---

## File Structure

```
.
├── main.tf           # EC2 instance resources for dev and test
├── provider.tf       # AWS provider configurations with aliases
├── variables.tf      # Variable declarations for dev and test
├── dev.auto.tfvars   # Dev environment variable values
└── test.auto.tfvars  # Test environment variable values
```

---

## What Was Built

### `provider.tf` — Multiple Provider Aliases

Three AWS providers were configured:

- **Default** → `us-east-1` (default profile)
- **`dev_env`** → `us-west-2` (dev_env profile)
- **`test_env`** → `us-west-2` (test_env profile)

```hcl
provider "aws" {
  region  = "us-east-1"
  profile = "default"
}

provider "aws" {
  region  = "us-west-2"
  alias   = "dev_env"
  profile = "dev_env"
}

provider "aws" {
  region  = "us-west-2"
  alias   = "test_env"
  profile = "test_env"
}
```

### `variables.tf` — Separate Variables for Dev & Test

Each environment has its own AMI and instance type variables with empty defaults.

```hcl
variable "ami_id"             { type = string; default = "" }
variable "instance_type"      { type = string; default = "" }
variable "test_ami_id"        { type = string; default = "" }
variable "test_instance_type" { type = string; default = "" }
```

### `dev.auto.tfvars` & `test.auto.tfvars` — Environment Values

Values are split into separate tfvars files and automatically loaded by Terraform.

| File                | Variable            | Value                  |
|---------------------|---------------------|------------------------|
| `dev.auto.tfvars`   | `ami_id`            | `ami-03caad32a158f72db` |
| `dev.auto.tfvars`   | `instance_type`     | `t2.micro`             |
| `test.auto.tfvars`  | `test_ami_id`       | `ami-03caad32a158f72db` |
| `test.auto.tfvars`  | `test_instance_type`| `t2.micro`             |

### `main.tf` — EC2 Resources with Provider Binding

Each instance is explicitly bound to its provider alias using `provider = aws.<alias>`.

```hcl
resource "aws_instance" "dev" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  provider               = aws.dev_env
  subnet_id              = "subnet-0fd2fc2b84b24cff8"
  vpc_security_group_ids = ["sg-044910c7a8c19aa3d"]
  tags = { name = "dev-instance" }
}

resource "aws_instance" "test" {
  ami                    = var.test_ami_id
  instance_type          = var.test_instance_type
  provider               = aws.test_env
  subnet_id              = "subnet-0fd2fc2b84b24cff8"
  vpc_security_group_ids = ["sg-044910c7a8c19aa3d"]
  tags = { name = "test-instance" }
}
```

---

## Issues Encountered & Fixes

### Issue 1: Incorrect Provider References in `main.tf`

**Problem:** The `provider` attribute in the resource blocks was not correctly pointing to the aliased providers, causing Terraform to use the wrong AWS account/region.

**Fix:** Explicitly set `provider = aws.dev_env` and `provider = aws.test_env` in each resource block to bind each instance to the correct provider alias.

---

### Issue 2: Variable Mismatches

**Problem:** Variable names declared in `variables.tf` did not exactly match what was used in `main.tf` or defined in the `.tfvars` files, leading to empty or undefined values.

**Fix:** Ensured consistent naming across all three files — `variables.tf`, `main.tf`, and the respective `.auto.tfvars` files.

---

### Issue 3: No Default VPC in `us-west-2`

**Problem:** When Terraform tried to launch instances in `us-west-2`, the region had **no default VPC**, causing the plan/apply to fail because there was no network to attach the instance to.

**Resolution Options Explored:**
- Creating a new VPC manually in `us-west-2`

**Final Fix:** Instead of relying on the default VPC, explicitly provided a `subnet_id` and `vpc_security_group_ids` in the resource block:

```hcl
subnet_id              = "subnet-0fd2fc2b84b24cff8"
vpc_security_group_ids = ["sg-044910c7a8c19aa3d"]
```

This bypassed the default VPC requirement and allowed `terraform plan` and `terraform apply` to succeed.

---

## Experiment: Named `.tfvars` Files with `-var-file` Flag

After the initial setup worked, a second test was done using **named tfvars files** (not `.auto.tfvars`) with an Ubuntu AMI to understand how Terraform handles variable precedence and state reconciliation.

### The tfvars Files Used

Both `dev.tfvars` and `test.tfvars` had the same content — but pointing to an Ubuntu AMI:

```hcl
# dev.tfvars / test.tfvars
ami_id        = "ami-0786adace1541ca80"   # Ubuntu AMI
instance_type = "t2.micro"
```

> **Note:** Unlike `*.auto.tfvars`, files named without `.auto.` in the name are **not loaded automatically**. They must be explicitly passed using `-var-file="filename.tfvars"`.

---

### Scenario 1 — Apply with `test.tfvars` only

```bash
terraform apply -var-file="test.tfvars"
```

**What happened:**

- Terraform loaded `test.tfvars` alongside the already auto-loaded `dev.auto.tfvars` and `test.auto.tfvars`
- The `ami_id` variable (used by the **test instance**) was **overridden** by `test.tfvars` with the Ubuntu AMI
- Terraform detected a drift in the test instance (Linux AMI → Ubuntu AMI) and replaced it
- The **dev instance was untouched** — its variables came from `dev.auto.tfvars` which was not overridden

**Result:**

| Instance | Before | After |
|---|---|---|
| `aws_instance.test` | Linux AMI (destroyed) | Ubuntu AMI (created) |
| `aws_instance.dev` | Linux AMI | Linux AMI (no change) ✅ |

This demonstrated that `-var-file` **merges** with already auto-loaded values, and only the variables defined in the passed file are overridden — making isolated, targeted updates possible.

---

### Scenario 2 — Apply with `dev.tfvars`

```bash
terraform apply -var-file="dev.tfvars"
```

**What happened:**

- Terraform loaded `dev.tfvars` which defined `ami_id` and `instance_type`
- These same variable names are used by **both** the dev and test resource blocks in `main.tf`
- `test.auto.tfvars` was also auto-loaded but its `test_ami_id` was now being compared against a state where the test instance had already been swapped to Ubuntu
- Terraform saw both instances as needing changes — it destroyed the existing Ubuntu test instance and the Linux dev instance, and re-created **both as Ubuntu**

**Result:**

| Instance | Before | After |
|---|---|---|
| `aws_instance.dev` | Linux AMI (destroyed) | Ubuntu AMI (created) |
| `aws_instance.test` | Ubuntu AMI (destroyed) | Ubuntu AMI (re-created) |

---

### Why Did Both Instances Get Replaced?

This is a key Terraform behaviour to understand:

> **Terraform always reconciles the entire state on every apply**, not just the resources whose variables changed.

When `dev.tfvars` was applied, Terraform evaluated the full desired state across all resources. Since `ami_id` in `dev.tfvars` pointed to the Ubuntu AMI and that variable feeds into the dev instance, Terraform destroyed and re-created it. The test instance was also caught up in reconciliation because the state from the previous apply (Ubuntu) no longer matched what the combined variable set now described.

**Root cause:** Both resource blocks shared the same variable names (`ami_id`, `instance_type`), so overriding them with `-var-file` affected both environments simultaneously.

**Lesson:** When managing multiple environments in a single Terraform workspace, use **distinct variable names per environment** (e.g., `dev_ami_id`, `test_ami_id`) or better yet, use **separate workspaces or state files** per environment to avoid unintended cross-environment changes.

---

### Variable Loading Order & Precedence

Terraform loads variables in this order (later sources win):

| Priority | Source |
|---|---|
| 1 (lowest) | `default` values in `variables.tf` |
| 2 | `terraform.tfvars` (auto-loaded if present) |
| 3 | `*.auto.tfvars` files (auto-loaded alphabetically) |
| 4 | `-var-file="filename.tfvars"` (explicitly passed) |
| 5 (highest) | `-var="key=value"` inline flags |

In this experiment, `test.tfvars` passed via `-var-file` had **higher precedence** than `test.auto.tfvars`, which is why it overrode the AMI for the test instance.

---

## Key Learnings

| Concept | Takeaway |
|---|---|
| Provider aliases | Use `alias` in provider block + `provider = aws.<alias>` in resource to target specific environments |
| `.auto.tfvars` | Files ending in `.auto.tfvars` are auto-loaded — no need to pass `-var-file` flag |
| Named `.tfvars` | Files like `dev.tfvars` must be explicitly passed with `-var-file="dev.tfvars"` |
| Variable precedence | `-var-file` overrides `.auto.tfvars` which overrides `variables.tf` defaults |
| Shared variable names | If two environments use the same variable name, overriding it affects both — always use distinct names per environment |
| Terraform full-state reconciliation | Every `apply` reconciles the **entire** state, not just changed resources — partial updates can cause unintended replacements |
| Separate variable sets | Prefix variables per environment (e.g., `test_ami_id`) to avoid collisions and unintended destroy/recreate cycles |
| Default VPC dependency | Not all regions have a default VPC — always explicitly provide `subnet_id` and security groups in production configs |
| Provider binding is mandatory | Without `provider = aws.<alias>`, resources fall back to the default provider, deploying to the wrong region/account |

---

## Commands Used

```bash
terraform init                            # Initialize providers
terraform validate                        # Check config syntax
terraform plan                            # Preview changes (uses auto-loaded tfvars)
terraform apply                           # Apply (uses auto-loaded tfvars)
terraform apply -var-file="test.tfvars"   # Apply with explicit tfvars (overrides auto)
terraform apply -var-file="dev.tfvars"    # Apply with dev-specific tfvars
terraform destroy                         # Tear down all resources
```
