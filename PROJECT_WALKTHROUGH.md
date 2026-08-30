# Tech Challenge 3: Step-by-Step Build and Business Decisions

This guide explains not only how to complete the project, but why each decision
was made. Items labeled **Required** come directly from the assignment. Items
labeled **Enhancement** improve security, reliability, maintainability, or
presentation without replacing the required work.

## Project goal

Build a repeatable AWS web-server environment:

```text
GitHub source code
        |
        v
Terraform provisions AWS infrastructure
        |
        v
Ansible configures EC2 and deploys Nginx
        |
        v
Public Hello, World! website
        |
        v
EC2 IAM role archives Nginx logs to S3
```

The overall business problem is:

> The company needs a web server that can be created consistently, configured
> automatically, secured appropriately, verified after deployment, and rebuilt
> without relying on manual console work.

## Step 1 — Create a private GitHub repository

**Assignment status:** Required

Create a private repository named:

```text
cloud-engineer-tech-challenge-3
```

Clone it and place the project files inside it:

```bash
git clone YOUR_PRIVATE_REPOSITORY_URL
cd cloud-engineer-tech-challenge-3
```

### What this accomplishes

Git tracks every change to the Terraform, Ansible, and documentation files.
GitHub stores the repository and allows the mentor to review it.

### Why we chose it

Infrastructure code must be reviewed and recoverable just like application
code. If a mistake is introduced, Git provides the history needed to identify
or reverse it.

### Business decision

Version control improves collaboration, accountability, change review, and
disaster recovery. It reduces the risk of relying on one engineer's laptop as
the only copy of the infrastructure definition.

## Step 2 — Prepare the local environment

**Assignment status:** Required

Use Ubuntu through WSL on the Windows computer and verify the tools:

```bash
terraform version
aws --version
ansible --version
git --version
aws sts get-caller-identity
```

### What this accomplishes

Terraform communicates with AWS to create resources. Ansible connects to EC2 to
configure the operating system. The AWS CLI confirms which AWS identity will be
used.

### Why we chose it

Ansible is designed primarily for Linux-based control machines. WSL provides
that Linux environment without requiring a separate physical computer.

### Business decision

Checking tools and credentials before deployment prevents time-consuming
failures halfway through the build and creates a repeatable workstation setup
for engineers.

## Step 3 — Create an SSH key pair

**Assignment status:** Supporting requirement

```bash
ssh-keygen -t ed25519 -f ~/.ssh/tech-challenge-3
chmod 600 ~/.ssh/tech-challenge-3
```

This creates:

- **tech-challenge-3.pub** — public key registered in AWS by Terraform
- **tech-challenge-3** — private key used locally by Ansible

### What this accomplishes

It gives Ansible a secure method of authenticating to the EC2 instance.

### Why we chose it

Public-key authentication is safer and more automatable than server passwords.
The private key remains on the administrator's machine and is never uploaded to
GitHub.

### Business decision

Strong authentication reduces unauthorized access and avoids managing reusable
server passwords.

## Step 4 — Configure reusable Terraform inputs

**Assignment status:** Required implementation quality

```bash
cp terraform/terraform.tfvars.example terraform/terraform.tfvars
curl -4 https://checkip.amazonaws.com
```

Edit **terraform/terraform.tfvars** and set the trusted address:

```hcl
ssh_cidr = "YOUR.PUBLIC.IP.ADDRESS/32"
```

### What this accomplishes

Variables control the AWS region, instance size, network ranges, SSH source,
key paths, and log retention without rewriting resource definitions.

### Why we chose it

Hard-coded values make infrastructure difficult to reuse and increase the
chance that an engineer edits the wrong part of the code.

### Business decision

Reusable configuration lets a company deploy the same approved design in
different environments while changing only controlled inputs.

## Step 5 — Build the AWS network with Terraform

**Assignment status:** Enhancement supporting the required EC2 instance

Terraform creates:

