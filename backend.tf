terraform {
  cloud {
    organization = "charlesgreen"
    hostname     = "app.terraform.io"

    workspaces {
      tags = ["dev", "prod"]
    }
  }
}
