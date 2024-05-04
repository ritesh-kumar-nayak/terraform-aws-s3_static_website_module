# We are not assigning any values here as these values will be passed when the module is being called
# These will be mandatory variables.
variable "bucket_name" {
  type        = string
  description = "Name of the S3 bucket"
}

variable "tags" {
  type    = map(string)
  default = {}

}

variable "index_file" {
  type = string
  description = "html file name has to passed"
  
}