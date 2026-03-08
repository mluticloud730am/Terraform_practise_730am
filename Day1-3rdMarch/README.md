# 🚀 Terraform Day 1 — Complete Hands-On Learning Guide
**Date:** 3rd March 2025  
**Topic:** Introduction to Terraform — Install, Configure, Deploy & Destroy AWS VPC  
**Trainer:** Abinash  
**Practised by:** Rakesh

> 📌 **Who is this for?**  
> This document is written so that **anyone — even with zero IT background** — can read it, understand exactly what was done, why it was done, and replicate it step by step on their own machine without any confusion.

---

## 📖 Table of Contents

1. [What is Terraform? — Plain English Explanation](#1-what-is-terraform--plain-english-explanation)
2. [Tools Installed Before Starting](#2-tools-installed-before-starting)
3. [How to Install Terraform on Windows — Exact Steps Done](#3-how-to-install-terraform-on-windows--exact-steps-done)
4. [What is PATH and Why Did We Set It?](#4-what-is-path-and-why-did-we-set-it)
5. [Visual Studio Code Setup](#5-visual-studio-code-setup)
6. [Core Concepts You Must Understand](#6-core-concepts-you-must-understand)
7. [Project Folder Structure](#7-project-folder-structure)
8. [Configuration Files Written](#8-configuration-files-written)
9. [Full Hands-On Session — Every Command Explained](#9-full-hands-on-session--every-command-explained)
10. [Provider Version Conflict — Error & Fix Explained](#10-provider-version-conflict--error--fix-explained)
11. [Auto-Generated Files — What They Are & Why Terraform Creates Them](#11-auto-generated-files--what-they-are--why-terraform-creates-them)
12. [Git Workflow — Saving Work to GitHub](#12-git-workflow--saving-work-to-github)
13. [Key Lessons & Common Mistakes](#13-key-lessons--common-mistakes)
14. [Quick Command Reference](#14-quick-command-reference)
15. [Resources](#15-resources)

---

## 1. What is Terraform? — Plain English Explanation

Imagine you want to build a house. You have two options:

- **Option A (Manual):** Go to the construction site every day, physically pick up each brick, place it, mix cement, nail planks yourself — takes weeks.
- **Option B (Blueprint + Contractor):** Write a blueprint on paper describing exactly what the house should look like. Hand it to a contractor. They build it exactly as described — done in days.

**Terraform is Option B — but for cloud infrastructure.**

Instead of logging into the AWS website and manually clicking buttons to create servers, networks, databases — you **write simple text files** (called `.tf` files) describing what you want. Terraform reads those files and **automatically creates everything in the cloud** by talking to AWS's API on your behalf.

```
You write .tf files  →  Terraform reads them  →  Cloud resources get created in AWS
```

This approach is called **Infrastructure as Code (IaC)** — your infrastructure is described in code, just like a developer writes code for an app.

**Why is this powerful?**
- You can create the same infrastructure **100 times** with one command
- You can **destroy everything** and recreate it exactly — no mistakes
- Your entire infrastructure is **saved in files** — you can share it, version it, review it
- No more "I forgot which button I clicked" — everything is written down

---

## 2. Tools Installed Before Starting

Before writing any Terraform code, these tools were installed on the Windows machine:

| Tool | Version | Purpose | Where to Download |
|------|---------|---------|-------------------|
| **Terraform** | 1.14.6 (AMD64) | The main tool that reads `.tf` files and creates cloud resources | https://developer.hashicorp.com/terraform/install |
| **Visual Studio Code** | 1.110.1 | Code editor for writing `.tf` files (like Notepad but much smarter) | https://code.visualstudio.com |
| **Git & Git Bash** | Latest | Version control + terminal for running commands on Windows | https://git-scm.com |
| **AWS CLI** | Latest | Command-line tool to connect your machine to your AWS account | https://aws.amazon.com/cli |

---

## 3. How to Install Terraform on Windows — Exact Steps Done

> 💡 **What is AMD64?**  
> AMD64 means 64-bit processor architecture. Almost all modern Windows laptops and desktops are AMD64. This is the version you should download.

### Step 1 — Download Terraform

1. Open your browser and go to: **https://developer.hashicorp.com/terraform/install**
2. You will see download options for different operating systems
3. Click on **Windows**
4. Click **AMD64** — this starts downloading a `.zip` file
5. The file downloaded was: `terraform_1.14.6_windows_amd64.zip`
6. This zip file was saved automatically to: `C:\Users\Admin\Downloads\`

### Step 2 — Extract the ZIP File

1. Go to `C:\Users\Admin\Downloads\` in Windows File Explorer
2. Find the file `terraform_1.14.6_windows_amd64.zip`
3. Right-click on it → click **"Extract All..."**
4. Click **Extract** (keep the default destination)
5. After extraction, a new folder appears: `terraform_1.14.6_windows_amd64`
6. Open that folder — inside you will find exactly one file: **`terraform.exe`**

> 💡 **What is `terraform.exe`?**  
> This is the entire Terraform program packed into a single file. Everything Terraform does runs from this one `.exe` file. There is nothing else to install.

### Step 3 — Tell Windows WHERE to Find terraform.exe (Setting the PATH)

Right now, `terraform.exe` is sitting in your Downloads folder. If you open a terminal and type `terraform`, Windows will say "I don't know what that is" — because it doesn't know where to look for it.

We need to tell Windows: **"Whenever someone types `terraform` in a terminal, look in this folder."**

This is done through **Environment Variables**. Here are the **exact steps that were done**:

---

**Step 3a — Open Environment Variables:**
- Press `Windows Key` on your keyboard
- Type: **Environment Variables**
- Click: **"Edit the system environment variables"**
- A window called **System Properties** opens
- Click the button at the bottom: **"Environment Variables..."**

---

**Step 3b — Find the PATH variable:**
- You will see two sections:
  - **Top section:** "User variables for Admin" ← this is where we made the change
  - **Bottom section:** "System variables"
- In the **top section**, scroll to find the row called **"Path"**
- Click on **"Path"** to select/highlight it
- Click the **"Edit..."** button

---

**Step 3c — Add the Terraform folder:**
- A new window opens showing a list of folder paths
- Click the **"New"** button (top right)
- A new empty row appears at the bottom of the list
- Copy the path from Windows File Explorer:
  - Open File Explorer → navigate to `Downloads\terraform_1.14.6_windows_amd64`
  - Click the address bar at the top of File Explorer — the full path gets highlighted in blue
  - Right-click → **Copy**
- Paste it into the new row in the Environment Variables window:
  ```
  C:\Users\Admin\Downloads\terraform_1.14.6_windows_amd64
  ```

---

**Step 3d — Save everything:**
- Click **OK** to close the "Edit environment variable" window
- Click **OK** to close the "Environment Variables" window
- Click **OK** to close "System Properties"

---

**Step 3e — Restart your terminal:**
- Close ALL open terminal windows (PowerShell, Command Prompt, Git Bash)
- PATH changes only take effect in **newly opened** terminals
- Open Git Bash fresh

### Step 4 — Verify Terraform is Working

Open **Git Bash** and type:

```bash
terraform -v
```

Expected output:
```
Terraform v1.14.6
on windows_amd64
```

✅ If you see this — **Terraform is successfully installed and ready to use!**

---

## 4. What is PATH and Why Did We Set It?

This is one of the most important concepts for beginners. It applies to every tool you will ever install (not just Terraform).

**Think of PATH like a contact list on your phone.**

When you type a command like `terraform` in the terminal, your computer doesn't search your entire hard drive — that would take forever. Instead, it **only checks the specific folders listed in your PATH variable**.

```
You type "terraform" in terminal

Windows checks PATH folders one by one:
  → C:\Windows\System32                                ← not here
  → C:\Program Files\Git\bin                           ← not here
  → C:\Users\Admin\Downloads\terraform_1.14.6_windows_amd64  ← FOUND! ✅

Windows runs terraform.exe
```

**Without adding to PATH:**
```
You type: terraform
Windows: "The term 'terraform' is not recognized" ❌
```

**After adding the folder to PATH:**
```
You type: terraform
Windows: Found it and runs it ✅
```

**Why must you close and reopen the terminal after setting PATH?**  
The terminal loads the PATH list only when it starts. An already-open terminal doesn't know about changes you just made. Closing and reopening forces it to reload the fresh PATH.

---

## 5. Visual Studio Code Setup

**Visual Studio Code (VS Code)** is the code editor used to write `.tf` files.

- **Downloaded from:** https://code.visualstudio.com (browser download)
- **Version:** 1.110.1
- **Installation:** Standard installer — run the `.exe` file → click Next through all screens → Finish

> 💡 **Why VS Code and not just Notepad?**  
> VS Code gives you syntax highlighting (code shown in colors), auto-indentation, error detection, and an integrated terminal — making it much easier to write and read Terraform code.

**Recommended: Install the Terraform Extension in VS Code**
1. Open VS Code
2. Press `Ctrl + Shift + X` → Extensions panel opens
3. Search: **HashiCorp Terraform**
4. Click **Install**
5. Now VS Code understands `.tf` files — gives you autocomplete and highlights mistakes

---

## 6. Core Concepts You Must Understand

Before looking at any code, understand these concepts. Everything else builds on them.

---

### 6.1 — What is a Provider?

A **Provider** is a plugin (a small downloadable program) that Terraform uses to talk to a specific cloud service.

Think of it like a **language translator**:
- You write instructions in Terraform language
- The AWS Provider translates them into AWS API calls
- AWS understands those calls and creates your resources

```
Your .tf file  →  AWS Provider (translator)  →  AWS API  →  Real VPC created in AWS
```

There are providers for AWS, Azure, GCP, GitHub, Kubernetes, Datadog, and hundreds more — all available at https://registry.terraform.io.

---

### 6.2 — What is a VPC?

**VPC = Virtual Private Cloud**

When you sign up for AWS, you share massive physical data centers with millions of other customers. But everyone's resources are completely isolated. Your VPC is **your own private, isolated section of the AWS network** — like having your own private floor in a giant office building.

Everything you create in AWS — servers (EC2), databases (RDS), etc. — lives inside a VPC.

```
AWS Data Center (massive shared building)
└── Your AWS Account
    └── Your VPC — "Rakesh_Dev_VPC" (your private isolated floor)
        ├── Future: Servers (EC2)
        ├── Future: Databases (RDS)
        └── Future: Load Balancers
```

---

### 6.3 — What is a CIDR Block?

`cidr_block = "10.0.0.0/16"` defines the **IP address range** for your VPC.

- `10.0.0.0` is the starting IP address
- `/16` is the size — means **65,536 available IP addresses** in this network
- Every resource inside your VPC gets one of these IP addresses

| CIDR | Available IPs | Common Use |
|------|-------------|-----------|
| `/16` | 65,536 | Large networks (used in this session) |
| `/24` | 256 | Small networks |
| `/28` | 16 | Very small networks |

---

### 6.4 — What is a Resource Block?

A **resource block** is the basic unit of Terraform code. It describes one cloud resource to create.

```hcl
resource "aws_vpc" "name" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "Rakesh_Dev_VPC"
  }
}
```

| Part | What It Is | Plain English |
|------|-----------|---------------|
| `resource` | Keyword | "I want to create something in the cloud" |
| `"aws_vpc"` | Resource Type | "Specifically, I want an AWS VPC" |
| `"name"` | Local Label | "I'll refer to it as 'name' inside my Terraform code" |
| `cidr_block` | Setting | "Give it the IP range 10.0.0.0/16" |
| `tags` | Setting | "Label it with this display name in AWS console" |

---

### 6.5 — What is the State File?

The **state file** (`terraform.tfstate`) is Terraform's memory. After creating resources, Terraform writes a record of everything it created into this file. Every future `plan` or `apply` reads this file to understand the current situation.

```
Your .tf files       =  What you WANT to exist
terraform.tfstate    =  What Terraform THINKS currently exists
Actual AWS Cloud     =  What ACTUALLY exists in AWS

Terraform's job: Make all three match perfectly
```

---

## 7. Project Folder Structure

After cloning the repository and completing Day 1, the folder structure looked like this:

```
Terraform_practise_730am/          ← Root of the cloned GitHub repo
│
├── .gitignore                     ← YOU write this: tells Git which files to NEVER upload
│
├── Day1-3rdMarch/                 ← Day 1 practice folder
│   ├── provider.tf                ← YOU write this: tells Terraform to use AWS
│   ├── main.tf                    ← YOU write this: defines the VPC resource
│   │
│   ├── .terraform/                ← AUTO-CREATED by: terraform init
│   ├── .terraform.lock.hcl        ← AUTO-CREATED by: terraform init
│   ├── terraform.tfstate          ← AUTO-CREATED by: terraform apply
│   ├── terraform.tfstate.backup   ← AUTO-CREATED by: terraform apply/destroy
│   └── terraform.tfstate.lock.info← AUTO-CREATED during apply/destroy (temporary)
│
└── Day2/                          ← Day 2 practice folder
```

> 📌 Files marked **AUTO-CREATED** are generated by Terraform automatically. You never create or manually edit these.

---

## 8. Configuration Files Written

These are the files **you write yourself** in VS Code before running any Terraform commands.

---

### `provider.tf` — Tells Terraform Which Cloud to Use

```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}
```

**Line-by-line explanation:**

| Line | Plain English Meaning |
|------|-----------------------|
| `terraform { }` | "Here are my global Terraform settings" |
| `required_providers { }` | "I need these plugins to be downloaded" |
| `source = "hashicorp/aws"` | "Download the official AWS plugin from HashiCorp's registry" |
| `version = "~> 6.0"` | "Use version 6.x — any 6.x is fine, but NOT version 7 or above" |
| `provider "aws" { }` | "Here is how to configure the AWS connection" |
| `region = "us-east-1"` | "Create all resources in AWS US East — N. Virginia data center" |

**What does `~> 6.0` mean exactly?**
- `~>` means "approximately" or "compatible with"
- `~> 6.0` allows: 6.0, 6.1, 6.35... (any 6.x)
- `~> 6.0` blocks: 7.0, 7.1... (any 7.x or higher)
- This protects you from accidental major version upgrades that could break things

---

### `main.tf` — Tells Terraform What Resource to Create

```hcl
resource "aws_vpc" "name" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "Rakesh_Dev_VPC"
  }
}
```

**What this creates:** One AWS VPC named "Rakesh_Dev_VPC" with IP range `10.0.0.0/16` in `us-east-1`.

**What do `tags` do?**  
Tags are labels attached to AWS resources. The `Name` tag appears as the display name in the AWS Console — so when you log in to AWS and go to VPC, you see "Rakesh_Dev_VPC" instead of just a random ID.

---

### `.gitignore` — Tells Git What to NEVER Upload to GitHub

```
.terraform/
*.tfstate
*.tfstate.backup
*.lock.info
```

Each line tells Git: "Ignore any file matching this pattern — never include it in commits."

---

## 9. Full Hands-On Session — Every Command Explained

### Step 1 — Clone the Repository from GitHub

```bash
git clone http://github.com/mluticloud730am/Terraform_practise_730am
```

**What "clone" means:**  
Cloning is making a complete copy of a repository from GitHub and bringing it to your local computer. All files, folders, and history come with it.

**Output seen:**
```
Cloning into 'Terraform_practise_730am'...
warning: You appear to have cloned an empty repository.
```

The "empty repository" warning appeared because the GitHub repo was created online but had no files in it yet — we are the first to add content.

**After cloning, a new folder appeared:**
```
Desktop/Terraform_Practise_730AM/
└── Terraform_practise_730am/    ← downloaded from GitHub
```

---

### Step 2 — Configure AWS Credentials

```bash
aws configure
```

**What this does:**  
This lets your computer "log in" to your AWS account. Terraform needs these credentials to call the AWS API and create real resources.

**What you enter when prompted:**
```
AWS Access Key ID:      ← Your unique key (like a username for API access)
AWS Secret Access Key:  ← Your secret (like a password — shown only once when created)
Default region name:    us-east-1   ← Press Enter if already correct
Default output format:  json        ← Press Enter to keep default
```

**Where this gets saved on your computer:**
```
C:\Users\Admin\.aws\credentials
```

Terraform **automatically reads this file** — you do not need to mention credentials anywhere inside your `.tf` files. The connection is made behind the scenes.

> ⚠️ **Critical Security Rule:** Never share your Access Key ID or Secret Access Key with anyone. Never paste them into GitHub, chat messages, or email. If you accidentally expose them, immediately log into AWS Console → IAM → Security Credentials → Deactivate and Delete that key → Create a new one.

---

### Step 3 — Navigate to the Correct Folder

```bash
# First mistake — ran terraform init in the wrong folder
terraform init
# Output: "Terraform initialized in an empty directory!"
```

This happened because we were in the parent folder (`Terraform_Practise_730AM`) which has no `.tf` files. Terraform politely told us there's nothing to initialize.

```bash
# Navigate into the cloned repo
cd Terraform_practise_730am/

# See what folders are inside
ls
# Output: Day1-3rdMarch/  Day2/

# Navigate into the Day 1 folder (this is where .tf files live)
cd Day1-3rdMarch/
```

> 📌 **Golden Rule:** Always `cd` into the exact folder containing your `.tf` files before running any Terraform command. Terraform only reads `.tf` files in the folder where you currently are.

---

### Step 4 — `terraform init` — Initialize the Project

```bash
terraform init
```

**What this command does — step by step:**
1. Reads your `provider.tf` file
2. Sees you need the `hashicorp/aws` provider
3. Connects to the internet → goes to `registry.terraform.io`
4. Downloads the AWS provider plugin
5. Saves the plugin inside a new `.terraform/` folder
6. Creates `.terraform.lock.hcl` recording the exact version downloaded

**Output seen:**
```
Initializing provider plugins...
- Finding hashicorp/aws versions matching "6.35.1"...
- Installing hashicorp/aws v6.35.1...
- Installed hashicorp/aws v6.35.1 (signed by HashiCorp)

Terraform has been successfully initialized!
```

**Files created automatically after this command:**
```
.terraform/
└── providers/
    └── registry.terraform.io/hashicorp/aws/6.35.1/
        └── terraform-provider-aws  ← The downloaded plugin binary

.terraform.lock.hcl  ← Version lock file (explained in Section 11)
```

> 💡 **When do you run `terraform init` again?**
> - First time setting up a project ← done today
> - After adding a new provider to `provider.tf`
> - After cloning someone else's Terraform project
> - When you see errors saying "provider not installed"

---

### Step 5 — `terraform plan` — Preview What Will Happen

```bash
terraform plan
```

**What this command does:**  
Terraform reads your `.tf` files, connects to AWS in **read-only mode** (doesn't create anything), and shows you a detailed preview of exactly what will happen when you run `apply`.

This is like a **flight itinerary before you board** — shows your full journey before anything actually moves.

**Output seen:**
```
Terraform will perform the following actions:

  # aws_vpc.name will be created
  + resource "aws_vpc" "name" {
      + arn                   = (known after apply)
      + cidr_block            = "10.0.0.0/16"
      + enable_dns_support    = true
      + id                    = (known after apply)
      + instance_tenancy      = "default"
      + region                = "us-east-1"
      + tags = {
          + "Name" = "Rakesh_Dev_VPC"
        }
    }

Plan: 1 to add, 0 to change, 0 to destroy.
```

**Understanding the symbols:**

| Symbol | Color | Meaning |
|--------|-------|---------|
| `+` | Green | This resource WILL BE CREATED |
| `-` | Red | This resource WILL BE DESTROYED |
| `~` | Yellow | This resource WILL BE MODIFIED |
| `-/+` | Red+Green | Will be DESTROYED then RECREATED |

**What does `(known after apply)` mean?**  
Values like `id` and `arn` are assigned by AWS at the moment of creation. Terraform doesn't know them yet — AWS will provide them after the resource is built.

> 📌 **Best Practice:** Always run `terraform plan` before `terraform apply`. Read the output carefully. The plan is your safety net.

---

### Step 6 — `terraform apply` — Create the VPC in AWS

```bash
terraform apply
```

Terraform shows the plan again and asks for confirmation:
```
Do you want to perform these actions?
  Only 'yes' will be accepted to approve.

  Enter a value: yes
```

**Output seen:**
```
aws_vpc.name: Creating...
aws_vpc.name: Creation complete after 3s [id=vpc-00252782afca27d3e]

Apply complete! Resources: 1 added, 0 changed, 0 destroyed.
```

**What happened behind the scenes:**
1. Terraform called the AWS API: "Please create a VPC with CIDR 10.0.0.0/16 in us-east-1 with these tags"
2. AWS created the VPC and assigned the unique ID `vpc-00252782afca27d3e`
3. AWS returned all the details (IP, ARN, region, etc.) to Terraform
4. Terraform wrote everything into `terraform.tfstate`

At this point — the VPC was real and visible in the **AWS Console → VPC → Your VPCs** with the name `Rakesh_Dev_VPC`.

---

### Step 7 — `terraform destroy` — Delete the VPC from AWS

```bash
terraform destroy
```

Terraform reads the state file, shows what will be deleted, and asks for confirmation:
```
Do you really want to destroy all resources?
  Only 'yes' will be accepted to confirm.

  Enter a value: yes
```

**Output seen:**
```
aws_vpc.name: Refreshing state... [id=vpc-00252782afca27d3e]

aws_vpc.name: Destroying... [id=vpc-00252782afca27d3e]
aws_vpc.name: Destruction complete after 2s

Destroy complete! Resources: 1 destroyed.
```

**Key line explained:**
```
aws_vpc.name: Refreshing state... [id=vpc-00252782afca27d3e]
```
This shows Terraform reading the state file to find exactly which VPC to delete. It knew the ID `vpc-00252782afca27d3e` because the state file saved it during `apply`. Without the state file, Terraform would not know which resource to delete.

> ⚠️ **Destroy is permanent.** Any data inside destroyed resources is lost forever. Always review what will be destroyed before typing `yes`.

---

### Step 8 — Repeated the Full Cycle 3 Times for Practice

The complete apply → destroy cycle was practised 3 times to build muscle memory:

| Attempt | VPC ID Assigned by AWS | Status |
|---------|----------------------|--------|
| 1st | `vpc-00252782afca27d3e` | Created ✅ → Destroyed ✅ |
| 2nd | `vpc-0f0a85224f6ec30b6` | Created ✅ → Destroyed ✅ |
| 3rd | `vpc-0508ad9689ef8df0f` | Created ✅ → Destroyed ✅ |

**Key observation:** Each time `apply` runs, AWS assigns a **completely new unique ID** — even though the code in `main.tf` is identical every time. This is because each resource is a brand new object in AWS.

---

## 10. Provider Version Conflict — Error & Fix Explained

During the session, this error appeared after running `terraform init`:

```
Error: Failed to query available provider packages

locked provider registry.terraform.io/hashicorp/aws 6.35.1 does not match
configured version constraint < 4.0.0; must use terraform init -upgrade
```

**Why did this happen?**

The `provider.tf` file was changed mid-session to `version = "< 4.0.0"` (meaning "use any version below 4.0"). But the `.terraform.lock.hcl` file still had `6.35.1` locked from the previous `terraform init`. These two disagreed:

```
provider.tf says:      I need version < 4.0.0
lock file says:        Version 6.35.1 is locked

Terraform says:        ❌ These conflict — I won't proceed until you resolve this
```

**Fix used:**
```bash
terraform init --upgrade
```

The `--upgrade` flag tells Terraform: "Ignore the existing lock file. Re-read `provider.tf` and download whatever version the constraint requires."

**What happened after `--upgrade`:**
```
- Finding hashicorp/aws versions matching "< 4.0.0"...
- Installing hashicorp/aws v3.76.1...
```
Downloaded version `3.76.1` (highest available version below 4.0.0) and updated the lock file to match.

**Provider versions across the session:**

| Stage | Version | Reason |
|-------|---------|--------|
| First `terraform init` | `6.35.1` | Latest version, no constraint |
| After constraint changed to `< 4.0.0` | `3.76.1` | Downgraded to satisfy constraint |
| Final `--upgrade` with no constraint | `6.35.1` | Upgraded back to latest |

---

## 11. Auto-Generated Files — What They Are & Why Terraform Creates Them

When you run Terraform commands, several files are **automatically created by Terraform**. You never create or edit these yourself. Understanding each one is essential for working safely.

---

### 11.1 — `terraform.tfstate` — Terraform's Memory

**Created by:** `terraform apply`  
**Updated by:** Every subsequent `apply` or `destroy`  
**Location:** Your project folder

#### What it is:
This is a **JSON file** that stores a complete record of every resource Terraform has created — including the AWS-assigned IDs, all settings, IP addresses, and every attribute returned by AWS.

#### What it looks like (simplified example):
```json
{
  "version": 4,
  "terraform_version": "1.14.6",
  "resources": [
    {
      "type": "aws_vpc",
      "name": "name",
      "instances": [
        {
          "attributes": {
            "id": "vpc-0508ad9689ef8df0f",
            "cidr_block": "10.0.0.0/16",
            "region": "us-east-1",
            "tags": { "Name": "Rakesh_Dev_VPC" }
          }
        }
      ]
    }
  ]
}
```

#### Why Terraform needs it:
Every time you run `plan` or `apply`, Terraform compares three things:

```
Your .tf files       =  What you WANT to exist
terraform.tfstate    =  What Terraform THINKS currently exists
Actual AWS Cloud     =  What ACTUALLY exists

Terraform's goal = Make all three perfectly match
```

Without the state file, Terraform would have no memory of what it previously created and could not manage existing resources.

#### Seen in your session:
```
aws_vpc.name: Refreshing state... [id=vpc-00252782afca27d3e]
```
This line proved Terraform was reading the state file during `destroy` — it used the saved ID to know exactly which VPC to call the AWS deletion API on.

#### Rules:
- ❌ **NEVER manually edit** — even one wrong character breaks Terraform completely
- ❌ **NEVER delete** — Terraform loses track of all resources; they keep running in AWS and keep billing you
- ❌ **NEVER commit to GitHub** — can contain IP addresses, account IDs, and sometimes passwords
- ✅ Always add `*.tfstate` to `.gitignore`

---

### 11.2 — `.terraform.lock.hcl` — The Version Lock File

**Created by:** `terraform init`  
**Updated by:** `terraform init --upgrade`  
**Location:** Your project folder

#### What it is:
When you run `terraform init`, Terraform downloads provider plugins. The lock file records the **exact version** of every downloaded provider — like a receipt with a tamper-proof seal.

#### What it looks like:
```hcl
# This file is maintained automatically by "terraform init".
# Manual edits may be lost in future updates.

provider "registry.terraform.io/hashicorp/aws" {
  version     = "6.35.1"
  constraints = "~> 6.0"
  hashes = [
    "h1:xK3C6bOJxDMn47yOslMXiFC...",   ← Cryptographic fingerprint
  ]
}
```

#### Why it exists — The Team Consistency Problem:

Without a lock file:
```
You run terraform init on Monday    → Downloads AWS provider 6.35.1
Teammate runs init on Tuesday       → Downloads AWS provider 6.36.0 (newer!)
Result: You both have different versions → Different behavior ❌
```

With a lock file:
```
You run terraform init on Monday    → Downloads 6.35.1, lock file records it
Teammate runs init on Tuesday       → Lock file says 6.35.1 → Downloads 6.35.1
Result: Both have identical versions → Consistent behavior ✅
```

The `hashes` field is a **cryptographic fingerprint** — every time someone downloads the provider, Terraform verifies the file matches this fingerprint. This prevents tampering or corrupted downloads.

#### Seen in your session:
The version conflict error was caused directly by this file having `6.35.1` while `provider.tf` required `< 4.0.0`. Fixed with `terraform init --upgrade`.

#### Rules:
- ✅ **ALWAYS commit to GitHub** — this is the one auto-generated file you SHOULD share with your team
- ❌ **DO NOT manually edit** — always let `terraform init` manage it
- To upgrade a provider version intentionally: `terraform init --upgrade`

---

### 11.3 — `terraform.tfstate.lock.info` — The Active Operation Lock

**Created by:** `terraform apply` or `terraform destroy` (the instant it starts)  
**Deleted by:** Automatically deleted the moment the operation finishes  
**Lifespan:** Exists ONLY while Terraform is actively running

#### What it is:
This file is like a **"Currently In Use — Do Not Disturb"** sign. The moment `terraform apply` or `destroy` starts, this file is created to signal that a Terraform operation is in progress. When the operation finishes, the file is automatically deleted.

#### What it looks like:
```json
{
  "ID":        "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
  "Operation": "OperationTypeApply",
  "Who":       "Admin@DESKTOP-FGF7R1H",
  "Version":   "1.14.6",
  "Created":   "2025-03-03T07:30:00.000Z",
  "Path":      "terraform.tfstate"
}
```

| Field | Meaning |
|-------|---------|
| `ID` | Unique ID for this specific lock |
| `Operation` | What is running — Apply or Destroy |
| `Who` | Which user/machine started it |
| `Version` | Which Terraform version is running it |
| `Created` | Exact time the operation started |

#### Why it exists — Preventing Simultaneous Runs:

```
Without lock file:
  Person A: terraform apply  ← starts modifying infrastructure
  Person B: terraform apply  ← also starts modifying at the same time
  Result: Conflicting API calls, duplicate resources, corrupted state file ❌

With lock file:
  Person A: terraform apply  → lock.info created immediately
  Person B: terraform apply  → Error: "State locked by Person A. Try again later."
  Person A finishes          → lock.info deleted automatically
  Person B: terraform apply  → Works now — lock.info created for B ✅
```

#### What if the file doesn't get cleaned up?

If your terminal is **force-closed or crashes** while apply is running, the lock file may be left behind as a "stale lock". Next time you run Terraform:

```
Error: Error acquiring the state lock

Lock Info:
  ID:        a1b2c3d4-e5f6-7890-abcd-ef1234567890
  Operation: OperationTypeApply
  Who:       Admin@DESKTOP-FGF7R1H
```

**Fix** (only when you are 100% sure nothing is actively running):
```bash
terraform force-unlock a1b2c3d4-e5f6-7890-abcd-ef1234567890
```
Copy the exact ID from the error message and use it in the command.

#### Rules:
- ❌ **NEVER manually delete** while Terraform is actively running — will corrupt state
- If it exists when nothing is running → stale lock from a crash → safe to `force-unlock`
- ❌ **NEVER commit to GitHub** → add `*.lock.info` to `.gitignore`

---

### 11.4 — `terraform.tfstate.backup` — The Automatic Safety Backup

**Created by:** `terraform apply` or `terraform destroy`  
**When exactly:** Created just BEFORE Terraform overwrites `terraform.tfstate`  
**Location:** Your project folder

#### What it is:
Every single time Terraform is about to update the main state file, it first **saves a copy of the current state** as `terraform.tfstate.backup`. It is your automatic one-step undo for the state file.

#### Exact timeline from your session:

```
━━━ Before 1st apply ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  terraform.tfstate        → does not exist yet
  terraform.tfstate.backup → does not exist yet

━━━ After 1st apply ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  terraform.tfstate        → "VPC vpc-00252782 exists"
  terraform.tfstate.backup → does not exist yet

━━━ Just before destroy (Terraform saves backup first) ━━━━
  terraform.tfstate        → "VPC vpc-00252782 exists"
  terraform.tfstate.backup → copy of above ← your safety net ✅

━━━ After destroy ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  terraform.tfstate        → empty (VPC deleted)
  terraform.tfstate.backup → still "VPC vpc-00252782 exists" ← undo available

━━━ After 2nd apply ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  terraform.tfstate        → "VPC vpc-0f0a85224 exists"
  terraform.tfstate.backup → "empty state" (previous tfstate)
```

#### How to use it for recovery:
If `terraform.tfstate` gets corrupted or accidentally deleted:
```bash
cp terraform.tfstate.backup terraform.tfstate
```
This restores the previous state so Terraform can continue managing your resources.

> 💡 **Limitation:** Only holds the **previous one state** — not a full history. For complete history, teams use remote state stored in AWS S3 (advanced topic for later).

#### Rules:
- ❌ **NEVER commit to GitHub** — contains the same sensitive data as the state file
- ❌ **DO NOT delete manually** — it is your only automatic recovery option
- ✅ Add `*.tfstate.backup` to `.gitignore`

---

### 11.5 — `.terraform/` Folder — Downloaded Provider Plugins

**Created by:** `terraform init`  
**Location:** Your project folder

#### What it is:
This folder contains the actual **downloaded provider plugin binary** — the executable file that Terraform downloaded from the registry. The AWS provider plugin lives here.

#### Why you never commit it:
- Provider binaries are very large (can be 100MB+)
- Automatically regenerated by `terraform init` on any machine
- Platform-specific (a Windows binary won't work on Mac or Linux)
- Anyone who clones your repo just runs `terraform init` to get it themselves

---

### 📊 Complete Auto-Generated Files Summary

| File | Created When | Purpose | Commit to GitHub? | Edit Manually? |
|------|-------------|---------|:-----------------:|:--------------:|
| `terraform.tfstate` | `terraform apply` | Terraform's memory — records all managed resources | ❌ Never | ❌ Never |
| `.terraform.lock.hcl` | `terraform init` | Locks exact provider versions for team consistency | ✅ Always | ❌ Never |
| `terraform.tfstate.lock.info` | During apply/destroy | Prevents two simultaneous Terraform operations | ❌ Never | ❌ Never |
| `terraform.tfstate.backup` | Before each apply/destroy | Auto-backup of the previous state for recovery | ❌ Never | ❌ Never |
| `.terraform/` folder | `terraform init` | Downloaded provider plugin binaries | ❌ Never | ❌ Never |

---

### ✅ Recommended `.gitignore` for Every Terraform Project

```gitignore
# ============================================================
# TERRAFORM — Files to NEVER commit to GitHub
# ============================================================

# Downloaded provider plugins (large binaries, auto-generated)
.terraform/

# State files (contain sensitive resource details)
terraform.tfstate
terraform.tfstate.backup

# Active operation lock file (temporary, auto-deleted normally)
*.lock.info

# Variable value files (may contain passwords, API keys)
*.tfvars
*.tfvars.json

# Crash logs from Terraform
crash.log
crash.*.log

# ============================================================
# NOTE: .terraform.lock.hcl is the ONE exception —
# that file SHOULD be committed to GitHub
# ============================================================
```

---

## 12. Git Workflow — Saving Work to GitHub

At the end of the session, all work was saved to GitHub.

### What is Git and GitHub?

- **Git** is a version control system — it tracks every change you make to your files over time, like "track changes" in Word but for your entire project
- **GitHub** is a website (https://github.com) where you store your Git projects online — like Google Drive but designed specifically for code

### Commands Used:

```bash
# Navigate to root of the repository
cd ../

# First attempt — forgot the dot
git add
# Output: "Nothing specified, nothing added. Maybe you wanted to say 'git add .'"
# Git politely told us we need to specify what to add

# Correct command — stage ALL files
git add .
```

> 💡 **What does `git add .` mean?**  
> The `.` means "everything in the current folder and all subfolders". It tells Git: "Mark all changed and new files as ready to be committed."

```bash
# Create a snapshot of the current state with a label
git commit -m "Day1 Learning Terraform with Abinash"
```

> 💡 **What is a commit?**  
> A commit is like pressing "Save + Label" on your work. It creates a permanent, timestamped snapshot of all your files. You can always look back at or restore any commit.

```bash
# Upload your commits from local computer to GitHub
git push
```

> 💡 **What is `git push`?**  
> Push sends your local commits to the GitHub server. Before push: your work is only on your laptop. After push: it is safely stored online, visible to your team, and backed up.

### Output seen:
```
[main (root-commit) 9b9ebbd] Day1 Learning Terraform with Abinash
 3 files changed, 26 insertions(+)
 create mode 100644 .gitignore
 create mode 100644 Day1-3rdMarch/main.tf
 create mode 100644 Day1-3rdMarch/provider.tf
```

**3 files were pushed to GitHub:**
- `.gitignore` — exclusion rules
- `Day1-3rdMarch/main.tf` — VPC resource code
- `Day1-3rdMarch/provider.tf` — AWS provider configuration

**Files NOT pushed** (because `.gitignore` excluded them correctly):
- `.terraform/` folder
- `terraform.tfstate` and `.backup`

---

## 13. Key Lessons & Common Mistakes

| # | Situation | What Happened | Lesson |
|---|-----------|--------------|--------|
| 1 | Ran `terraform init` in wrong folder | Got "empty directory" message | Always `cd` into the folder with `.tf` files first |
| 2 | Typed `git add` without `.` | Got "Nothing specified" error | Always use `git add .` to stage everything |
| 3 | Provider version conflict error | Lock file and `provider.tf` disagreed | Use `terraform init --upgrade` to re-resolve versions |
| 4 | Each `apply` gives a different VPC ID | AWS assigns a brand new unique ID every time | Normal behavior — new resource = new ID |
| 5 | `.tfstate` not pushed to GitHub | `.gitignore` correctly excluded it | State files must never be committed |
| 6 | `(known after apply)` in plan output | Some values only exist after AWS creates the resource | Normal — Terraform fills these in after apply |
| 7 | `terraform init` must run before any other command | No provider = no Terraform functionality | Always initialize before plan/apply |

---

## 14. Quick Command Reference

```bash
# ── INSTALLATION CHECK ──────────────────────────────────
terraform -v                    # Check installed Terraform version

# ── PROJECT SETUP ───────────────────────────────────────
terraform init                  # Initialize project — download provider plugins
terraform init --upgrade        # Force re-download providers, fix version conflicts

# ── DAILY WORKFLOW ──────────────────────────────────────
terraform fmt                   # Auto-format all .tf files neatly
terraform validate              # Check .tf files for syntax errors (no cloud call)
terraform plan                  # Preview what WILL happen (read-only)
terraform apply                 # Create or update real cloud infrastructure
terraform apply -auto-approve   # Apply without asking for 'yes' confirmation
terraform destroy               # Delete all managed infrastructure
terraform destroy -auto-approve # Destroy without asking for 'yes' confirmation

# ── INSPECTION COMMANDS ─────────────────────────────────
terraform state list            # List all resources tracked in state file
terraform output                # Show output values defined in outputs.tf
terraform show                  # Show full details of current state

# ── GIT COMMANDS ────────────────────────────────────────
git clone <url>                 # Download a repository from GitHub to local
git add .                       # Stage all changed files
git commit -m "your message"    # Save a snapshot with a description
git push                        # Upload commits to GitHub
git status                      # See which files have changed
git log                         # See full commit history
```

---

## 15. Resources

| Resource | URL |
|---------|-----|
| Terraform Download | https://developer.hashicorp.com/terraform/install |
| Terraform Documentation | https://developer.hashicorp.com/terraform/docs |
| Terraform Registry (all providers) | https://registry.terraform.io |
| AWS VPC Terraform Docs | https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc |
| AWS Console | https://console.aws.amazon.com |
| Visual Studio Code | https://code.visualstudio.com |
| Git Download | https://git-scm.com |

---

## ✅ Day 1 Summary — What Was Accomplished

- Terraform 1.14.6 (AMD64) downloaded from HashiCorp and extracted on Windows
- `terraform.exe` path (`C:\Users\Admin\Downloads\terraform_1.14.6_windows_amd64`) added to Windows User PATH via Environment Variables → verified with `terraform -v`
- VS Code 1.110.1 installed as the code editor
- AWS credentials configured with `aws configure`
- GitHub repository cloned locally
- Navigated to correct folder and ran `terraform init` successfully
- Wrote `provider.tf` and `main.tf` to define AWS VPC
- Ran the full `plan → apply → destroy` cycle 3 times successfully
- Understood and resolved a provider version conflict with `terraform init --upgrade`
- Learned the purpose of all 5 auto-generated Terraform files in depth
- Committed and pushed 3 files to GitHub using `git add . → commit → push`

---

*Written by Rakesh | Trainer: Abinash | Date: 3rd March 2025*
