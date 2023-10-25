packer {
  required_plugins {
    amazon = {
      version = ">= 0.0.2"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

variable "ami_prefix" {
  type    = string
  default = "wodbooster"
}

locals {
  timestamp = regex_replace(timestamp(), "[- TZ:]", "")
}

source "amazon-ebs" "ubuntu" {
  ami_name      = "${var.ami_prefix}-${local.timestamp}"
  instance_type = "t2.micro"
  region        = "us-east-1"
  source_ami_filter {
    filters = {
      name                = "ubuntu/images/*/ubuntu-*-22.04-amd64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["099720109477"]
  }
  ssh_username = "ubuntu"
}

build {
  name = "wodbooster"
  sources = [
    "source.amazon-ebs.ubuntu"
  ]

  hcp_packer_registry {
    bucket_name = "wodbooster"
    description = "Image with all the dependencies required to run the WodBooster application"

    bucket_labels = {
      "owner"   = "jotadrilo"
      "os"      = "Ubuntu",
      "version" = "22.04",
      "created" = local.timestamp
    }
  }

  provisioner "shell" {
    environment_vars = [
      "DEBIAN_FRONTEND=noninteractive",
    ]
    inline = [
      "sudo apt-get update",
      "sudo apt-get install -y ca-certificates unzip xvfb fluxbox wmctrl gnupg2 curl dbus",
      "curl -fsSL https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add -",
      "echo \"deb http://dl.google.com/linux/chrome/deb/ stable main\" | sudo tee /etc/apt/sources.list.d/google.list",
      "sudo apt-get update",
      "sudo apt-get install -y google-chrome-stable",
      "mkdir -p /etc/apt/keyrings",
      "curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg",
      "echo \"deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_16.x nodistro main\" | sudo tee /etc/apt/sources.list.d/nodesource.list",
      "sudo apt-get update",
      "sudo apt-get install -y nodejs",
      "sudo npm install -g yarn",
      "curl -SLf -o /tmp/main.zip https://github.com/jotadrilo/wodbooster/archive/refs/heads/main.zip",
      "cd $HOME && unzip /tmp/main.zip",
      "cd wodbooster-main/src && yarn install",
    ]
  }
}
