resource "aws_instance" "bastion" {
  ami                    = var.ami
  instance_type          = "t2.micro"
  subnet_id              = module.vpc.public_subnets[0]
  key_name               = aws_key_pair.my-key.key_name
  count                  = var.instance_count
  vpc_security_group_ids = [aws_security_group.baston-sg.id]

  tags = {
    Name    = "bastion"
    PROJECT = "bastion-app"
  }

  provisioner "file" {
    content     = templatefile("templates/db-dploy.tmpl", { rds-endpoint = aws_db_instance.rds-instance.address, dbuser = var.dbuser, dbpass = var.dbpass })
    destination = "/tmp/dbdeploy.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/dbdeploy.sh",
      "sudo /tmp/dbdeploy.sh"
    ]
  }

  connection {
    type        = "ssh"
    user        = var.username
    private_key = file(var.private_key)
    host        = self.public_ip
  }

  depends_on = [aws_db_instance.rds-instance]

}