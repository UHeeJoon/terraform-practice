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