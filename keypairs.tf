resource "aws_key_pair" "my-key" {
  key_name   = "my-key"
  public_key = file(var.public_key)
}