#Creates 2 Linux Systems running Ubuntu 26.04 on the Private Subnet
resource "aws_instance" "Private Linux System" {
  count                  = 2
  ami                    = "ami-0f441bd6af0596ef7"
  instance_type          = "t2.medium" #Required type for Linux Systems
  subnet_id              = "subnet-0a020415a53eb76f8" # Subnet ID
  # private_ip           = "10.0.1.10"       # The Private IP is not needed but if needed, it is here.

  tags = {
    Name = "Private_Linux_System-${count.index + 1}"
  }
}

#Creates 2 Linux Systems running Ubuntu 26.04 on the Public Subnet
resource "aws_instance" "Public Linux System" {
  count                  = 2
  ami                    = "ami-0f441bd6af0596ef7"
  instance_type          = "t2.medium" #Required type for Linux Systems
  subnet_id              = "subnet-0068a0cc04806514d" # Subnet ID
  # private_ip           = "10.0.1.10"       # The Private IP is not needed but if needed, it is here.

  tags = {
    Name = "Public_Linux_System-${count.index + 1}"
  }
}
