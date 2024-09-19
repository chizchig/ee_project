resource "aws_instance" "ec2" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  key_name                    = aws_key_pair.rr-tf.key_name
  tenancy                     = "default"
  subnet_id                   = aws_subnet.external_subnets[0].id
  vpc_security_group_ids      = [aws_security_group.aurora_sg.id]
  associate_public_ip_address = true

  root_block_device {
    volume_size           = "100"
    volume_type           = "gp2"
    encrypted             = true
    delete_on_termination = true
  }
    ebs_block_device {
    device_name           = "/dev/xvda"
    volume_size           = "1000"
    volume_type           = "gp2"
    encrypted             = true
    delete_on_termination = true
  }


  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = tls_private_key.rr.private_key_pem
    host        = self.public_ip
    timeout     = "5m"
  }

  provisioner "file" {
    source      = "${path.module}/jenkins.sh"
    destination = "/tmp/jenkins.sh"  # Adjust destination path as needed
  }

  provisioner "remote-exec" {
    inline = [
      "sudo chmod +x /tmp/jenkins.sh",
      "sudo /tmp/jenkins.sh 2>&1 | tee /tmp/jenkins_install.log || { cat /tmp/jenkins_install.log; exit 1; }",
    ]
  }
  depends_on = [aws_instance.ec2]

  tags = {
    Name = "Super_Instance"
  }
}

  


  


