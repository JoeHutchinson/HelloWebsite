locals {
  name = "ex-${basename(path.cwd)}"
  container_port = 3000
  container_image = "nmatsui/hello-world-api:0.1.1"
  container_name = "hello-world-web-server"
}