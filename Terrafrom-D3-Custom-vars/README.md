# Day 3 — Terraform Hands-On: Multi-Provider Setup, Variables & tfvars

## What This Hands-On Covers

This hands-on walks through provisioning EC2 instances across two isolated AWS environments — **Dev** and **Test** — using a single Terraform configuration. Along the way you will learn how Terraform handles multiple providers, how variables and tfvars files work together, and what really happens under the hood when you run `terraform apply` with different variable inputs.

By the end of this, you will understand:
- How to use **provider aliases** to target different AWS accounts or regions
- The difference between **`.auto.tfvars`** and named **`.tfvars`** files
- How Terraform's **variable precedence** works
- Why Terraform sometimes replaces resources you didn't intend to touch — and how to prevent it

---

## The Goal

Provision two EC2 instances — one for Dev, one for Test — each managed by a separate AWS provider alias pointing to different AWS profiles. Both instances should be independently configurable without affecting each other.

---

## File Structure

```
.
├── main.tf              # EC2 instance resource definitions
├── provider.tf          # AWS provider blocks with aliases
├── variables.tf         # Variable declarations for dev and test
├── dev.auto.tfvars      # Dev environment values (auto-loaded)
├── test.auto.tfvars     # Test environment values (auto-loaded)
├── dev.tfvars           # Dev values for manual override (explicit)
└── test.tfvars          # Test values for manual override (explicit)
```

---

## Part 1 — Building the Configuration

### Step 1: `provider.tf` — Multiple AWS Providers with Aliases

When you write `provider "aws"` more than once in the same config, Terraform needs a way to tell them apart. That is where **aliases** come in. An alias gives each provider block a unique name so your resources can reference exactly which one to use.

```hcl
# Default provider — used if no alias is specified in a resource
provider "aws" {
  region  = "us-east-1"
  profile = "default"
}

# Dev environment — us-west-2 using the dev_env AWS profile
provider "aws" {
  region  = "us-west-2"
  alias   = "dev_env"
  profile = "dev_env"
}

# Test environment — us-west-2 using the test_env AWS profile
provider "aws" {
  region  = "us-west-2"
  alias   = "test_env"
  profile = "test_env"
}
```

> 💡 **Concept — Provider Alias:** Think of each provider block as a separate "connection" to AWS. The alias is its label. Without an alias, only one `aws` provider can exist in a config. With aliases, you can have as many as you need — each pointing to a different region, account, or profile.

---

### Step 2: `variables.tf` — Declaring Variables for Each Environment

Each environment gets its own dedicated set of variables. Notice the naming convention: dev variables use generic names (`ami_id`, `instance_type`) while test variables are prefixed with `test_`. This separation is intentional and becomes very important later in Part 3.

```hcl
### Dev Variables ###
variable "ami_id" {
  description = "AMI ID for the dev instance"
  type        = string
  default     = ""
}

variable "instance_type" {
  description = "Instance type for the dev instance"
  type        = string
  default     = ""
}

### Test Variables ###
variable "test_ami_id" {
  description = "AMI ID for the test instance"
  type        = string
  default     = ""
}

variable "test_instance_type" {
  description = "Instance type for the test instance"
  type        = string
  default     = ""
}
```

> 💡 **Concept — Declaration vs Assignment:** `variables.tf` only *declares* that a variable exists and its expected type. It does not supply the actual value — that happens in `.tfvars` files. Think of `variables.tf` as a contract: "these are the inputs this configuration accepts." The `.tfvars` files are what fulfill that contract with real values.

---

### Step 3: `dev.auto.tfvars` & `test.auto.tfvars` — Supplying the Values

These files assign actual values to the variables declared above. The `.auto.tfvars` suffix tells Terraform to load them **automatically** without any flags.

```hcl
# dev.auto.tfvars — Linux AMI for dev
ami_id        = "ami-03caad32a158f72db"
instance_type = "t2.micro"
```

