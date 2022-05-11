## Copyright (c) 2020, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

resource "null_resource" "redis_cluster_startup" {
  depends_on = [null_resource.redis1_bootstrap, null_resource.redis2_bootstrap]

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = "opc"
      host        = data.oci_core_vnic.redis1_vnic.public_ip_address
      private_key = tls_private_key.public_private_key_pair.private_key_pem
      script_path = "/home/opc/myssh.sh"
      agent       = false
      timeout     = "10m"
    }
    inline = [
      "echo '=== Starting REDIS on redis1 node... ==='",
      "sudo -u root nohup /usr/local/bin/redis-server /etc/redis.conf > /tmp/redis-server.log &",
      "ps -ef | grep redis",
      "sleep 10",
      "sudo cat /tmp/redis-server.log",
      "echo '=== Started REDIS on redis1 node... ==='"
    ]
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
      "echo '=== Starting REDIS on redis2 node... ==='",
      "sudo -u root nohup /usr/local/bin/redis-server /etc/redis.conf > /tmp/redis-server.log &",
      "ps -ef | grep redis",
      "sleep 10",
      "sudo -u root cat /tmp/redis-server.log",
      "echo '=== Started REDIS on redis2 node... ==='"
    ]
  }

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = "opc"
      host        = data.oci_core_vnic.redis1_vnic.public_ip_address
      private_key = tls_private_key.public_private_key_pair.private_key_pem
      script_path = "/home/opc/myssh.sh"
      agent       = false
      timeout     = "10m"
    }
    inline = [
      "echo 'cluster info' | /usr/local/bin/redis-cli -c -a ${random_string.redis_password.result}",
      "echo 'cluster nodes' | /usr/local/bin/redis-cli -c -a ${random_string.redis_password.result}"
    ]
  }

}

