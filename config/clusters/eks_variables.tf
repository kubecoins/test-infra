variable "eks_default_worker_group_name" {
  default     = "default-worker-group"
  description = "The name of the default EKS worker group"
}

variable "eks_default_worker_group_instance_type" {
  default     = "m5.large"
  description = "The instance type of the default EKS worker group"
}

variable "eks_default_worker_group_asg_min_capacity" {
  default     = 3
  description = "The Autoscaling Group size of the default EKS worker group"
}

variable "eks_default_worker_group_asg_desired_capacity" {
  default     = 4
  description = "The Autoscaling Group size of the default EKS worker group"
}

variable "eks_default_worker_group_asg_max_capacity" {
  default     = 10
  description = "The Autoscaling Group size of the default EKS worker group"
}

variable "eks_default_worker_group_additional_userdata" {
  default     = 1
  description = "Uerdata to append to the default userdata of the default EKS worker group"
}

variable "eks_groups" {
  description = "Additional IAM users to add to the aws-auth configmap."
  type = list(object({
    rolearn  = string
    username = string
    groups   = list(string)
  }))
}
