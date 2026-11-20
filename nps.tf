#Creates Windows Server
data "aws_ami" "windows_2025" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["Windows_Server-2025-English-Full-Base-*"]
  }
}

#Creates NPS SG
resource "aws_security_group" "nps_sg" {
  name        = "NPS"
  description = "Allow RADIUS authentication/accounting and RDP traffic"

  # RADIUS Authentication (UDP 1812 & legacy 1645)
  ingress {
    description = "RADIUS Authentication"
    from_port   = 1812
    to_port     = 1812
    protocol    = "udp"
    cidr_blocks = ["10.0.0.0/8"]
  }

  # RADIUS Accounting (UDP 1813 & legacy 1646)
  ingress {
    description = "RADIUS Accounting"
    from_port   = 1813
    to_port     = 1813
    protocol    = "udp"
    cidr_blocks = ["10.0.0.0/8"] 
  }

  # RDP Access
  ingress {
    description = "RDP Management"
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # 
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#Creates NPS Server
resource "aws_instance" "NPS Server" {
  ami                    = data.aws_ami.windows_2025.id
  instance_type          = "c5.xlarge" #Required type for Windows Systems
  subnet_id              = "subnet-0a020415a53eb76f8" # Subnet ID
  private_ip             = "10.0.1.40"       # Static private IP
  vpc_security_group_ids = [aws_security_group.nps_sg.id]

  user_data = <<-EOF
    <powershell>
    # 1. Installs NPS and Management Tools
    Install-WindowsFeature -Name NPAS -IncludeManagementTools

    # 2. Joins and adds the the instance to the AD
    $domain = "://school1.aa.edu"
    $password = ConvertTo-SecureString "${var.ad_join_password}" -AsPlainText -Force
    $credential = New-Object System.Management.Automation.PSCredential("CORP\Admin", $password)
    Add-Computer -DomainName $domain -Credential $credential -Restart -Force

     </powershell>
  EOF
  
# Of note, manually configuration is still needed for the RADIUS Clients and Policies
# This issue will be solved with the "radius.tf" file.

  tags = {
    Name = "NPS-Server"
  }

#This creates a variable for a directory_id for RADIUS configuration
variable "directory_id" {
  type = string
  default = "radius_server_id"
}
