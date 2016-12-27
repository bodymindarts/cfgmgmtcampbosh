job "cfgmgmcamp-demo" {
	datacenters = ["dc1"]

	# Configure the job to do rolling updates
	update {
		# Stagger updates every 10 seconds
		stagger = "10s"

		# Update a single task at a time
		max_parallel = 1
	}

	group "example" {
    count = 3

		task "server" {
			# Use Docker to run the task.
			driver = "docker"

			# Configure Docker driver with the image
			config {
				image = "bodymindarts/cfgmgmcamp-demo:latest"
        network_mode = "host"
			}

			service {
				name = "${TASKGROUP}-sinatra"
				port = "web"
				check {
					type = "http"
					path = "/_healthz"
					interval = "10s"
					timeout = "2s"
				}
			}

			resources {
				cpu = 500 # 500 Mhz
				memory = 256 # 256MB
				network {
					mbits = 10
					port "web" {
            static = "4567"
					}
				}
			}
		}
	}
}

