data "azurerm_key_vault" "test_kv" {
  name                = "credlock-terraform-kv"
  resource_group_name = "credlock-team-rg"
}

resource "azurerm_key_vault_secret" "test_secret" {
  key_vault_id = data.azurerm_key_vault.test_kv.id
  name         = "test-key"
  value        = "hello hehe"
}