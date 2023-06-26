locals {
  marketplace_images = [
    {
      publisher = "canonical"
      offer     = "0001-com-ubuntu-minimal-lunar"
      plan      = "minimal-23_04-ARM"
    }
  ]
  common_tags = {
    environment = "dev"
    project     = "moodle-dev"
  }
}