resource "radius_settings" "radius_set" {
  directory_id = var.radius_server_id

  authentication_protocol = "PAP" #Protocol RADIUS endpoits use, PAP will be the default
  display_label           = "radius"
  radius_port             = 1812
  radius_retries          = 4
  radius_servers          = ["10.0.1.40"] #Same IP as the NPS EC2 Instance
  radius_timeout          = 1
  shared_secret           = "12345678" #Default shared secret, change when needed
}