```hcl
# test.auto.tfvars — Linux AMI for test
test_ami_id        = "ami-03caad32a158f72db"
test_instance_type = "t2.micro"
```

> 💡 **Concept — `.auto.tfvars`:** Any file ending in `.auto.tfvars` is picked up automatically when you run `terraform plan` or `terraform apply` — no flags needed. Terraform loads all such files alphabetically. This makes them ideal for baseline values you always want applied to an environment.

---

### Step 4: `main.tf` — Defining the EC2 Resources

This is where provider aliases and variables come together. Each resource explicitly declares which provider to use via the `provider` attribute, and references its own set of variables.

```hcl
resource "aws_instance" "dev" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  provider               = aws.dev_env          # Binds to the dev_env provider alias
  subnet_id              = "subnet-0fd2fc2b84b24cff8"
  vpc_security_group_ids = ["sg-044910c7a8c19aa3d"]

  tags = {
    name = "dev-instance"
  }
}

resource "aws_instance" "test" {
  ami                    = var.test_ami_id
  instance_type          = var.test_instance_type
  provider               = aws.test_env         # Binds to the test_env provider alias
  subnet_id              = "subnet-0fd2fc2b84b24cff8"
  vpc_security_group_ids = ["sg-044910c7a8c19aa3d"]

  tags = {
    name = "test-instance"
  }
}
```

> 💡 **Concept — `provider = aws.<alias>`:** Without this line, Terraform uses the default (un-aliased) provider for every resource. Adding `provider = aws.dev_env` explicitly routes that resource through the dev connection. This is what ensures each instance lands in the correct AWS account and region.

---

## Part 2 — Issues Encountered & How They Were Resolved

Real-world Terraform learning always comes with errors. Here are the three issues hit during this hands-on and what they taught us.

---

### Issue 1 — Provider Not Referenced Correctly in `main.tf`

**What went wrong:** The `provider` attribute was missing or incorrectly set in the resource blocks. Terraform either threw a configuration error or silently used the default provider, deploying the instance to the wrong region.

**The fix:** Explicitly add `provider = aws.dev_env` and `provider = aws.test_env` to each resource block.

**The lesson:** Terraform will never guess which aliased provider you intend to use. If you define aliases but don't reference them in your resources, those aliases are completely ignored and everything falls back to the default. Always be explicit about provider binding when aliases are involved.

---

### Issue 2 — Variable Name Mismatches Caused Silent Failures

**What went wrong:** Variable names in `variables.tf`, `main.tf`, and the `.tfvars` files didn't match exactly. For example, a variable declared as `ami_id` but referenced as `amiId` or assigned in a `.tfvars` file with a slightly different name. Terraform did not always throw an error — it silently fell back to the `default = ""` value instead, creating instances with no AMI specified.

**The fix:** Ensure the variable name is exactly the same across all three places — the declaration in `variables.tf`, the usage as `var.<name>` in `main.tf`, and the assignment in the `.tfvars` file.

**The lesson:** Variable names are case-sensitive and must match precisely. The dangerous part is that a mismatch won't always cause an obvious error — if a default value exists, Terraform happily uses it. Always double-check that your variable names are consistent across all files.

---

### Issue 3 — No Default VPC in `us-west-2`

**What went wrong:** `terraform apply` failed because the `us-west-2` region had no default VPC. AWS creates a default VPC in each region for new accounts, but this one was either deleted or the account was set up without it. Without a VPC and subnet, AWS has nowhere to place the instance and rejects the request.

**What was tried first:** Creating a new VPC manually in `us-west-2` via the AWS Console.

**The final fix:** Rather than relying on a default VPC, explicitly provide the `subnet_id` and `vpc_security_group_ids` directly in the resource block:

```hcl
subnet_id              = "subnet-0fd2fc2b84b24cff8"
vpc_security_group_ids = ["sg-044910c7a8c19aa3d"]
```

**The lesson:** Never assume a default VPC exists in a region — especially in production accounts or regions you haven't used before. Hardcoding or referencing explicit subnets and security groups is also better practice because it gives you full visibility and control over where your instances are placed and what traffic they allow.

