provider "aws" {
	access_key=""
	secret_key=""
	region="us-east-1"
}

resource "aws_instance" "centos"{
	ami     =   "ami-02358d9f5245918a3"    #ami id is available in image
	count  =  1                                                   #number of instances to be created
	key_name=  "My_practice"		#key that we generated
	instance_type="t2.micro"		#instance type
	security_groups = [ "security_centos"]  #we can specify our own name for security group
	tags= {
		Name = "centos instance"
	}
}

resource "aws_security_group" "security_centos" {
	name= "security_centos"
	description = "security group for centos"
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
		Name = "security_centos"
	}
}