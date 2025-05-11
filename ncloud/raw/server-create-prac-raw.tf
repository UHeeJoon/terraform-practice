terraform {
  required_providers {
    ncloud = {
      source = "NaverCloudPlatform/ncloud"
    }
  }
  required_version = ">= 0.13"
}

provider "ncloud" {}


variable "region" {
  type    = string
  default = "KR"
}

variable "site" {
  type    = string
  default = "public"
}

variable "my_ip" {
  type    = string
  default = "61.43.126.244/32"
}

variable "server_count" {
  type    = number
  default = 1
}

# vpc
resource "ncloud_vpc" "t_vpc" {
  name            = "t-vpc"
  ipv4_cidr_block = "10.0.0.0/16"
}

# nacl
resource "ncloud_network_acl" "t_nacl" {
  name   = "t-nacl"
  vpc_no = ncloud_vpc.t_vpc.id
}

# t_nacl rule
resource "ncloud_network_acl_rule" "t_nacl_rule" {
  network_acl_no = ncloud_network_acl.t_nacl.id

  inbound {
    priority    = 1
    protocol    = "TCP"
    rule_action = "ALLOW"
    ip_block    = "0.0.0.0/0"
    port_range  = "80"
  }

  inbound {
    priority    = 2
    protocol    = "TCP"
    rule_action = "ALLOW"
    ip_block    = var.my_ip
    port_range  = "22"
  }

  inbound {
    priority    = 3
    protocol    = "ICMP"
    rule_action = "ALLOW"
    ip_block    = "0.0.0.0/0"
  }

  inbound {
    priority    = 199
    protocol    = "TCP"
    rule_action = "DROP"
    ip_block    = "0.0.0.0/0"
    port_range  = "22"
  }

  outbound {
    priority    = 1
    protocol    = "TCP"
    rule_action = "ALLOW"
    ip_block    = "0.0.0.0/0"
    port_range  = "1-65535"
  }

  outbound {
    priority    = 2
    protocol    = "UDP"
    rule_action = "ALLOW"
    ip_block    = "0.0.0.0/0"
    port_range  = "1-65535"
  }
}

# subnet
resource "ncloud_subnet" "t_subnet" {
  name           = "t-subnet-01"
  vpc_no         = ncloud_vpc.t_vpc.id
  subnet         = cidrsubnet(ncloud_vpc.t_vpc.ipv4_cidr_block, 8, 1)
  zone           = "KR-2"
  network_acl_no = ncloud_network_acl.t_nacl.id
  subnet_type    = "PUBLIC"
  usage_type     = "GEN"
}

# acg
resource "ncloud_access_control_group" "acg" {
  name   = "t-acg"
  vpc_no = ncloud_vpc.t_vpc.id
}

# acg rule 
resource "ncloud_access_control_group_rule" "t_acg_rule" {
  access_control_group_no = ncloud_access_control_group.acg.id

  inbound {
    protocol = "ICMP"
    ip_block = "0.0.0.0/0"
  }

  inbound {
    protocol   = "TCP"
    ip_block   = "0.0.0.0/0"
    port_range = 80
  }

  inbound {
    protocol   = "TCP"
    ip_block   = var.my_ip
    port_range = 22
  }

  outbound {
    protocol = "ICMP"
    ip_block = "0.0.0.0/0"
  }

  outbound {
    protocol   = "TCP"
    ip_block   = "0.0.0.0/0"
    port_range = "1-65535"
  }

  outbound {
    protocol   = "UDP"
    ip_block   = "0.0.0.0/0"
    port_range = "1-65535"
  }
}

# network interface
resource "ncloud_network_interface" "t-nic" {
  name                  = "t-nic"
  subnet_no             = ncloud_subnet.t_subnet.id
  access_control_groups = [ncloud_access_control_group.acg.id]
}

#public ip
resource "ncloud_public_ip" "t_public_ip" {
  count              = length(ncloud_server.t_server)
  server_instance_no = ncloud_server.t_server[count.index].instance_no
}

resource "ncloud_login_key" "loginkey" {
  key_name = "t-loginkey"
}

resource "local_file" "login_key_pem" {
  content         = ncloud_login_key.loginkey.private_key
  filename        = "${path.module}/t-loginkey.pem"
  file_permission = "0600"
}

data "ncloud_server_image_numbers" "kvm-image" {
  server_image_name = "rocky-9.4-base"
  filter {
    name   = "hypervisor_type"
    values = ["KVM"]
  }
}

data "ncloud_server_specs" "kvm-spec" {
  filter {
    name   = "server_spec_code"
    values = ["c2-g3"]
  }
}

resource "ncloud_server" "t_server" {
  count = var.server_count

  subnet_no           = ncloud_subnet.t_subnet.id
  name                = "t-server"
  server_image_number = data.ncloud_server_image_numbers.kvm-image.image_number_list.0.server_image_number
  server_spec_code    = data.ncloud_server_specs.kvm-spec.server_spec_list.0.server_spec_code
  login_key_name      = ncloud_login_key.loginkey.key_name
  network_interface {
    network_interface_no = ncloud_network_interface.t-nic.id
    order                = 0
  }
}

output "public_ip_addresses" {
  value = [for ip in ncloud_public_ip.t_public_ip : ip.public_ip]
}

output "login_key_fingerprint" {
  value = {
    id          = ncloud_login_key.loginkey.id
    fingerprint = ncloud_login_key.loginkey.fingerprint
  }
}