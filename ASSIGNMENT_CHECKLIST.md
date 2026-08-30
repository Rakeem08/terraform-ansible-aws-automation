# Tech Challenge 3 Submission Checklist

Use this checklist before sending the project to the mentor.

## Required Terraform work

- [ ] Terraform successfully creates an EC2 instance.
- [ ] Terraform successfully creates an S3 bucket.
- [ ] Terraform successfully creates the necessary IAM role and instance profile.
- [ ] Terraform successfully creates the necessary security group.
- [ ] **terraform fmt -check -recursive** passes.
- [ ] **terraform validate** passes.
- [ ] **terraform plan** has been reviewed before apply.

## Required Ansible work

- [ ] Ansible connects to the Terraform-created EC2 instance.
- [ ] Ansible installs Nginx.
- [ ] Ansible enables and starts Nginx.
- [ ] Ansible deploys a page containing the exact text **Hello, World!**
- [ ] The playbook completes with **failed=0**.
- [ ] A second playbook run completes with **changed=0** and **failed=0**.

## Required documentation and submission

- [ ] README contains environment setup instructions.
- [ ] README contains Terraform deployment instructions.
- [ ] README contains Ansible configuration instructions.
- [ ] README explains the Terraform files.
- [ ] README explains the Ansible roles.
- [ ] The real hosted website URL has been added to the README.
- [ ] The hosted URL works in a browser without AWS-console access.
- [ ] A screenshot of the working page has been added to the repository.
- [ ] Code has been committed and pushed to a private GitHub repository.
- [ ] The private repository has been shared with the mentor.
- [ ] The GitHub repository URL has been submitted.

## Extra professional evidence

- [ ] SSH is restricted to the current trusted IPv4 CIDR.
- [ ] The S3 bucket is private, encrypted, and versioned.
- [ ] The EC2 instance uses a least-privilege IAM role without stored AWS keys.
- [ ] At least one Nginx log archive exists under the S3 **nginx-logs/** prefix.
- [ ] The Nginx log-backup systemd timer is active.
- [ ] GitHub Actions validation checks pass.
- [ ] No keys, credentials, state files, or real variable files are committed.
- [ ] Cleanup has been planned after evaluation.