- VPC
- Public subnet
- Internet Gateway
- Public route table
- Route-table association

Relevant file:

```text
terraform/networking.tf
```

### What this accomplishes

The VPC provides an isolated AWS network. The subnet holds the EC2 instance, and
the route through the Internet Gateway allows public web traffic to reach it.

### Why we chose it

Using an explicitly defined network makes the traffic path visible and
repeatable instead of depending on whichever default VPC happens to exist.

### Business decision

Companies need predictable network boundaries for security, troubleshooting,
auditing, and future expansion. A defined network is easier to support than an
unexplained default configuration.

## Step 6 — Create the security group

**Assignment status:** Required

Terraform allows:

- TCP port 80 from **0.0.0.0/0** for the public website
- TCP port 22 only from the trusted **ssh_cidr**
- Outbound traffic for package downloads and AWS API access

Relevant file:

```text
terraform/security.tf
```

### What this accomplishes

Users can reach Nginx, but only the trusted administrator location can attempt
an SSH connection.

### Why we chose it

The website must be public, while server administration should not be exposed
to every address on the internet.

### Business decision

This applies least exposure: open only the services the business needs, to only
the audiences that need them. It reduces the attack surface without blocking
customers.

## Step 7 — Create the required S3 bucket

**Assignment status:** Required, with enhancements

Terraform creates an S3 bucket with:

- Block Public Access
- Server-side encryption
- Versioning
- A lifecycle rule for log retention

Relevant file:

```text
terraform/storage.tf
```

### What this accomplishes

The bucket satisfies the assignment and provides durable storage for Nginx log
archives instead of remaining an unused demonstration resource.

### Why we chose it

Logs stored only on EC2 disappear if the server is deleted or its disk fails.
S3 separates operational records from the life of the server.

### Business decision

Centralized, durable logs help troubleshooting, auditing, incident review, and
retention management. Encryption and blocked public access protect operational
data.

## Step 8 — Create the required IAM role

**Assignment status:** Required

Terraform creates:

- An EC2 IAM role
- A least-privilege S3 policy
- An instance profile that attaches the role to EC2

The role can list the assigned log location and write only beneath:

```text
s3://PROJECT_BUCKET/nginx-logs/
```

Relevant file:

```text
terraform/iam.tf
```

### What this accomplishes

The EC2 instance receives temporary AWS credentials automatically and can
archive logs to the one approved bucket location.

### Why we chose it

An IAM role avoids saving long-term AWS access keys on the server or inside the
Ansible code.

### Business decision

Temporary credentials and least-privilege permissions lower the effect of a
credential leak and make access easier to audit and revoke.

## Step 9 — Create the required EC2 instance

**Assignment status:** Required, with enhancements

Terraform creates:

- Ubuntu EC2 instance
- Encrypted gp3 root volume
- EC2 key pair
- IAM instance-profile attachment
- Security-group attachment
- Elastic IP
- Required IMDSv2 metadata protection

Relevant file:

```text
terraform/compute.tf
```

### What this accomplishes

EC2 provides the Linux server that Ansible will configure to host the required
web page.

### Why we chose it

Ubuntu has strong package support for Nginx and Ansible automation. An Elastic
IP gives the evaluator a stable address while the project is active.

### Business decision

The company gains direct control over the operating system and configuration,
which is useful when a workload needs server-level customization. Disk
encryption and IMDSv2 improve the server's security posture.

## Step 10 — Review and apply the Terraform plan

**Assignment status:** Required

```bash
terraform -chdir=terraform fmt -recursive
terraform -chdir=terraform init
terraform -chdir=terraform validate
terraform -chdir=terraform plan -out=tfplan
terraform -chdir=terraform apply tfplan
```

### What this accomplishes

Terraform compares the declared configuration with AWS and creates the approved
resource changes.

### Why we chose it

The saved plan ensures the exact changes reviewed by the engineer are the
changes passed to **terraform apply**.

### Business decision

