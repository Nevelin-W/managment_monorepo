terraform {
  cloud {
    organization = "YOUR_ORG_NAME"  # Replace with your HashiCorp Cloud org
    
    workspaces {
      name = "subtrack-prod"
    }
  }
}