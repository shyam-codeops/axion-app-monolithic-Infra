rgs = {
  rg1 = {
    name     = "rg-axion-dev-01"
    location = "centralindia"
  }
}

vnets = {
  vnet1 = {
    name                = "vnet-axion-dev-01"
    location            = "centralindia"
    resource_group_name = "rg-axion-dev-01"
    address_space       = ["10.0.0.0/16"]
  }
}

subnets = {
  subnet1 = {
    name                 = "frontend-subnet-axion-dev-01"
    resource_group_name  = "rg-axion-dev-01"
    virtual_network_name = "vnet-axion-dev-01"
    address_prefixes     = ["10.0.1.0/24"]
  }
  subnet2 = {
    name                 = "backend-subnet-axion-dev-01"
    resource_group_name  = "rg-axion-dev-01"
    virtual_network_name = "vnet-axion-dev-01"
    address_prefixes     = ["10.0.2.0/24"]
  }
  # subnet3 = {
  #   name                 = "database-subnet-axion-dev-01"
  #   resource_group_name  = "rg-axion-dev-01"
  #   virtual_network_name = "vnet-axion-dev-01"
  #   address_prefixes     = ["10.0.3.0/24"]
  # }
}


public_ips = {
  pip1 = {
    name                = "pip-frontend-vm-axion-dev-01"
    resource_group_name = "rg-axion-dev-01"
    location            = "centralindia"
    allocation_method   = "Static"
  }
  pip2 = {
    name                = "pip-backend-vm-axion-dev-01"
    resource_group_name = "rg-axion-dev-01"
    location            = "centralindia"
    allocation_method   = "Static"
  }
  # pip3 = {
  #   name                = "pip-database-vm-axion-dev-01"
  #   resource_group_name = "rg-axion-dev-01"
  #   location            = "centralindia"
  #   allocation_method   = "Static"
  # }
}


network_interface = {
  nic1 = {
    nic_name             = "nic-frontend-vm-axion-dev-01"
    location             = "centralindia"
    resource_group_name  = "rg-axion-dev-01"
    subnet_name          = "frontend-subnet-axion-dev-01"
    virtual_network_name = "vnet-axion-dev-01"
    public_ip_name       = "pip-frontend-vm-axion-dev-01"
  }
  nic2 = {
    nic_name             = "nic-backend-vm-axion-dev-01"
    location             = "centralindia"
    resource_group_name  = "rg-axion-dev-01"
    subnet_name          = "backend-subnet-axion-dev-01"
    virtual_network_name = "vnet-axion-dev-01"
    public_ip_name       = "pip-backend-vm-axion-dev-01"
  }
  # nic3 = {
  #   nic_name             = "nic-database-vm-axion-dev-01"
  #   location             = "centralindia"
  #   resource_group_name  = "rg-axion-dev-01"
  #   subnet_name          = "database-subnet-axion-dev-01"
  #   virtual_network_name = "vnet-axion-dev-01"
  #   public_ip_name       = "pip-database-vm-axion-dev-01"
  # }
}

network_security_group = {
  nsg1 = {
    name                   = "nsg-frontend-axion-dev-01"
    location               = "centralindia"
    resource_group_name    = "rg-axion-dev-01"
    nic_name               = "nic-frontend-vm-axion-dev-01"
    destination_allow_port = 22

  }
  nsg2 = {
    name                   = "nsg-backend-axion-dev-01"
    location               = "centralindia"
    resource_group_name    = "rg-axion-dev-01"
    nic_name               = "nic-backend-vm-axion-dev-01"
    destination_allow_port = 22
  }
  # nsg3 = {
  #   name                   = "nsg-database-axion-dev-01"
  #   location               = "centralindia"
  #   resource_group_name    = "rg-axion-dev-01"
  #   nic_name               = "nic-database-vm-axion-dev-01"
  #   destination_allow_port = 22

  # }
}


virtual_machines = {
  vm1 = {
    name                = "frontend-vm-axion-dev-01"
    resource_group_name = "rg-axion-dev-01"
    location            = "centralindia"
    size                = "Standard_B2as_v2"
    admin_username      = "ssadmin"
    admin_password      = "Nested@1234"
    nic_name            = "nic-frontend-vm-axion-dev-01"
  }
  vm2 = {
    name                = "backend-vm-axion-dev-01"
    resource_group_name = "rg-axion-dev-01"
    location            = "centralindia"
    size                = "Standard_B2as_v2"
    admin_username      = "ssadmin"
    admin_password      = "Nested@1234"
    nic_name            = "nic-backend-vm-axion-dev-01"
  }
  # vm3 = {
  #   name                = "database-vm-axion-dev-01"
  #   resource_group_name = "rg-axion-dev-01"
  #   location            = "centralindia"
  #   size                = "Standard_B2as_v2"
  #   admin_username      = "ssadmin"
  #   admin_password      = "Nested@1234"
  #   nic_name            = "nic-database-vm-axion-dev-01"
  # }
}

postgresql_server = {
  postgres1 = {
    name                   = "postgresql-axion-dev-01"
    resource_group_name    = "rg-axion-dev-01"
    location               = "centralindia"
    administrator_login    = "ssadmin"
    administrator_password = "Nested@1234"
    database_name          = "axiondb"
  }
}
