terraform {

  required_version = ">=0.12"

  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "~>2.0"
    }
  }
}

provider "azurerm" {
  features {}
}
resource "azurerm_resource_group" "practice_vm" {
  name     = "practice-resources"
  location = "East US"
}

resource "azurerm_virtual_network" "practice_vm" {
  name                = "practice-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.practice_vm.location
  resource_group_name = azurerm_resource_group.practice_vm.name
}

resource "azurerm_subnet" "practice_vm" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.practice_vm.name
  virtual_network_name = azurerm_virtual_network.practice_vm.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_public_ip" "practice_vm" {
  name                = "myPublicIP"
  location            = azurerm_resource_group.practice_vm.location
  resource_group_name = azurerm_resource_group.practice_vm.name
  allocation_method   = "Dynamic"
}

resource "azurerm_network_security_group" "practice_vm" {
  name                = "myNetworkSecurityGroup"
  location            = azurerm_resource_group.practice_vm.location
  resource_group_name = azurerm_resource_group.practice_vm.name

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_interface" "practice_vm" {
  name                = "example-nic"
  location            = azurerm_resource_group.practice_vm.location
  resource_group_name = azurerm_resource_group.practice_vm.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.practice_vm.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.practice_vm.id
  }
}

resource "azurerm_network_interface_security_group_association" "practice_vm" {
  network_interface_id      = azurerm_network_interface.practice_vm.id
  network_security_group_id = azurerm_network_security_group.practice_vm.id
}

resource "azurerm_linux_virtual_machine" "practice_vm" {
  name                = "practice-machine"
  resource_group_name = azurerm_resource_group.practice_vm.name
  location            = azurerm_resource_group.practice_vm.location
  size                = "Standard_F2"
  admin_username      = "adminuser"
  network_interface_ids = [
    azurerm_network_interface.practice_vm.id,
  ]

  admin_ssh_key {
    username   = "adminuser"
    public_key = file("id_rsa.pub.txt")
  }
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
}