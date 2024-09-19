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
