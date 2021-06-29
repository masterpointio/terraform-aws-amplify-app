locals {
  basic_auth_creds = try(base64encode("${var.basic_auth_username}:${var.basic_auth_password}"), null)
}

module "master_branch_label" {
  source  = "cloudposse/label/null"
  version = "0.24.1"

  attributes = concat(var.attributes, ["master"])

  context = module.this.context
}

module "develop_branch_label" {
  source  = "cloudposse/label/null"
  version = "0.24.1"

  attributes = concat(var.attributes, ["develop"])

  context = module.this.context
}

resource "aws_amplify_app" "this" {
  name                     = module.this.id
  description              = var.description != null ? var.description : "Amplify App for the github.com/${var.organization}/${var.repo} project."
  repository               = "https://github.com/${var.organization}/${var.repo}"
  access_token             = var.gh_access_token
  enable_branch_auto_build = true
  build_spec               = var.build_spec_content != "" ? var.build_spec_content : null
  environment_variables    = var.global_environment_variables
  tags                     = module.this.tags

  enable_basic_auth      = var.enable_basic_auth_globally
  basic_auth_credentials = local.basic_auth_creds

  dynamic "custom_rule" {
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

  environment_variables = var.master_environment_variables

  enable_basic_auth      = var.enable_basic_auth_on_master
  basic_auth_credentials = local.basic_auth_creds
}

resource "aws_amplify_branch" "develop" {
  app_id                      = aws_amplify_app.this.id
  branch_name                 = var.develop_branch_name
  display_name                = module.develop_branch_label.id
  enable_pull_request_preview = var.develop_pull_request_preview
  tags                        = module.develop_branch_label.tags

  environment_variables = var.develop_environment_variables

  enable_basic_auth      = var.enable_basic_auth_on_develop
  basic_auth_credentials = local.basic_auth_creds
}

resource "aws_amplify_domain_association" "this" {
  count = var.domain_name != "" ? 1 : 0

  app_id      = aws_amplify_app.this.id
  domain_name = var.domain_name

  sub_domain {
    branch_name = aws_amplify_branch.master.branch_name
    prefix      = ""
  }

  sub_domain {
    branch_name = aws_amplify_branch.master.branch_name
    prefix      = "www"
  }

  sub_domain {
    branch_name = aws_amplify_branch.master.branch_name
    prefix      = "master"
  }

  sub_domain {
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
