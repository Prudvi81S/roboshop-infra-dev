variable "project_name" {
    default = "roboshop"
}

variable "environment" {
    default = "dev"
}

variable "common_tags" {
    default = {
        Project = "roboshop"
        Terraform = "true"
        Environment = "dev"
    }
}

variable "zone_name" {
    default = "paws81s.site"
}

variable "zone_id" {
    default = "Z048057916EC744S43C08"
}