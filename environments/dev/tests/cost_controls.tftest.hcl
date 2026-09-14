# All providers are mocked. Every run uses plan; no Azure calls or real resources.
mock_provider "azurerm" {
  mock_data "azurerm_client_config" {
    defaults = {
      tenant_id = "00000000-0000-0000-0000-000000000001"
      object_id = "00000000-0000-0000-0000-000000000002"
    }
  }
}
mock_provider "random" {}

run "stable_governance_tags" {
  command = plan
  variables {
    project_name = "lab-app"
    common_tags = {
      CostCenter = "learning"
      Owner      = "override"
      owner      = "override-lowercase"
      CreatedAt  = "should-be-ignored"
    }
  }
  assert {
    condition = tomap(module.app_infrastructure.common_tags) == tomap({
      Environment = "dev"
      Project     = "lab-app"
      ManagedBy   = "Terraform"
      Owner       = "portfolio"
      CostCenter  = "learning"
    })
    error_message = "Tags devem ser estáveis, preservar extras e proteger campos reservados inclusive variações de caixa."
  }
  assert {
    condition     = output.resource_group_name == "rg-lab-app-dev"
    error_message = "O formato de nomes existente deve ser preservado."
  }
}

variables {
  subscription_id = "00000000-0000-0000-0000-000000000000"
  project_name    = "costtest"
  owner           = "portfolio"
}

run "compute_disabled_by_default" {
  command = plan
  assert {
    condition     = length(output.vm_ids) == 0 && length(output.vm_private_ips) == 0
    error_message = "O default deve planejar zero VMs e NICs."
  }
  assert {
    condition     = module.app_infrastructure.admin_password_secret_id == null
    error_message = "Sem VMs, o secret de compute não deve existir."
  }
}

run "one_vm_explicitly_enabled" {
  command = plan
  variables {
    admin_ssh_public_key = trimspace(file("tests/mock_rsa.pub"))
    admin_source_cidrs   = ["10.0.2.10/32"]
    vm_count             = 1
    vm_size              = "Standard_B2s"
  }
  assert {
    condition     = length(output.vm_ids) == 1 && length(output.vm_private_ips) == 1
    error_message = "Habilitar compute deve planejar exatamente uma VM e NIC."
  }
  assert {
    condition     = output.deployment_summary.vm_size == "Standard_B2s"
    error_message = "O SKU escolhido no DEV deve chegar ao orquestrador."
  }
}

run "reject_multiple_vms" {
  command = plan
  variables { vm_count = 2 }
  expect_failures = [var.vm_count]
}

run "reject_negative_vm_count" {
  command = plan
  variables { vm_count = -1 }
  expect_failures = [var.vm_count]
}

run "reject_fractional_vm_count" {
  command = plan
  variables { vm_count = 0.5 }
  expect_failures = [var.vm_count]
}

run "reject_unreviewed_sku" {
  command = plan
  variables { vm_size = "Standard_D2s_v3" }
  expect_failures = [var.vm_size]
}

run "reject_premium_storage" {
  command = plan
  variables { storage_account_tier = "Premium" }
  expect_failures = [var.storage_account_tier]
}

run "reject_geo_redundant_storage" {
  command = plan
  variables { storage_replication_type = "GRS" }
  expect_failures = [var.storage_replication_type]
}
