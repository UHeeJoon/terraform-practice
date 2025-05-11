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