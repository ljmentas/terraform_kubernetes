
resource "aws_security_group" "sg_redis" {
  name        = "sg_redis"
  description = "Security group that is needed for the redis servers"
  vpc_id      = "${aws_vpc.demo.id}"

}

# Allow a security group to access the redis instance
resource "aws_security_group_rule" "sg_app_to_redis" {
  type                     = "ingress"
  security_group_id        = "${aws_security_group.sg_redis.id}"
  from_port                = "6379"
  to_port                  = "6379"
  protocol                 = "tcp"
  source_security_group_id = "${aws_security_group.demo-node.id}"
}


resource "aws_elasticache_subnet_group" "demo" {
  name       = "testing-cache-subnet"
  subnet_ids = ["${aws_subnet.demo.*.id}"]
}

resource "aws_elasticache_cluster" "demo" {
  cluster_id           = "cluster-demo"
  engine               = "redis"
  node_type            = "cache.t2.micro"
  num_cache_nodes      = 1
  parameter_group_name = "default.redis3.2"
  security_group_ids   = ["${aws_security_group.sg_redis.id}"]
  engine_version       = "3.2.6"
  port                 = 6379
  subnet_group_name    = "${aws_elasticache_subnet_group.demo.name}"
}

output "configuration_endpoint_address" {
  value = "${aws_elasticache_cluster.demo.cache_nodes.0.address}"
}


/*
We are commenting the cluster cause we wont be able to affort 18 nodes

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
*/
