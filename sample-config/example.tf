provider aws {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region = "${var.region}"
}

resource aws_instance example {
  ami = "${lookup(var.amis,var.region )}"
  instance_type = "${var.instance_type}"


//  provisioner "local-exec" {
//    command = "echo ${aws_instance.example.public_ip} > file.txt"
//  }

  tags{
    Name = "terraform-example"
  }
}

resource aws_eip ip {
  instance = "${aws_instance.example.id}"
  depends_on = ["aws_instance.example"]
}
resource "aws_elb" "example" {
  name = "example"
  availability_zones = ["us-east-1a","us-east-1b"]
  instances = ["${aws_instance.example.id}"]
  listener {
    lb_port = 80
    lb_protocol = "http"
    instance_port = "${var.instance_port}"
    instance_protocol = "http"
  }
}

output "ip" {
  value = "${aws_eip.ip.public_ip}"
}