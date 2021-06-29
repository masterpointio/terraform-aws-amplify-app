[![Masterpoint Logo](https://i.imgur.com/RDLnuQO.png)](https://masterpoint.io)

# terraform-aws-amplify-app

A Terraform module for building simple Amplify apps. This creates the `master` and `develop` branches, sets up the domain association, and creates webhooks for both branches.

## Usage

```hcl
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

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.14.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 3.32 |
| <a name="requirement_local"></a> [local](#requirement\_local) | ~> 2.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 3.47.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_develop_branch_label"></a> [develop\_branch\_label](#module\_develop\_branch\_label) | cloudposse/label/null | 0.24.1 |
| <a name="module_master_branch_label"></a> [master\_branch\_label](#module\_master\_branch\_label) | cloudposse/label/null | 0.24.1 |
| <a name="module_this"></a> [this](#module\_this) | cloudposse/label/null | 0.24.1 |

## Resources

| Name | Type |
|------|------|
| [aws_amplify_app.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/amplify_app) | resource |
| [aws_amplify_branch.develop](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/amplify_branch) | resource |
| [aws_amplify_branch.master](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/amplify_branch) | resource |
| [aws_amplify_domain_association.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/amplify_domain_association) | resource |
| [aws_amplify_webhook.develop](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/amplify_webhook) | resource |
| [aws_amplify_webhook.master](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/amplify_webhook) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_tag_map"></a> [additional\_tag\_map](#input\_additional\_tag\_map) | Additional tags for appending to tags\_as\_list\_of\_maps. Not added to `tags`. | `map(string)` | `{}` | no |
| <a name="input_attributes"></a> [attributes](#input\_attributes) | Additional attributes (e.g. `1`) | `list(string)` | `[]` | no |
| <a name="input_basic_auth_password"></a> [basic\_auth\_password](#input\_basic\_auth\_password) | The password to use for the basic auth configuration. | `string` | n/a | yes |
| <a name="input_basic_auth_username"></a> [basic\_auth\_username](#input\_basic\_auth\_username) | The username to use for the basic auth configuration. | `string` | n/a | yes |
| <a name="input_build_spec_content"></a> [build\_spec\_content](#input\_build\_spec\_content) | Your build spec file contents. If not provided then it will use the `amplify.yml` at the root of your project / branch. | `string` | `""` | no |
| <a name="input_context"></a> [context](#input\_context) | Single object for setting entire context at once.<br>See description of individual variables for details.<br>Leave string and numeric variables as `null` to use default value.<br>Individual variable settings (non-null) override settings in context object,<br>except for attributes, tags, and additional\_tag\_map, which are merged. | <pre>object({<br>    enabled             = bool<br>    namespace           = string<br>    environment         = string<br>    stage               = string<br>    name                = string<br>    delimiter           = string<br>    attributes          = list(string)<br>    tags                = map(string)<br>    additional_tag_map  = map(string)<br>    regex_replace_chars = string<br>    label_order         = list(string)<br>    id_length_limit     = number<br>  })</pre> | <pre>{<br>  "additional_tag_map": {},<br>  "attributes": [],<br>  "delimiter": null,<br>  "enabled": true,<br>  "environment": null,<br>  "id_length_limit": null,<br>  "label_order": [],<br>  "name": null,<br>  "namespace": null,<br>  "regex_replace_chars": null,<br>  "stage": null,<br>  "tags": {}<br>}</pre> | no |
| <a name="input_custom_rules"></a> [custom\_rules](#input\_custom\_rules) | The custom rules to apply to the Amplify App. | <pre>list(object({<br>    source    = string # Required<br>    target    = string # Required<br>    status    = any    # Use null if not passing<br>    condition = any    # Use null if not passing<br>  }))</pre> | `[]` | no |
| <a name="input_delimiter"></a> [delimiter](#input\_delimiter) | Delimiter to be used between `namespace`, `environment`, `stage`, `name` and `attributes`.<br>Defaults to `-` (hyphen). Set to `""` to use no delimiter at all. | `string` | `null` | no |
| <a name="input_description"></a> [description](#input\_description) | The description to associate with the Amplify App. | `string` | n/a | yes |
| <a name="input_develop_branch_name"></a> [develop\_branch\_name](#input\_develop\_branch\_name) | The name of the 'develop'-like branch that you'd like to use. | `string` | `"develop"` | no |
| <a name="input_develop_environment_variables"></a> [develop\_environment\_variables](#input\_develop\_environment\_variables) | Environment variables for the develop branch. | `map(string)` | `{}` | no |
| <a name="input_develop_pull_request_preview"></a> [develop\_pull\_request\_preview](#input\_develop\_pull\_request\_preview) | Whether to enable preview on PR's into develop. | `bool` | `true` | no |
| <a name="input_domain_name"></a> [domain\_name](#input\_domain\_name) | The Custom Domain Name to associate with this Amplify App. | `string` | `""` | no |
| <a name="input_enable_basic_auth_globally"></a> [enable\_basic\_auth\_globally](#input\_enable\_basic\_auth\_globally) | To enable basic auth for all branches or not. | `bool` | `false` | no |
| <a name="input_enable_basic_auth_on_develop"></a> [enable\_basic\_auth\_on\_develop](#input\_enable\_basic\_auth\_on\_develop) | To enable basic auth on the develop branch subdomain or not. | `bool` | `true` | no |
| <a name="input_enable_basic_auth_on_master"></a> [enable\_basic\_auth\_on\_master](#input\_enable\_basic\_auth\_on\_master) | To enable basic auth the root subdomain or not. | `bool` | `false` | no |
| <a name="input_enabled"></a> [enabled](#input\_enabled) | Set to false to prevent the module from creating any resources | `bool` | `null` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment, e.g. 'uw2', 'us-west-2', OR 'prod', 'staging', 'dev', 'UAT' | `string` | `null` | no |
| <a name="input_gh_access_token"></a> [gh\_access\_token](#input\_gh\_access\_token) | Personal Access token for 3rd party source control system for an Amplify App, used to create webhook and read-only deploy key. Token is not stored. | `string` | n/a | yes |
| <a name="input_global_environment_variables"></a> [global\_environment\_variables](#input\_global\_environment\_variables) | Environment variables that are set across all branches. | `map(string)` | `{}` | no |
| <a name="input_id_length_limit"></a> [id\_length\_limit](#input\_id\_length\_limit) | Limit `id` to this many characters.<br>Set to `0` for unlimited length.<br>Set to `null` for default, which is `0`.<br>Does not affect `id_full`. | `number` | `null` | no |
| <a name="input_label_order"></a> [label\_order](#input\_label\_order) | The naming order of the id output and Name tag.<br>Defaults to ["namespace", "environment", "stage", "name", "attributes"].<br>You can omit any of the 5 elements, but at least one must be present. | `list(string)` | `null` | no |
| <a name="input_master_branch_name"></a> [master\_branch\_name](#input\_master\_branch\_name) | The name of the 'master'-like branch that you'd like to use. | `string` | `"master"` | no |
| <a name="input_master_environment_variables"></a> [master\_environment\_variables](#input\_master\_environment\_variables) | Environment variables for the master branch. | `map(string)` | `{}` | no |
| <a name="input_name"></a> [name](#input\_name) | Solution name, e.g. 'app' or 'jenkins' | `string` | `null` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Namespace, which could be your organization name or abbreviation, e.g. 'eg' or 'cp' | `string` | `null` | no |
| <a name="input_organization"></a> [organization](#input\_organization) | The GitHub organization or user where the repo lives. | `string` | n/a | yes |
| <a name="input_regex_replace_chars"></a> [regex\_replace\_chars](#input\_regex\_replace\_chars) | Regex to replace chars with empty string in `namespace`, `environment`, `stage` and `name`.<br>If not set, `"/[^a-zA-Z0-9-]/"` is used to remove all characters other than hyphens, letters and digits. | `string` | `null` | no |
| <a name="input_repo"></a> [repo](#input\_repo) | The name of the repo that the Amplify App will be created around. | `string` | n/a | yes |
| <a name="input_stage"></a> [stage](#input\_stage) | Stage, e.g. 'prod', 'staging', 'dev', OR 'source', 'build', 'test', 'deploy', 'release' | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags (e.g. `map('BusinessUnit','XYZ')` | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_arn"></a> [arn](#output\_arn) | The ARN of the main Amplify resource. |
| <a name="output_custom_domains"></a> [custom\_domains](#output\_custom\_domains) | List of custom domains that are associated with this resource (if any). |
| <a name="output_default_domain"></a> [default\_domain](#output\_default\_domain) | The amplify domain (non-custom). |
| <a name="output_develop_webhook_arn"></a> [develop\_webhook\_arn](#output\_develop\_webhook\_arn) | The ARN of the develop webhook. |
| <a name="output_develop_webhook_url"></a> [develop\_webhook\_url](#output\_develop\_webhook\_url) | The URL of the develop webhook. |
| <a name="output_domain_association_arn"></a> [domain\_association\_arn](#output\_domain\_association\_arn) | The ARN of the domain association resource. |
| <a name="output_master_webhook_arn"></a> [master\_webhook\_arn](#output\_master\_webhook\_arn) | The ARN of the master webhook. |
| <a name="output_master_webhook_url"></a> [master\_webhook\_url](#output\_master\_webhook\_url) | The URL of the master webhook. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
