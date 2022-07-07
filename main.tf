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

data "aws_iam_policy_document" "assume_role" {
  count = module.this.enabled && var.amplify_service_role_enabled ? 1 : 0

  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["amplify.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "default" {
  count = module.this.enabled && var.amplify_service_role_enabled ? 1 : 0

  name                = "cogniwide-webapp"
  assume_role_policy  = join("", data.aws_iam_policy_document.assume_role.*.json)
  managed_policy_arns = ["arn:aws:iam::aws:policy/AdministratorAccess"]
  tags                = module.this.tags
}

resource "aws_amplify_app" "this" {
  name                     = "cogniwide-webapp"
  description              = var.description != null ? var.description : "Amplify App for the github.com/${var.organization}/${var.repo} project."
  repository               = "https://github.com/${var.organization}/${var.repo}"
  access_token             = var.gh_access_token
  enable_branch_auto_build = true
  build_spec               = var.build_spec_content != "" ? var.build_spec_content : null
  environment_variables    = var.global_environment_variables
  iam_service_role_arn     = var.amplify_service_role_enabled ? aws_iam_role.default[0].arn : null
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

  lifecycle {
    ignore_changes = [platform, custom_rule]
  }
}

resource "aws_amplify_branch" "master" {
  app_id                  = aws_amplify_app.this.id
  branch_name             = var.master_branch_name
  display_name            = module.master_branch_label.id
  tags                    = module.master_branch_label.tags
  backend_environment_arn = var.master_backend_environment_enabled ? aws_amplify_backend_environment.master[0].arn : null

  environment_variables = var.master_environment_variables

  enable_basic_auth      = var.enable_basic_auth_on_master
  basic_auth_credentials = local.basic_auth_creds

  lifecycle {
    ignore_changes = [framework]
  }
}


resource "aws_amplify_backend_environment" "master" {
  count            = var.master_backend_environment_enabled ? 1 : 0
  app_id           = aws_amplify_app.this.id
  environment_name = var.master_branch_name
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


}


