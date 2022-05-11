## Copyright (c) 2020, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

data "template_file" "redis_bootstrap_replica_template" {
  template = file("./scripts/redis_bootstrap_replica.sh")

  vars = {
    redis_version      = var.redis_version
    redis_port1        = var.redis_port1
    redis_port2        = var.redis_port2
    redis_password     = random_string.redis_password.result
    master1_private_ip = data.oci_core_vnic.redis1_vnic.private_ip_address
    slave1_private_ip = data.oci_core_vnic.redis2_vnic.private_ip_address
  }
}

resource "null_resource" "redis2_bootstrap" {
  depends_on = [oci_core_instance.redis1,oci_core_instance.redis2]

  provisioner "file" {
    connection {
      type        = "ssh"
      user        = "opc"
      host        = data.oci_core_vnic.redis2_vnic.public_ip_address
      private_key = tls_private_key.public_private_key_pair.private_key_pem
      script_path = "/home/opc/myssh.sh"
      agent       = false
      timeout     = "10m"
    }

    content     = data.template_file.redis_bootstrap_replica_template.rendered
    destination = "~/redis_bootstrap_replica.sh"
  }
  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = "opc"
      host        = data.oci_core_vnic.redis2_vnic.public_ip_address
      private_key = tls_private_key.public_private_key_pair.private_key_pem
      script_path = "/home/opc/myssh.sh"
      agent       = false
      timeout     = "10m"
    }
    inline = [
      "chmod +x ~/redis_bootstrap_replica.sh",
      "sudo ~/redis_bootstrap_replica.sh",
    ]
  }
}

