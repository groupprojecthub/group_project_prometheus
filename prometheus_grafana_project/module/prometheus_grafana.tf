resource "aws_instance" "web" {
  ami         = "${data.aws_ami.amazon.id}"
  subnet_id   = "${aws_subnet.public1.id}"
  iam_instance_profile = "${aws_iam_instance_profile.prometheus_profile.name}"
  key_name      = "${aws_key_pair.deployer.key_name}"
  vpc_security_group_ids = ["${aws_security_group.pro_graf_security.id}"]
  instance_type = "t3.small"
  provisioner   "remote-exec" {
    connection {
        host        = "${self.public_ip}"
        type        = "ssh"
        user        = "ec2-user"
        private_key = "${file("~/.ssh/id_rsa")}"
    }
    inline = [
      "sudo yum update -y",
      "sudo yum install wget -y",
      # Add users 
      "sudo useradd --no-create-home --shell /bin/false prometheus",
      "sudo mkdir /etc/prometheus",
      "sudo mkdir /var/lib/prometheus",
      "sudo chown prometheus:prometheus /etc/prometheus",
      "sudo chown prometheus:prometheus /var/lib/prometheus",
      # Download prometheus from a link 
      "curl -LO https://github.com/prometheus/prometheus/releases/download/v2.3.2/prometheus-2.3.2.linux-amd64.tar.gz",
      "tar -xvf prometheus-2.3.2.linux-amd64.tar.gz",
      "mv prometheus-2.3.2.linux-amd64 prometheus-files",
       # Copy binaries 
      "sudo cp prometheus-files/prometheus /usr/local/bin/",
      "sudo cp prometheus-files/promtool /usr/local/bin/",
      "sudo chown prometheus:prometheus /usr/local/bin/prometheus",
      "sudo chown prometheus:prometheus /usr/local/bin/promtool",
      # Move console files 
      "sudo cp -r prometheus-files/consoles /etc/prometheus",
      "sudo cp -r prometheus-files/console_libraries /etc/prometheus",
      "sudo chown -R prometheus:prometheus /etc/prometheus/consoles",
      "sudo chown -R prometheus:prometheus /etc/prometheus/console_libraries",
    ]
  },
  depends_on = ["aws_instance.web"]
  provisioner   "file" {
    connection {
        host        = "${aws_instance.web.public_ip}"
        type        = "ssh"
        user        = "ec2-user"
        private_key = "${file("~/.ssh/id_rsa")}"
    }
    source  =  "./module/configurations/prometheus_configs/prometheus.yml"
    destination = "/tmp/prometheus.yml"
  },
  depends_on = ["aws_instance.web"]
  provisioner   "file" {
    connection {
        host        = "${aws_instance.web.public_ip}"
        type        = "ssh"
        user        = "ec2-user"
        private_key = "${file("~/.ssh/id_rsa")}"
    }
    source  =  "./module/configurations/prometheus_configs/prometheus.service"
    destination = "/tmp/prometheus.service"
  },
  depends_on = ["aws_instance.web"]
  provisioner   "remote-exec" {
    connection {
        host        = "${aws_instance.web.public_ip}"
        type        = "ssh"
        user        = "ec2-user"
        private_key = "${file("~/.ssh/id_rsa")}"
    }
    inline = [
    # move files to their folders
      "sudo mv /tmp/prometheus.yml /etc/prometheus/prometheus.yml",
      "sudo mv /tmp/prometheus.service /etc/systemd/system/prometheus.service",
    # change ownership of prometheus.yml
      "sudo chown prometheus:prometheus /etc/prometheus/prometheus.yml",
      "sudo chown root:root /etc/systemd/system/prometheus.service",
    # start and enable services
      "sudo systemctl daemon-reload", 
      "sudo systemctl start prometheus",
      "sudo systemctl enable prometheus",
      "sudo systemctl status prometheus" 
    ]
  },
  depends_on = ["aws_instance.web"]
  provisioner   "file" {
    connection {
        host        = "${aws_instance.web.public_ip}"
        type        = "ssh"
        user        = "ec2-user"
        private_key = "${file("~/.ssh/id_rsa")}"
    }
    source  =  "./module/configurations/grafan_config/grafana.repo"
    destination = "/tmp/grafana.repo"
  },
  depends_on = ["aws_instance.web"]
  provisioner   "remote-exec" {
    connection {
        host        = "${aws_instance.web.public_ip}"
        type        = "ssh"
        user        = "ec2-user"
        private_key = "${file("~/.ssh/id_rsa")}"
    }
    inline = [
    # move grafana repo to the correct folder
     "sudo mv /tmp/grafana.repo /etc/yum.repos.d/grafana.repo",
     "sudo chown root:root /etc/yum.repos.d/grafana.repo",
     "yum-config-manager --enable grafana.repo",
     # install grafana
     "sudo yum install grafana fontconfig freetype* urw-fonts -y",
      # install start and enable grafana
     "sudo systemctl daemon-reload",
     "sudo systemctl start grafana-server",
     "sudo systemctl enable grafana-server.service",
     "sudo systemctl status grafana-server"
    ]
  },
  provisioner   "remote-exec" {
    connection {
        host        = "${self.public_ip}"
        type        = "ssh"
        user        = "ec2-user"
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
        host        = "${aws_instance.web.public_ip}"
        type        = "ssh"
        user        = "ec2-user"
        private_key = "${file("~/.ssh/id_rsa")}"
    }
    source  =  "./module/configurations/prometheus_configs/node_exporter.service"
    destination = "/tmp/node_exporter.service"
  },
  depends_on = ["aws_instance.web"]
  provisioner   "remote-exec" {
    connection {
        host        = "${aws_instance.web.public_ip}"
        type        = "ssh"
        user        = "ec2-user"
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
    Name = "Prometheus_Grafana Server"
  }

}