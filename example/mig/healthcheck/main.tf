
provider "google" {
  project = "opz0-xxxxx"
  region  = "asia-northeast1"
  zone    = "asia-northeast1-a"
}

######==============================================================================
###### vpc module call.
######==============================================================================

module "vpc" {
  source                                    = "git::git@github.com:opz0/terraform-gcp-vpc.git?ref=master"
  name                                      = "app"
  environment                               = "test"
  label_order                               = ["name", "environment"]
  project_id                                = "opz0-xxxxx"
  network_firewall_policy_enforcement_order = "AFTER_CLASSIC_FIREWALL"
}

######==============================================================================
###### subnet module call.
######==============================================================================
module "subnet" {
  source        = "git::git@github.com:opz0/terraform-gcp-subnet.git?ref=master"
  name          = "subnet"
  environment   = "test"
  gcp_region    = "asia-northeast1"
  network       = module.vpc.vpc_id
  project_id    = "opz0-xxxxx"
  source_ranges = ["10.10.0.0/16"]
}

######==============================================================================
##### firewall module call.
#####==============================================================================
module "firewall" {
  source        = "git::git@github.com:opz0/terraform-gcp-firewall.git?ref=master"
  name          = "app"
  environment   = "test"
  project_id    = "opz0-xxxxx"
  network       = module.vpc.vpc_id
  source_ranges = ["0.0.0.0/0"]

  allow = [
    { protocol = "tcp"
      ports    = ["22", "80"]
    }
  ]
}

#####==============================================================================
##### instance_template module call.
#####==============================================================================
module "instance_template" {
  source               = "git::git@github.com:opz0/terraform-gcp-template-instance.git?ref=master"
  instance_template    = true
  name                 = "template"
  environment          = "test"
  region               = "asia-northeast1"
  project_id           = "opz0-xxxxx"
  source_image         = "ubuntu-2204-jammy-v20230908"
  source_image_family  = "ubuntu-2204-lts"
  source_image_project = "ubuntu-os-cloud"
  subnetwork           = module.subnet.subnet_id
  service_account      = null
  metadata = {
    ssh-keys = <<EOF
        dev:ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCnRpyyDQHM2KPJ+j/FmgC27u/ohglMoWsJLsXSqfms5fWTW7YOm6WU89HlyWIJkQRPx4pIxpGFvDZwrFu0u3uTKLDtlfjs7KG5pH7q2RzIDq7spvrLJZ5VX2hJxveP9+L6ihYrPhcx5/0YqTB2cIkD1/R0qwnOWlNBUpDL9/GcLH54hjJLjPcMLfVfJwAa9IZ8jDGbMbFYLRazk78WCaYVe3BIBzFpyhwYcLL4YVolO6l450rsARENBq7ObXrP3AW1O/+I3fLaKGVZB7VXA7I0rj3MKU4qzD5L6tZLn5Lq3aUPcerhDgsiCY0X4nSJygxYX2Lxc3YKmJ/1PvrR9eJJ585qkRE25Z7URiICm45kFVfqf5Wn56PxzA+nOlPpV2QeNspI/6wih87hbyvUsE0y1fyds3kD9zVWQNzLd2BW4QZ/ZoaYRVY365S8LEqGxUVRbuyzni+51lj99yDW8X8W/zKU+lCBaggRjlkx4Q3NWS1gefgv3k/3mwt2y+PDQMU= suresh@suresh

      EOF
  }
  access_config = [{
    nat_ip       = ""
    network_tier = ""
  }, ]
}

#####==============================================================================
##### instance_group module call.
#####==============================================================================
module "mig" {
  source              = "../../../"
  project_id          = "opz0-xxxxx"
  instance_template   = module.instance_template.self_link_unique
  region              = "asia-northeast1"
  autoscaling_enabled = true
  min_replicas        = 2
  autoscaler_name     = "mig-as"
  hostname            = "instance-group"

  autoscaling_cpu = [
    {
      target            = 0.4
      predictive_method = null
    },
  ]

  health_check_name = "mig-https-hc"
  health_check = {
    type                = "https"
    initial_delay_sec   = 120
    check_interval_sec  = 5
    healthy_threshold   = 2
    timeout_sec         = 5
    unhealthy_threshold = 2
    response            = ""
    proxy_header        = "NONE"
    port                = 80
    request             = ""
    request_path        = "/"
    host                = "localhost"
    enable_logging      = false
  }
}