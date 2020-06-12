/**
 * [![Masterpoint Logo](https://i.imgur.com/RDLnuQO.png)](https://masterpoint.io)
 *
 * # terraform-aws-amplify-app
 *
 * A Terraform module for building simple Amplify apps. This creates the `master` and `develop` branches, sets up the domain association, and creates webhooks for both branches.
 *
 * NOTE: This is currently using [@k24d's Amplify resources](https://github.com/terraform-providers/terraform-provider-aws/issues/6917#issuecomment-626309424) which are still up on PR and not currently merged into [terraform-provider-aws](https://github.com/terraform-providers/terraform-provider-aws). To use this today, you can use [these instructions](https://github.com/k24d/terraform-provider-aws/blob/amplify/README-amplify.md). While this notice is still up, please be sure to go and upvote [the main Amplify resource PR #11928](https://github.com/terraform-providers/terraform-provider-aws/pull/11928) so we can get that merged by the AWS provider team.
 *
 * ## Usage
 *
 *
 * ```hcl
 * provider "aws" {
 *   region = "us-east-1"
 * }
 *
 * module "amplify" {
 *   source = "git::https://github.com/masterpointio/terraform-aws-amplify-app.git?ref=tags/0.1.0"
 *
 *   namespace                    = var.namespace
 *   stage                        = var.stage
 *   name                         = "mattgowie"
 *   organization                 = "Gowiem"
 *   repo                         = "mattgowie.com"
 *   gh_access_token              = var.gh_access_token
 *   domain_name                  = "mattgowie.com"
 *   description                  = "The Personal site of Matt Gowie."
 *   enable_basic_auth_on_master  = false
 *   enable_basic_auth_on_develop = true
 *   basic_auth_username          = var.basic_auth_username
 *   basic_auth_password          = var.basic_auth_password
 *   develop_pull_request_preview = true
 *
 *   custom_rules = [{
 *     source    = "https://www.mattgowie.com"
 *     target    = "https://mattgowie.com"
 *     status    = "301"
 *     condition = null
 *   }, {
 *     source    = "/<*>"
 *     target    = "/index.html"
 *     status    = "404"
 *     condition = null
 *   }]
 * }
 * ```
 *
 *
 * ## Credits
 *
 * 1. [@k24d](https://github.com/k24d)'s creation of the Amplify Resources for the AWS Provider!
 * 1. [cloudposse/terraform-null-label](https://github.com/cloudposse/terraform-null-label)
 *
 */

# main.tf

module "root_label" {
  source      = "git::https://github.com/cloudposse/terraform-null-label.git?ref=tags/0.16.0"
  namespace   = var.namespace
  stage       = var.stage
  name        = var.name
  environment = var.environment
  delimiter   = var.delimiter
  attributes  = var.attributes
  tags        = var.tags
}

module "master_branch_label" {
  source      = "git::https://github.com/cloudposse/terraform-null-label.git?ref=tags/0.16.0"
  namespace   = var.namespace
  stage       = var.stage
  name        = var.name
  environment = var.environment
  delimiter   = var.delimiter
  attributes  = concat(var.attributes, ["master"])
  tags        = var.tags
}

module "develop_branch_label" {
  source      = "git::https://github.com/cloudposse/terraform-null-label.git?ref=tags/0.16.0"
  namespace   = var.namespace
  stage       = var.stage
  name        = var.name
  environment = var.environment
  delimiter   = var.delimiter
  attributes  = concat(var.attributes, ["develop"])
  tags        = var.tags
}

data "local_file" "build_spec" {
  filename = "${path.module}/build_spec.yml"
}

resource "aws_amplify_app" "this" {
  name                     = module.root_label.id
  description              = var.description != null ? var.description : "Amplify App for the github.com/${var.organization}/${var.repo} project."
  repository               = "https://github.com/${var.organization}/${var.repo}"
  access_token             = var.gh_access_token
  enable_branch_auto_build = true
  build_spec               = var.build_spec_content != "" ? var.build_spec_content : data.local_file.build_spec.content
  tags                     = module.root_label.tags

  dynamic "custom_rules" {
    for_each = var.custom_rules
    iterator = rule

    content {
      source    = rule.value.source
      target    = rule.value.target
      status    = rule.value.status
      condition = lookup(rule.value, "condition", null)
    }
  }
}

resource "aws_amplify_branch" "master" {
  app_id       = aws_amplify_app.this.id
  branch_name  = var.master_branch_name
  display_name = module.master_branch_label.id
  tags         = module.master_branch_label.tags

  basic_auth_config {
    enable_basic_auth = var.enable_basic_auth_on_master
    username          = var.basic_auth_username
    password          = var.basic_auth_password
  }
}

resource "aws_amplify_branch" "develop" {
  app_id                      = aws_amplify_app.this.id
  branch_name                 = var.develop_branch_name
  display_name                = module.develop_branch_label.id
  enable_pull_request_preview = var.develop_pull_request_preview
  tags                        = module.develop_branch_label.tags

  basic_auth_config {
    enable_basic_auth = var.enable_basic_auth_on_develop
    username          = var.basic_auth_username
    password          = var.basic_auth_password
  }
}

resource "aws_amplify_domain_association" "this" {
  count = var.domain_name != "" ? 1 : 0

  app_id      = aws_amplify_app.this.id
  domain_name = var.domain_name

  sub_domain_settings {
    branch_name = aws_amplify_branch.master.branch_name
    prefix      = ""
  }

  sub_domain_settings {
    branch_name = aws_amplify_branch.master.branch_name
    prefix      = "www"
  }

  sub_domain_settings {
    branch_name = aws_amplify_branch.master.branch_name
    prefix      = "master"
  }

  sub_domain_settings {
    branch_name = aws_amplify_branch.develop.branch_name
    prefix      = "dev"
  }
}

resource "aws_amplify_webhook" "master" {
  app_id      = aws_amplify_app.this.id
  branch_name = aws_amplify_branch.master.branch_name
  description = "trigger-master"

  # NOTE: We trigger the webhook via local-exec so as to kick off the first build on creation of Amplify App.
  provisioner "local-exec" {
    command = "curl -X POST -d {} '${aws_amplify_webhook.master.url}&operation=startbuild' -H 'Content-Type:application/json'"
  }
}

resource "aws_amplify_webhook" "develop" {
  app_id      = aws_amplify_app.this.id
  branch_name = aws_amplify_branch.develop.branch_name
  description = "trigger-develop"

  # NOTE: We trigger the webhook via local-exec so as to kick off the first build on creation of Amplify App.
  provisioner "local-exec" {
    command = "curl -X POST -d {} '${aws_amplify_webhook.develop.url}&operation=startbuild' -H 'Content-Type:application/json'"
  }
}
