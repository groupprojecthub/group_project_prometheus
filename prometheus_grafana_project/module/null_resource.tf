#   resource "null_resource" "mine" {
#     triggers = {
#         always_run = "${timestamp()}"
#     }    
#   depends_on = ["aws_instance.web"]
#   provisioner   "remote-exec" {
#     connection {
#         host        = "${aws_instance.web.public_ip}"
#         type        = "ssh"
#         user        = "ec2-user"
#         private_key = "${file("~/.ssh/id_rsa")}"
#     }
#     inline = [
#      "sudo yum update -y "
#     ]
#   }
# }

