# sonarqube-ext-enterprise

IaC and CICD resources for deploying Externalized instance of SonarQube Enterprise.

## Project Structure

This repository contains the following key elements:

- `README.md`: This file
- `.azure`: CICD workflow logic
- `.github`: Community health files for PR and Issue templates
- `charts`: Configurations files for helmsman deployment
- `data`: DNS request forms and SSL certificate config
- `docs`: Markdown files for documenting repository and workflow
- `infrastructure`: Terraform IAC and config for dependent infrastructure
- `kubernetes`: Manifest files for initial setup of namespace
- `scripts`: bash scripts for common commands used in setup

## Requirements

1. Azure DevOps access
2. Azure Resource Group
3. External AKS cluster with namespace access

## Installation

Installation steps can be found in the [Setup Guide](./docs/SETUP.md).

## Application gateway

The Application gateways are handled in two different tenants.

1. SonarQube Prod --> “gsk-Corp-prod-us6-gpt-aks-Extappgw0001”
2. SonarQube Dev & UAT--> “gsk-Corp-Nonprod-us6-gpt-aks-Extappgw0001”

## Development

To keep local development clean we have included configurations for pythons pre-commit framework. Install the dependency globally following [install instructions](https://pre-commit.com/#installation) or simply run

```sh
pip install pre-commit
pre-commit install
```

## Contributing

If you wish to contribute features or improvements to this repo, clone it,
start a new branch, and submit your pull request.

Issues are welcome as well.

See [the guidelines](.github/CONTRIBUTING.md).
