resource "aws_instance" "node" {
  depends_on = ["aws_instance.web"]
  ami           = "${data.aws_ami.centos7.id}"
  count = 3
  key_name      = "${aws_key_pair.deployer.key_name}"
  subnet_id = "${element(list("${aws_subnet.public2.id}", "${aws_subnet.public3.id}"), count.index)}"
  vpc_security_group_ids  = ["${aws_security_group.pro_node_security.id}"]
  instance_type = "t3.micro"
  provisioner   "remote-exec" {
    connection {
        host        = "${self.public_ip}"
        type        = "ssh"
        user        = "centos"
        private_key = "${file("~/.ssh/id_rsa")}"
    }
    inline = [
      "sudo yum update -y",
      "sudo yum install wget -y",
      # Add users 
      "sudo useradd --no-create-home --shell /bin/false prometheus",
      "sudo mkdir -p /etc/prometheus",
      "sudo mkdir -p /var/lib/prometheus",
      "sudo chown prometheus:prometheus /etc/prometheus",
      "sudo chown prometheus:prometheus /var/lib/prometheus",
      # Installs node exporter 
      "wget https://github.com/prometheus/node_exporter/releases/download/v0.18.1/node_exporter-0.18.1.linux-amd64.tar.gz",
      "tar xvfz node_exporter-0.18.1.linux-amd64.tar.gz",
    ]
  },
   depends_on = ["aws_instance.web"]
  provisioner   "file" {
    connection {
        host        = "${self.public_ip}"
        type        = "ssh"
        user        = "centos"
        private_key = "${file("~/.ssh/id_rsa")}"
    }
    source  =  "./module/configurations/prometheus_configs/node_exporter.service"
    destination = "/tmp/node_exporter.service"
  },
  depends_on = ["aws_instance.web"]
  provisioner   "remote-exec" {
    connection {
        host        = "${self.public_ip}"
        type        = "ssh"
        user        = "centos"
        private_key = "${file("~/.ssh/id_rsa")}"
    }
    inline = [
      "sudo mv node_exporter-0.18.1.linux-amd64 /etc/prometheus/node_exporter",
      # change ownership to prometheus
      "sudo chown -R prometheus:prometheus /etc/prometheus/node_exporter",
      # move service file to /etc folder and change ownership to root
      "sudo mv /tmp/node_exporter.service /etc/systemd/system/node_exporter.service",
      "sudo chown root:root /etc/systemd/system/node_exporter.service",
      # start and enable services
      "sudo systemctl daemon-reload", 
      "sudo systemctl start node_exporter",
      "sudo systemctl enable node_exporter",
      "sudo systemctl status node_exporter"
    ]
  }
 tags = {
    Name = "Node ${count.index + 1}"
  }

}
  