Reviewing infrastructure changes before deployment reduces accidental resource
creation, security mistakes, outages, and unexpected cloud spending.

## Step 11 — Connect Terraform to Ansible

**Assignment status:** Supporting integration

```bash
terraform -chdir=terraform output -raw ansible_inventory > ansible/inventory.ini
chmod 600 ansible/inventory.ini

EC2_IP=$(terraform -chdir=terraform output -raw public_ip)
mkdir -p ~/.ssh
ssh-keyscan -H "$EC2_IP" >> ~/.ssh/known_hosts
```

### What this accomplishes

Terraform provides the address of the server it created. Ansible uses that
address, the Ubuntu username, and the SSH key to establish its connection.

### Why we chose it

Passing outputs between tools prevents manually copying an address from the AWS
console and reduces configuration drift.

### Business decision

Automated handoffs between provisioning and configuration tools make deployments
faster, more consistent, and less dependent on human memory.

## Step 12 — Install and configure Nginx with Ansible

**Assignment status:** Required

The **nginx** role:

1. Updates the apt cache.
2. Installs Nginx.
3. Deploys the page template.
4. Enables and starts the Nginx service.
5. Reloads Nginx through a handler only when necessary.

Relevant files:

```text
ansible/playbook.yml
ansible/roles/nginx/
```

### What this accomplishes

It converts the new Ubuntu EC2 instance into the required working web server
without manually entering commands over SSH.

### Why we chose it

Terraform is best at creating infrastructure. Ansible is best at configuring
software inside servers. Each tool is used for the responsibility it handles
well.

### Business decision

Automated configuration eliminates inconsistent manual server setup and allows
the company to rebuild or replace servers reliably.

## Step 13 — Deploy the required Hello World page

**Assignment status:** Required

The Ansible Jinja template displays the exact required text:

```text
Hello, World!
```

It also displays the environment, host, and project version.

Relevant file:

```text
ansible/roles/nginx/templates/index.html.j2
```

### What this accomplishes

It proves that Ansible did more than install a package: it deployed application
content to the correct server location.

### Why we chose it

A template keeps the page reusable. Values can change by environment without
maintaining separate copies of the full HTML file.

### Business decision

Templating standardizes deployments while still supporting controlled
environment-specific information.

## Step 14 — Configure automatic S3 log backups

**Assignment status:** Enhancement using required S3 and IAM resources

The **log_backup** role:

- Installs the AWS CLI
- Installs a secure backup script
- Creates a systemd service
- Creates a daily systemd timer
- Uploads the first archive to S3
- Verifies the EC2 IAM identity

Relevant files:

```text
ansible/roles/log_backup/
```

Run the complete playbook:

```bash
S3_BUCKET=$(terraform -chdir=terraform output -raw s3_bucket_name)

ANSIBLE_CONFIG=ansible/ansible.cfg \
ansible-playbook \
  -i ansible/inventory.ini \
  ansible/playbook.yml \
  -e "s3_log_bucket=$S3_BUCKET"
```

### What this accomplishes

Nginx logs are archived outside the server on a schedule.

### Why we chose it

This gives the required S3 bucket and IAM role a realistic relationship to the
required EC2 web server.

### Business decision

Automated off-server logs provide operational evidence even if the web server
is replaced, helping support teams diagnose incidents and meet retention needs.

## Step 15 — Verify functionality automatically

**Assignment status:** Required outcome, enhanced verification

The playbook uses an HTTP request and assertion to confirm:

- Nginx responds with HTTP 200
- The response contains **Hello, World!**
- The S3 log-backup timer is active

Run an external check too:

```bash
WEBSITE_URL=$(terraform -chdir=terraform output -raw website_url)
curl -fsS "$WEBSITE_URL" | grep "Hello, World!"
```

Verify the S3 archive:

```bash
aws s3 ls "s3://$S3_BUCKET/nginx-logs/" --recursive
```

### What this accomplishes

