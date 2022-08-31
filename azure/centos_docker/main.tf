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
resource "azurerm_resource_group" "centos_vm" {
  name     = "practice-centos"
  location = "East US"
}

resource "azurerm_virtual_network" "centos_vm" {
  name                = "practice-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.centos_vm.location
  resource_group_name = azurerm_resource_group.centos_vm.name
}

resource "azurerm_subnet" "centos_vm" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.centos_vm.name
  virtual_network_name = azurerm_virtual_network.centos_vm.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_public_ip" "centos_vm" {
  name                = "myPublicIP"
  location            = azurerm_resource_group.centos_vm.location
  resource_group_name = azurerm_resource_group.centos_vm.name
  allocation_method   = "Dynamic"
}

resource "azurerm_network_security_group" "centos_vm" {
  name                = "myNetworkSecurityGroup"
  location            = azurerm_resource_group.centos_vm.location
  resource_group_name = azurerm_resource_group.centos_vm.name

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

resource "azurerm_network_interface" "centos_vm" {
  name                = "example-nic"
  location            = azurerm_resource_group.centos_vm.location
  resource_group_name = azurerm_resource_group.centos_vm.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.centos_vm.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.centos_vm.id
  }
}

resource "azurerm_network_interface_security_group_association" "centos_vm" {
  network_interface_id      = azurerm_network_interface.centos_vm.id
  network_security_group_id = azurerm_network_security_group.centos_vm.id
}

resource "azurerm_linux_virtual_machine" "centos_vm" {
  name                = "practice-machine"
  resource_group_name = azurerm_resource_group.centos_vm.name
  location            = azurerm_resource_group.centos_vm.location
  size                = "Standard_F2"
  admin_username      = "adminuser"
  network_interface_ids = [
    azurerm_network_interface.centos_vm.id,
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
    publisher = "OpenLogic"
    offer     = "CentOS"
    sku       = "7.5"
    version   = "latest"
  }
}