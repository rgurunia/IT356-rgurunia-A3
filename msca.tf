#Creates Windows Server
data "aws_ami" "windows_2025" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["Windows_Server-2025-English-Full-Base-*"]
  }
}

#Creates MSCA SG
resource "aws_security_group" "mcsa_sg" {
  name        = "MSCA"
  description = "Allow LDAP, DNS, and RDP traffic"
  vpc_id      = "vpc-034fa96301cadd243" #VPC ID for the VPC that was Created

  # DNS (TCP/UDP 53), Kerberos (88), LDAP (389), SMB (445), RDP (3389)
  ingress {
    from_port   = 53
    to_port     = 53
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }
  ingress {
    from_port   = 53
    to_port     = 53
    protocol    = "udp"
    cidr_blocks = ["10.0.0.0/16"]
  }
  ingress {
    from_port   = 389
    to_port     = 389
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }
  ingress {
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = ["IP/32"] # Restrict RDP access to admin
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#Creates MSCA
resource "aws_instance" "MCCA Server" {
  ami                    = data.aws_ami.windows_2025.id
  instance_type          = "t3.medium"
  subnet_id              = "subnet-0a020415a53eb76f8" # Subnet ID
  private_ip             = "10.0.1.30"       # Static private IP
  vpc_security_group_ids = [aws_security_group.mcsa_sg.id]
  key_name               = "your-key-pair"

  user_data = <<-EOF
    <powershell>
    # 1. Installs ADCS and Management Tools
    Install-WindowsFeature -Name ADCS-Cert-Authority -IncludeManagementTools

    # 2. Creates the MSCA
    Install-AdcsCertificationAuthority -CAType StandaloneRootCA -CACommonName "My-MSCA-Root" -KeyLength 2048 -HashAlgorithmName SHA256 -CryptoProviderName "RSA#Microsoft Software Key Storage Provider" -ValidityPeriod Years -ValidityPeriodUnits 5 -Force
    </powershell>
  EOF

  tags = {
    Name = "MSCA-Server"
  }
