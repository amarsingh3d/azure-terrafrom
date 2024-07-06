
variable "region" {
  default = "West Europe"

}

#######################################################
# Virtual Netwroks Variables                          #
#######################################################
variable "vnet" {
  description = "Configuration for each Vnet"
  type = map(object({
    location            = string
    address_space       = list(string)
    subnet1             = map(string)
    subnet2             = optional(map(string))
    tags                = map(string)
    resource_group_name = string
  }))

  default = {
    dev = {
      location            = "West Europe"
      address_space       = ["10.0.0.0/16"]
      resource_group_name = "dev-resource-group"
      subnet1 = {
        name           = "dev_subnet1"
        address_prefix = "10.0.1.0/24"
      }

      tags = {
        Env        = "dev"
        Name       = "dev"
        Automation = "Terraform"
      }
    },
    prod = {
      location            = "East US"
      address_space       = ["11.0.0.0/16"]
      resource_group_name = "prod-resource-group"
      subnet1 = {
        name           = "prod_subnet1"
        address_prefix = "11.0.1.0/24"
      }
      subnet2 = {
        name           = "prod_subnet2"
        address_prefix = "11.0.2.0/24"
      }
      tags = {
        Env        = "Prod"
        Name       = "Prod"
        Automation = "Terraform"
      }
    }
  }
}

#######################################################
# Virtual Machines Variables                          #
#######################################################
variable "vm_instances" {
  description = "Configuration for each Virtual Machine"
  type = map(object({
    resource_group_name           = string
    size                          = string
    admin_username                = string
    network_interface_ids         = list(string)
    admin_ssh_key                 = string
    os_disk                       = map(string)
    source_image_reference        = map(string)
    location                      = string
    subnet_id                     = optional(list(string))
    private_ip_address_allocation = optional(string)
    tags                          = map(string)
    count                         = number

  }))


  default = {
    dev = {
      count               = "1"
      location            = "West Europe"
      resource_group_name = "dev-resource-group"
      network_interface_ids = [
        ""
      ]
      size           = "Standard_B1s"
      admin_username = "devadmin"
      admin_ssh_key  = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDERT8JttlolL0H4AwAnOaOvebDim0hq5GiCM3cF8/37t4EDgmtXeYibf9jGZNy26pLwXmA56VL0cX4QzLAFAcQx0kSyQzfvJOK724Nx2PhWI3q/ZwzTjXoqulVuu0HwpbswpGaztJIRxXpfQvcBzF6QG1PYQeMbd/FmqYTb3z3xswHam/jj1duRbE8uKZuwphmFDwegbILa02zzqhYLs5WhiPjLmbWF9hmPhRWNnvokKes8ME4pI30d2tsOjKSM311ieF7B/hMdTBr+yh5UEqxP8uAGXkwAklRSab5tDnqtbf17jINJG6qz3kXZYHVedpP8aTcDqha6ACBNHZLofVNGfQsRFxIkf0XajMAabWVUnpt/n1KBfF7L2Tnty3//9p5A4n6zeO4bLWsK5utitOZ5+T1qfKQo2cBDmZkfdYFpoSc5yDQo3Yr31W93tDsAK01hVQbsOuOeu5Wr7QfZ8zTG+/g8anBJHWgR5qHpETxxU00usNCuhyO9G/h1c8QPi8= root@INHL1250"
      os_disk = {
        caching              = "ReadWrite"
        storage_account_type = "Standard_LRS"
      }

      source_image_reference = {
        publisher = "Canonical"
        offer     = "0001-com-ubuntu-server-jammy"
        sku       = "22_04-lts"
        version   = "latest"
      }
      tags = {
        Name       = "Dev"
        ENV        = "Dev"
        Automation = "Terraform"
      }
    },
    prod = {
      count               = "1"
      location            = "East US"    
      resource_group_name = "prod-resource-group"
      network_interface_ids = [
        ""
      ]
      size           = "Standard_GS1"
      admin_username = "prodadmin"
      admin_ssh_key  = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDERT8JttlolL0H4AwAnOaOvebDim0hq5GiCM3cF8/37t4EDgmtXeYibf9jGZNy26pLwXmA56VL0cX4QzLAFAcQx0kSyQzfvJOK724Nx2PhWI3q/ZwzTjXoqulVuu0HwpbswpGaztJIRxXpfQvcBzF6QG1PYQeMbd/FmqYTb3z3xswHam/jj1duRbE8uKZuwphmFDwegbILa02zzqhYLs5WhiPjLmbWF9hmPhRWNnvokKes8ME4pI30d2tsOjKSM311ieF7B/hMdTBr+yh5UEqxP8uAGXkwAklRSab5tDnqtbf17jINJG6qz3kXZYHVedpP8aTcDqha6ACBNHZLofVNGfQsRFxIkf0XajMAabWVUnpt/n1KBfF7L2Tnty3//9p5A4n6zeO4bLWsK5utitOZ5+T1qfKQo2cBDmZkfdYFpoSc5yDQo3Yr31W93tDsAK01hVQbsOuOeu5Wr7QfZ8zTG+/g8anBJHWgR5qHpETxxU00usNCuhyO9G/h1c8QPi8= root@INHL1250"
      os_disk = {
        caching              = "ReadWrite"
        storage_account_type = "Standard_LRS"
      }

      source_image_reference = {
        publisher = "Canonical"
        offer     = "0001-com-ubuntu-server-jammy"
        sku       = "22_04-lts"
        version   = "latest"
      }
      tags = {
        Name       = "Prod"
        ENV        = "Prod"
        Automation = "Terraform"
      }
    }
  }
}
