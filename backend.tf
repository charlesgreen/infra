terraform {
  cloud {
    organization = "simplyhey"
    hostname     = "app.terraform.io"

    workspaces {
      tags = ["infra-dev"]
    }
  }
}
