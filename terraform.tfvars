aws_region  = "us-east-2"
aws_profile = "bgsilvait"
vpc_cidr    = "10.0.0.0/16"
cidrs       = {
    subpbc1 = "10.0.20.0/24"
    subpbc2 = "10.0.40.0/24"
    subpvt1 = "10.0.60.0/24"
    subpvt2 = "10.0.80.0/24"
    }
dom_name = "bgsilvait"
app_count ="2"
fargate_cpu= "256"
fargate_memory ="512"
app_image ="bgsilvait/nginx:latest"
app_port ="80"