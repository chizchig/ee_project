locals {
  generate_subnet_cidr_blocks = [
    for index in range(2) : cidrsubnet("10.0.0.0/16", 8, index)
  ]
}

locals {
  instances = {
    database_instance0 = {
      ami           = "ami-0440d3b780d96b29d"
      instance_type = "t2.micro"
      # key_name       = ""
    },
    database_instance1 = {
      ami           = "ami-0440d3b780d96b29d"
      instance_type = "t2.micro"
      # key_name       = ""
    }
  }

  #   instance_availability_zones = {
  #     database_instance1 = "us-east-1a"
  #     database_instance2 = "us-east-1b"
  #   }
}
