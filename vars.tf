variable "cluster-name" {
  default = "terraform-eks-demo"
  type    = "string"
}

variable "node_groups" {
  description = "Number of nodes groups to create in the cluster"
  default     = 3
}
