provider "aws" {
  region = "us-east-1"
}

variable "ec2_private_key" {
  type      = string
  sensitive = true
}

resource "aws_instance" "medusa_ec2" {
  ami                    = "ami-0a0e5d9c7acc336f1" #ami id for ubuntu v22.04
  instance_type          = "t2.small" #instance_type small to procees tand avoid the timeout
  key_name               = "Jaswanth"
  vpc_security_group_ids = ["sg-0850c1dc0c3cfdbfb"]

    inline = [
      # Update the package database and install dependencies
      "sudo apt-get update -y",
      "sudo apt-get install -y docker.io",

      # Download Docker Compose
      "sudo curl -L \"https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)\" -o /usr/local/bin/docker-compose",

      # Apply executable permissions to the binary
      "sudo chmod +x /usr/local/bin/docker-compose",

      # Check the version of Docker Compose to ensure it's installed
      "docker-compose --version"
    ]


  tags = {
    Name = "MedusaEC2"
  }

  provisioner "file" {
    source      = "install.sh"
    destination = "/home/ubuntu/install.sh"

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = var.ec2_private_key
      host        = self.public_ip
    }
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /home/ubuntu/install.sh",
      "/home/ubuntu/install.sh"
    ]

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = var.ec2_private_key
      host        = self.public_ip
    }
  }
}

output "ec2_public_ip" {
  value = aws_instance.medusa_ec2.public_ip
}
