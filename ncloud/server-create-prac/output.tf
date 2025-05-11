output "public_ip_addresses" {
  value = [for ip in ncloud_public_ip.t_public_ip : ip.public_ip]
}

output "login_key_fingerprint" {
  value = {
    id          = ncloud_login_key.loginkey.id
    fingerprint = ncloud_login_key.loginkey.fingerprint
  }
}