---

## Part 3 — Experiment: Named `.tfvars` with `-var-file`

Once the base setup was working with Linux AMIs via `.auto.tfvars`, a second experiment tested **named `.tfvars` files** passed manually via the `-var-file` flag. The goal was to swap the AMI to Ubuntu and closely observe how Terraform handles variable overrides and state reconciliation.

### The New tfvars Files

Both `dev.tfvars` and `test.tfvars` pointed to an Ubuntu AMI using the same variable names:

```hcl
# dev.tfvars  /  test.tfvars
ami_id        = "ami-0786adace1541ca80"   # Ubuntu AMI
instance_type = "t2.micro"
```

> ⚠️ **Key difference from `.auto.tfvars`:** A file named `dev.tfvars` or `test.tfvars` is **NOT loaded automatically**. You must explicitly pass it using `-var-file="dev.tfvars"`. If you don't pass it, Terraform ignores the file entirely.

---

### Scenario 1 — Targeted Update: Only Test Instance Changed ✅

```bash
terraform apply -var-file="test.tfvars"
```

**How Terraform resolved variables for this run:**

| Step | Source | Variable Set |
|---|---|---|
| 1 | `dev.auto.tfvars` (auto-loaded) | `ami_id` = Linux AMI |
| 2 | `test.auto.tfvars` (auto-loaded) | `test_ami_id` = Linux AMI |
| 3 | `test.tfvars` (explicitly passed) | `ami_id` = **Ubuntu AMI** ← overrides step 1 |

Since `ami_id` was overridden to the Ubuntu AMI and the test resource uses `ami_id`, Terraform detected that the test instance needed to change. The dev instance's resolved variable set was unaffected.

**Outcome:**

| Instance | Before | After | Action |
|---|---|---|---|
| `aws_instance.test` | Linux AMI | Ubuntu AMI | Destroyed → Recreated |
| `aws_instance.dev` | Linux AMI | Linux AMI | **No change** ✅ |

**Why dev was untouched:** Terraform compares the full *desired state* (computed from all merged variable inputs) against the *current state* recorded in `terraform.tfstate`. Since dev's desired state still matched its current state, Terraform took no action on it. This is the ideal behavior — surgical changes to one environment without disturbing the other.

---

### Scenario 2 — Unintended Impact: Both Instances Replaced ⚠️

```bash
terraform apply -var-file="dev.tfvars"
```

**How Terraform resolved variables for this run:**

| Step | Source | Variable Set |
|---|---|---|
| 1 | `dev.auto.tfvars` (auto-loaded) | `ami_id` = Linux AMI |
| 2 | `test.auto.tfvars` (auto-loaded) | `test_ami_id` = Linux AMI |
| 3 | `dev.tfvars` (explicitly passed) | `ami_id` = **Ubuntu AMI** ← overrides step 1 |

**Outcome:**

| Instance | Before | After | Action |
|---|---|---|---|
| `aws_instance.dev` | Linux AMI | Ubuntu AMI | Destroyed → Recreated |
| `aws_instance.test` | Ubuntu AMI | Ubuntu AMI | Destroyed → Recreated |

Both instances were replaced — including the test instance which was already running Ubuntu. This was unexpected and is the most important learning from this entire hands-on.

---

### Why Did Both Get Replaced? — The Critical Lesson

> **Terraform reconciles the ENTIRE state on every single `apply`, not just the parts whose variables changed.**

Here is the exact chain of events:

1. `dev.tfvars` overrode `ami_id` with the Ubuntu AMI — this caused `aws_instance.dev` to be replaced (Linux → Ubuntu). This was expected.

2. The test instance was previously in state as Ubuntu (from Scenario 1). Terraform re-evaluated the full desired state for all resources. During this evaluation, the combined variable set produced a configuration for the test instance that Terraform considered different from what was recorded in state — triggering a replace even though the AMI was already Ubuntu.

