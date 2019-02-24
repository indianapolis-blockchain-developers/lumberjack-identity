variable "VPCCIDR" {
    type                 = "string"
    description          = "Must be a valid IP CIDR Range of the form x.x.x.x/x"
    default              = "10.0.0.0/16"
}

variable "PrivateSubnetCIDR" {
    type                 = "string"
    description          = "Must be a valid IP CIDR Range of the form x.x.x.x/x"
    default              = "10.0.0.0/19"
}

variable "PublicSubnetCIDR" {
    type                 = "string"
    description          = "Must be a valid IP CIDR Range of the form x.x.x.x/x"
    default              = "10.0.128.0/20"
}
variable "aws_region" {
    description          = "The AWS Region you wish to run (e.g. us-east-1)"
    default              = "us-east-1"
}

variable "InstanceType" {
    type                 = "string"
    description          = "The type of EC2 Instances to run (e.g. t2.micro)"
    default              = "t2.micro"
}       
       
variable "amis"        {
    type                 = "map"
    default              = {
        "us-east-1"      = "ami-02eac2c0129f6376b"
        "us-east-2"      = "ami-0f2b4fc905b0bd1f1"
        "us-west-1"      = "ami-074e2d6769f445be5"
        "us-west-2"      = "ami-01ed306a12b7d1c96"
        "ca-central-1"   = "ami-033e6106180a626d0"
        "eu-central-1"   = "ami-04cf43aca3e6f3de3"
        "eu-west-1"      = "ami-0ff760d16d9497662"
        "eu-west-2"      = "ami-0eab3a90fc693af19"
        "eu-west-3"      = "ami-0e1ab783dc9489f34"
        "ap-southeast-1" = "ami-0b4dd9d65556cac22"
        "ap-southeast-2" = "ami-08bd00d7713a39e7d"
        "ap-northeast-2" = "ami-06cf2a72dadf92410"
        "ap-northeast-1" = "ami-045f38c93733dd48d"
        "ap-south-1"     = "ami-02e60be79e78fef21"
        "sa-east-1"      = "ami-0b8d86d4bf91850af"

    }
}

