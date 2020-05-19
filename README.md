[![Masterpoint Logo](https://i.imgur.com/RDLnuQO.png)](https://masterpoint.io)

# terraform-aws-amplify-app

A Terraform module for building simple Amplify apps. This creates the `master` and `develop` branches, sets up the domain association, and creates webhooks for both branches.

NOTE: This is currently using [@k24d's Amplify resources](https://github.com/terraform-providers/terraform-provider-aws/issues/6917#issuecomment-626309424) which are still up on PR and not currently merged into [terraform-provider-aws](https://github.com/terraform-providers/terraform-provider-aws). To use this today, you can use [these instructions](https://github.com/k24d/terraform-provider-aws/blob/amplify/README-amplify.md). While this notice is still up, please be sure to go and upvote [the main Amplify resource PR #11928](https://github.com/terraform-providers/terraform-provider-aws/pull/11928) so we can get that merged by the AWS provider team.

## Usage

```hcl
provider "aws" {
  region = "us-east-1"
}

module "amplify" {
  source = "git::https://github.com/masterpointio/terraform-aws-amplify-app.git?ref=tags/0.1.0"

  namespace                    = var.namespace
  stage                        = var.stage
  name                         = "mattgowie"
  organization                 = "Gowiem"
  repo                         = "mattgowie.com"
  gh_access_token              = var.gh_access_token
  domain_name                  = "mattgowie.com"
  description                  = "The Personal site of Matt Gowie."
  enable_basic_auth_on_master  = false
  enable_basic_auth_on_develop = true
  basic_auth_username          = var.basic_auth_username
  basic_auth_password          = var.basic_auth_password
  develop_pull_request_preview = true

  custom_rules = [{
    source    = "https://www.mattgowie.com"
    target    = "https://mattgowie.com"
    status    = "301"
    condition = null
  }, {
    source    = "/<*>"
    target    = "/index.html"
    status    = "404"
    condition = null
  }]
}
```

## Credits

1. [@k24d](https://github.com/k24d)'s creation of the Amplify Resources for the AWS Provider!  
1. [cloudposse/terraform-null-label](https://github.com/cloudposse/terraform-null-label)

## Requirements

| Name | Version |
|------|---------|
| terraform | ~> 0.12.0 |
| aws | ~> 2.0 |
| local | ~> 1.2 |
| null | ~> 2.0 |

## Providers

| Name | Version |
|------|---------|
| aws | ~> 2.0 |
| local | ~> 1.2 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| attributes | Additional attributes (e.g. `1`) | `list(string)` | `[]` | no |
| basic\_auth\_password | The password to use for the basic auth configuration. | `string` | n/a | yes |
| basic\_auth\_username | The username to use for the basic auth configuration. | `string` | n/a | yes |
| custom\_rules | The custom rules to apply to the Amplify App. | <pre>list(object({<br>    source    = string # Required<br>    target    = string # Required<br>    status    = any # Use null if not passing<br>    condition = any # Use null if not passing<br>  }))</pre> | `[]` | no |
| delimiter | Delimiter to be used between `namespace`, `stage`, `name` and `attributes` | `string` | `"-"` | no |
| description | The description to associate with the Amplify App. | `string` | n/a | yes |
| develop\_pull\_request\_preview | Whether to enable preview on PR's into develop. | `bool` | `true` | no |
| domain\_name | The Custom Domain Name to associate with this Amplify App. | `string` | `""` | no |
| enable\_basic\_auth\_on\_develop | To enable basic auth on the develop branch subdomain or not. | `bool` | `true` | no |
| enable\_basic\_auth\_on\_master | To enable basic auth the root subdomain or not. | `bool` | `false` | no |
| environment | Environment, e.g. 'prod', 'staging', 'dev', 'pre-prod', 'UAT' | `string` | `""` | no |
| gh\_access\_token | Personal Access token for 3rd party source control system for an Amplify App, used to create webhook and read-only deploy key. Token is not stored. | `string` | n/a | yes |
| name | Solution name, e.g. 'app' or 'jenkins' | `string` | n/a | yes |
| namespace | Namespace, which could be your organization name or abbreviation, e.g. 'eg' or 'cp' | `string` | n/a | yes |
| organization | The GitHub organization or user where the repo lives. | `string` | n/a | yes |
| repo | The name of the repo that the Amplify App will be created around. | `string` | n/a | yes |
| stage | The environment that this infrastrcuture is being deployed to e.g. dev, stage, or prod | `string` | n/a | yes |
| tags | Additional tags (e.g. `map('BusinessUnit','XYZ')` | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| arn | The ARN of the main Amplify resource. |
| custom\_domains | List of custom domains that are associated with this resource (if any). |
| default\_domain | The amplify domain (non-custom). |
| develop\_webhook\_arn | The ARN of the develop webhook. |
| develop\_webhook\_url | The URL of the develop webhook. |
| domain\_association\_arn | The ARN of the domain association resource. |
| master\_webhook\_arn | The ARN of the master webhook. |
| master\_webhook\_url | The URL of the master webhook. |

