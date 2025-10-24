terraform {
  cloud {
    organization = "applications"  # Replace with your HashiCorp Cloud org
    
    workspaces {
      name = "subtracker_dev"
    }
  }
}