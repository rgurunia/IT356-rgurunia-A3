#Defines the provider and region
provider "aws" {
  region = "us-east-2"
}

# This module defines and creates the VPC
module "school-vpc-01" {
  source = "terraform-aws-modules/vpc/aws"
#Defines name and IPv4
  name = "school-vpc-01"
  cidr = "10.0.0.0/23"
#AZs and how many subnets there are
  azs             = ["eu-east-2a"]
  private_subnets = ["10.0.1.0/24"]
  public_subnets  = ["10.0.101.0/24"]

  enable_nat_gateway = true
  enable_vpn_gateway = true

  tags = {
    Terraform = "true"
    Environment = "dev"
  }
}

#Creates the 2 Domain Controllers
data "aws_ami" "windows_2025" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["Windows_Server-2025-English-Full-Base-*"]
  }
}

resource "aws_security_group" "ad_sg" {
  name        = "DomainControllers"
  description = "Allow AD DS, DNS, and RDP traffic"
  vpc_id      = "vpc-xxxxxxxx" # Replace with your VPC ID

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
    cidr_blocks = ["YOUR_IP/32"] # Restrict RDP access
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#First Domain Controller
resource "aws_instance" "domain_controller-1" {
  ami                    = data.aws_ami.windows_2025.id
  instance_type          = "t3.medium"
  subnet_id              = "subnet-xxxxxxxx" # Replace with your Subnet ID
  private_ip             = "10.0.1.10"       # Static private IP is recommended for DNS
  vpc_security_group_ids = [aws_security_group.ad_sg.id] #Replace?
  key_name               = "your-key-pair"

  user_data = <<-EOF
    <powershell>
    # 1. Install AD DS, DNS, and Management Tools
    Install-WindowsFeature -Name AD-Domain-Services, DNS -IncludeManagementTools

    # 2. Promote to Domain Controller and create a new Forest
    $DomainName = "://school1.aa.edu"
    $SafeModePassword = ConvertTo-SecureString "P@ssw0rd1234!" -AsPlainText -Force

    Install-ADDSForest `
      -DomainName $school1.aa.edu `
      -SafeModeAdministratorPassword $SafeModePassword `
      -InstallDns:$true `
      -Force:$true
    </powershell>
  EOF

  tags = {
    Name = "Primary-Domain-Controller"
  }

#2nd Domain Controller
resource "aws_instance" "domain_controller-2" {
  ami                    = data.aws_ami.windows_2025.id
  instance_type          = "t3.medium"
  subnet_id              = "subnet-xxxxxxxx" # Replace with your Subnet ID
  private_ip             = "10.0.1.10"       # Static private IP is recommended for DNS
  vpc_security_group_ids = [aws_security_group.ad_sg.id] #Replace
  key_name               = "your-key-pair"

  user_data = <<-EOF
    <powershell>
    # 1. Install AD DS, DNS, and Management Tools
    Install-WindowsFeature -Name AD-Domain-Services, DNS -IncludeManagementTools

    # 2. Promote to Domain Controller and create a new Forest
    $DomainName = "://school2.aa.edu "
    $SafeModePassword = ConvertTo-SecureString "P@ssw0rd1234!" -AsPlainText -Force

    Install-ADDSForest `
      -DomainName $school2.aa.edu `
      -SafeModeAdministratorPassword $SafeModePassword `
      -InstallDns:$true `
      -Force:$true
    </powershell>
  EOF

  tags = {
    Name = "Secondary-Domain-Controller"
  }
}
