job "web_app" {
  datacenters = ["dc1"]
  

//   group "redis_db" {
//     network {
//       mode = "bridge"
//     }
//     service {
//       name = "redis"
//       port = "6379"

//       connect {
//         sidecar_service {}
//       }
//     }
//     task "redis" {           # The task stanza specifices a task (unit of work) within a group
//       driver = "docker"      # This task uses Docker, other examples: exec, LXC, QEMU
//       config {
//         image = "redis:3.2"  # Docker image to download (uses public hub by default)
//       }
//     } 
//   }
    

  group "counter" {
    network {
      mode = "bridge"

      port "http" {
        static = 5000
        to     = 5000
      }
    }

    service {
      name = "webapp"
      port = "5000"
      connect {
        sidecar_service {
            proxy {
                upstreams {
                    destination_name = "redis"
                    local_bind_port = 6479
                }
            }
        }
      }
    }
    

    task "app" {
      driver = "raw_exec"
      
      config {
        command = "/bin/sh"
        args = ["/vagrant/scripts/runapp.sh"]
      }

      dispatch_payload {
       file = "/vagrant/scripts/runapp.sh"
     }

    }
  }
}