**The root cause: shared variable names.** Both the dev and test resource blocks used variables named `ami_id` and `instance_type`. When you override `ami_id` via `-var-file`, it has no concept of scope — it overrides that variable globally for the entire run, affecting every resource that references it.

**How to prevent this in practice:**

Use fully distinct, prefixed variable names per environment so no two resources ever share a variable name:

```hcl
# Clear separation — no shared variable names
variable "dev_ami_id"          { ... }
variable "dev_instance_type"   { ... }
variable "test_ami_id"         { ... }
variable "test_instance_type"  { ... }
```

Or for production setups, use **separate Terraform workspaces** or **separate state files** per environment so each environment's state is completely independent and changes to one can never ripple into another.

---

## Variable Loading Order — Full Reference

Terraform merges variables from multiple sources in a fixed order. When the same variable is defined in more than one place, **the later source always wins**:

| Priority | Source | How it loads |
|:---:|---|---|
| 1 (lowest) | `default` in `variables.tf` | Always present as a fallback |
| 2 | `terraform.tfvars` | Auto-loaded if the file exists in the working directory |
| 3 | `*.auto.tfvars` | Auto-loaded alphabetically |
| 4 | `-var-file="file.tfvars"` | Explicitly passed at the command line |
| 5 (highest) | `-var="key=value"` | Inline flag at the command line |

In this hands-on, `-var-file` at priority 4 overrode `.auto.tfvars` values at priority 3. This is why passing `test.tfvars` changed the AMI even though `test.auto.tfvars` had already set a value for it.

---

## Summary of All Key Concepts

| Concept | What to Remember |
|---|---|
| **Provider alias** | Use `alias` in the provider block and `provider = aws.<alias>` in each resource to route it to the right AWS account/region |
| **Provider binding is mandatory** | Without explicit binding, all resources fall back to the default provider — wrong region, wrong account |
| **`.auto.tfvars`** | Auto-loaded on every plan/apply — great for environment defaults you always want active |
| **Named `.tfvars`** | Must be explicitly passed with `-var-file` — useful for one-off overrides or environment switching |
| **Variable precedence** | `-var-file` beats `.auto.tfvars` beats `variables.tf` defaults. Later always wins |
| **Shared variable names are dangerous** | If two environments share a variable name, overriding it affects both. Always use distinct, prefixed names per environment |
| **Terraform reconciles entire state** | Every `apply` compares ALL resources against the full desired state — there is no concept of applying changes to just one resource in isolation |
| **No default VPC assumption** | Never rely on a default VPC existing. Always explicitly provide `subnet_id` and `vpc_security_group_ids` |
| **Variable mismatch is silent** | A naming error won't always throw an error — Terraform may silently fall back to the default value |

---

## Commands Reference

```bash
# Initial setup
terraform init                              # Download providers and initialize the backend

# Validation and planning
terraform validate                          # Check for syntax and configuration errors
terraform plan                              # Preview changes using auto-loaded tfvars only
terraform plan -var-file="dev.tfvars"       # Preview with a specific override file

# Applying changes
terraform apply                             # Apply using auto-loaded tfvars only
terraform apply -var-file="test.tfvars"     # Apply with test environment overrides
terraform apply -var-file="dev.tfvars"      # Apply with dev environment overrides

# Cleanup
terraform destroy                           # Destroy all managed resources
terraform destroy -var-file="dev.tfvars"    # Destroy with specific variable context
```

---

## What to Try Next

- Refactor `variables.tf` so every variable uses a clear `dev_` or `test_` prefix, then re-run Scenario 2 to confirm both instances are no longer affected simultaneously
- Explore `terraform workspace` to fully isolate dev and test state files from each other
- Move the hardcoded `subnet_id` and `vpc_security_group_ids` into variables so each environment can reference its own networking resources
- Try `terraform plan -out=tfplan` to save a plan file and then `terraform apply tfplan` to apply exactly what was previewed — no surprises
