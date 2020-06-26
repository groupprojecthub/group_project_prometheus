terraform {
  backend "s3" {
    bucket = "terraform-state-april-class-kellysalrin"
    key    = "jenkins/us-east-1/tools/prometheus_grafana/prometheus_grafana.tfstate"
    region = "us-east-1"
  }
}