It provides evidence that the website and backup process work instead of
declaring success merely because no command displayed an error.

### Why we chose it

Successful infrastructure creation does not guarantee that the application is
usable. Testing the result validates the customer-facing outcome.

### Business decision

Automated checks find deployment problems before users or evaluators do,
reducing outages and shortening troubleshooting time.

## Step 16 — Prove Ansible idempotence

**Assignment status:** Configuration-management quality enhancement

Run the same playbook a second time:

```bash
ANSIBLE_CONFIG=ansible/ansible.cfg \
ansible-playbook \
  -i ansible/inventory.ini \
  ansible/playbook.yml \
  -e "s3_log_bucket=$S3_BUCKET"
```

Expected result:

```text
changed=0
failed=0
```

### What this accomplishes

It proves that Ansible recognizes the server's desired state and does not
repeat unnecessary changes.

### Why we chose it

Configuration automation should be safe to rerun after a failure, during
maintenance, or when confirming compliance.

### Business decision

Idempotence reduces deployment risk and makes automation dependable during
routine operations and incident recovery.

## Step 17 — Validate code through GitHub Actions

**Assignment status:** Enhancement

On pushes and pull requests, the workflow runs:

```text
terraform fmt -check
terraform validate
tflint
ansible-playbook --syntax-check
ansible-lint
```

Relevant file:

```text
.github/workflows/validate.yml
```

### What this accomplishes

It catches formatting, syntax, and quality problems before code is accepted.

### Why we chose it

Human reviewers should focus on architecture and business logic instead of
spending all their time locating basic syntax errors.

### Business decision

Early automated feedback reduces rework, improves consistency, and prevents
broken infrastructure code from moving further through the delivery process.

## Step 18 — Document and submit the project

**Assignment status:** Required

Before submission:

1. Add the real website URL to **README.md**.
2. Add a screenshot of the working page.
3. Confirm the private GitHub repository contains all required code.
4. Confirm no credentials, private keys, state, or real variable files exist in
   GitHub.
5. Share the private repository with the mentor.
6. Submit the repository link and hosted URL.
7. Complete **ASSIGNMENT_CHECKLIST.md**.

### What this accomplishes

It gives the evaluator clear evidence that every requirement works.

### Why we chose it

Even good engineering work loses value when another person cannot understand,
run, or verify it.

### Business decision

Clear documentation reduces onboarding and support time, preserves operational
knowledge, and prevents systems from depending on one individual.

## Step 19 — Destroy the lab after evaluation

**Assignment status:** Enhancement and cost control

Review what will be removed:

```bash
terraform -chdir=terraform plan -destroy
```

After saving any evidence required for submission:

```bash
terraform -chdir=terraform destroy
```

### What this accomplishes

It removes the EC2 instance, S3 objects and bucket, networking, IAM resources,
security group, key pair, and Elastic IP.

### Why we chose it

Temporary lab infrastructure should not keep running after it has served its
purpose.

### Business decision

Disciplined cleanup controls cloud spending and reduces the number of unused
resources that must be secured, monitored, and audited.

## Full interview story

> The company needed a repeatable way to deploy and configure a small AWS web
> server without relying on manual console work. My responsibility was to
> provision the infrastructure with Terraform and configure the server with
> Ansible. Terraform created the required EC2 instance, S3 bucket, IAM role, and
> security group, along with the supporting network. I restricted SSH, encrypted
> the storage, and gave EC2 a least-privilege role instead of permanent AWS
> keys. Ansible installed Nginx, deployed the required Hello World page, and
> configured daily log backups to S3. Finally, I automatically tested the page
> and reran the playbook to prove idempotence. The result was a secure,
> documented environment that could be consistently rebuilt and verified.

## Simple memory framework

```text
GitHub tracks it
Terraform builds it
IAM protects it
Ansible configures it
Nginx serves it
S3 preserves the logs
Tests prove it
Documentation explains it
```

