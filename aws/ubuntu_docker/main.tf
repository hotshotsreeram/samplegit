provider "aws" {
	access_key=""
	secret_key=""
	region="us-east-1"
}

resource "aws_instance" "myFirstInstance"{
	ami     =   "ami-052efd3df9dad4825"    #ami id is available in image
	count  =  1                                                   #number of instances to be created
	key_name=  "My_practice"		#key that we generated
	instance_type="t2.micro"		#instance type
	security_groups = [ "security_ubuntu"]  #we can specify our own name for security group
	tags= {
		Name = "ubuntu instance"
	}
}

resource "aws_security_group" "security_ubuntu" {
	name= "security_ubuntu"
	description = "security group for ubuntu"
ingress {
	from_port = 8080		#8080 is for local host
	to_port	     = 8080
	protocol    ="tcp"                          #protocol that we want to use
	cidr_blocks=["0.0.0.0/0"]
}

ingress{
		from_port      =  22		#22 is for ssh port
		to_port           = 22
		protocol         ="tcp"
		cidr_blocks= ["0.0.0.0/0"]
	}
	
	egress {
		from_port     = 0
		to_port          = 65535
		protocol        ="tcp"
		cidr_blocks=["0.0.0.0/0"]
	}
	tags= {
		Name = "security_ubuntu"
	}
}
