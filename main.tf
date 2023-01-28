terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
}

# Configure the DigitalOcean Provider
provider "digitalocean" {
  token = var.token
}

# Create droplet for Jenkinks

data "digitalocean_ssh_key" "my-ssh-key" {
  name = var.ssh-name
}

resource "digitalocean_droplet" "jenkins" {
  image    = "ubuntu-22-04-x64"
  name     = "jenkins"
  region   = var.region
  size     = "s-2vcpu-2gb"
  ssh_keys = [data.digitalocean_ssh_key.my-ssh-key.id]
}

# Create a cluster with Kuburnetes

resource "digitalocean_kubernetes_cluster" "my-cluster" {
  name    = "k8s"
  region  = var.region
  version = "1.25.4-do.0"

  node_pool {
    name       = "worker-pool"
    size       = "s-2vcpu-2gb"
    node_count = 2
  }
}

# Define ambient variables

variable "token" {
  default = ""
}

variable "region" {
  default = "nyc1"
}

variable "ssh-name" {
  default = ""
}

# droplet Jenkins IP

output "jenkins-ip" {
  value = digitalocean_droplet.jenkins.ipv4_address
}

# create a file with .kube.config inside

resource "local_file" "kube-config" {
  content  = digitalocean_kubernetes_cluster.my-cluster.kube_config.0.raw_config
  # filename = "/home/luiz/Documentos/config"
  filename = "/home/luiz/.kube/config"
}
