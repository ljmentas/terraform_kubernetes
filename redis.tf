resource "aws_security_group" "demo" {
  name_prefix = "${var.cluster-name}"
  vpc_id      = "${aws_vpc.demo.id}"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_elasticache_subnet_group" "demo" {
  name       = "testing-cache-subnet"
  subnet_ids = ["${aws_subnet.demo.*.id}"]
}

resource "aws_elasticache_replication_group" "demo" {
  replication_group_id          = "${var.cluster-name}"
  replication_group_description = "Redis cluster for Hashicorp ElastiCache example"

  node_type            = "cache.t2.micro"
  port                 = 6379
  #parameter_group_name = "demo.redis3.2.cluster.on"

  snapshot_retention_limit = 5
  snapshot_window          = "00:00-05:00"

  subnet_group_name          = "${aws_elasticache_subnet_group.demo.name}"
  automatic_failover_enabled = true

  cluster_mode {
    replicas_per_node_group = 1
    num_node_groups         = "${var.node_groups}"
  }
}

output "configuration_endpoint_address" {
  value = "${aws_elasticache_replication_group.demo.configuration_endpoint_address}"
}
