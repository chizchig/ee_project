region                      = "us-east-1"
internal_subnet_cidr_blocks = ["10.0.3.0/24", "10.0.4.0/24"]
external_subnet_cidr_blocks = ["10.0.1.0/24", "10.0.2.0/24"]
vpc_cidr_block              = "10.0.0.0/16"


tags = {
  env = "dev"
}


ingress_rules = [
  {
    from_port   = 6379
    to_port     = 6379
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16", "192.168.0.0/24"]
  },
  {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  },
  {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  },
   {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  },
   {
    from_port   = 9000
    to_port     = 9000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
]

egress_rules = [
  {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
]

security_group_name = "aurora-sg"

ami_id        = "ami-0a5c3558529277641"
instance_type = "t2.medium"
passwd        = "Tantalizer45"

