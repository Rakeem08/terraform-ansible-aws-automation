# Infrastructure Automation — Implementation and Deployment Checklist

This public portfolio repository originated as a training assignment. Checked items below indicate committed implementation, not proof of a current deployment. Capture fresh evidence for unchecked runtime checks.

## Committed implementation

- [x] Terraform definitions for EC2, S3, IAM, security groups, and supporting networking.
- [x] Terraform outputs for the website address and Ansible inventory.
- [x] Ansible roles for Nginx and optional S3 log backups.
- [x] HTTP 200 and Hello, World! assertions in the playbook.
- [x] GitHub Actions configuration for Terraform and Ansible quality checks.
- [x] Setup instructions in [README.md](README.md).
- [x] Build explanation in [PROJECT_WALKTHROUGH.md](PROJECT_WALKTHROUGH.md).
- [x] Public repository: [terraform-ansible-aws-automation](https://github.com/Rakeem08/terraform-ansible-aws-automation).

## Verify for each deployment

- [ ] Set the trusted administrator CIDR and matching local SSH key paths.
- [ ] Confirm Terraform formatting, initialization, validation, and CI results.
- [ ] Review the Terraform plan before applying it.
- [ ] Generate the inventory and verify Ansible SSH connectivity.
- [ ] Run the playbook and capture `failed=0`.
- [ ] Confirm the deployed page returns HTTP 200 and Hello, World! externally.
- [ ] Re-run the playbook and check idempotence (`changed=0`, `failed=0`).
- [ ] When backups are enabled, verify the timer and a log archive under `nginx-logs/`.
- [ ] Confirm the deployed security controls match the Terraform configuration.
- [ ] Inspect the diff for credentials, keys, state, and real variable files before committing.
- [ ] Preserve non-sensitive deployment evidence and remove resources when finished.

The historical URL in the README is a lab reference. Use the current Terraform `website_url` output for a new deployment. No private-repository sharing or mentor submission is required to use this public project.
