job "web_app" {
  datacenters = ["dc1"]
    

  group "counter" {
    count = 4
    network {
      mode = "bridge"

      port "http" {
  
        to     = 5000
      }
    }

    service {
      name = "webapp-proxy"
      port = "http"
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

    service {
      name = "webapp"
      port = "http"
      tags = ["urlprefix-/"]
      check {
        name     = "HTTP Health Check"
        type     = "http"
        port     = "http"
        path     = "/health"
        interval = "5s"
        timeout  = "2s"
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
