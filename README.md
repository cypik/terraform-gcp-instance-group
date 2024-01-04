# Terraform-gcp-instance-group
# Google Cloud Infrastructure Provisioning with Terraform
## Table of Contents

- [Introduction](#introduction)
- [Usage](#usage)
- [Module Inputs](#module-inputs)
- [Module Outputs](#module-outputs)
- [License](#license)

## Introduction
This project deploys a Google Cloud infrastructure using Terraform to create Instance-Group.
## Usage
To use this module, you should have Terraform installed and configured for GCP. This module provides the necessary Terraform configuration for creating GCP resources, and you can customize the inputs as needed. Below is an example of how to use this module:
### Examples

## Example: _Complete_

```hcl
module "mig" {
  source                       = "git::https://github.com/cypik/terraform-gcp-instance-group.git?ref=v1.0.0"
  hostname                     = "test"
  environment                  = "instance-group"
  min_replicas                 = var.min_replicas
  max_replicas                 = var.max_replicas
  region                       = var.region
  target_pools                 = var.target_pools
  distribution_policy_zones    = var.distribution_policy_zones
  update_policy                = var.update_policy
  named_ports                  = var.named_ports
  health_check                 = var.health_check
  autoscaling_enabled          = var.autoscaling_enabled
  autoscaling_cpu              = var.autoscaling_cpu
  autoscaling_metric           = var.autoscaling_metric
  autoscaling_lb               = var.autoscaling_lb
  autoscaling_scale_in_control = var.autoscaling_scale_in_control
  instance_template            = module.instance_template.self_link_unique
}
```

## Example: _Autoscaling_

```hcl
module "mig" {
  source              = "git::https://github.com/cypik/terraform-gcp-instance-group.git?ref=v1.0.0"
  region              = var.region
  hostname            = "test"
  environment         = "mig-autoscaling"
  autoscaling_enabled = var.autoscaling_enabled
  min_replicas        = var.min_replicas
  autoscaling_cpu     = var.autoscaling_cpu
  instance_template   = module.instance_template.self_link_unique
}
```
## Example: _Health-Check_

```hcl
module "mig" {
  source              = "git::https://github.com/cypik/terraform-gcp-instance-group.git?ref=v1.0.0"
  instance_template   = module.instance_template.self_link_unique
  region              = "asia-northeast1"
  autoscaling_enabled = true
  min_replicas        = 1
  hostname            = "test"
  environment         = "instance-group"

  autoscaling_cpu = [
    {
      target            = 0.4
      predictive_method = null
    },
  ]

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
```
## Example: _Simple_

```hcl
module "mig" {
  source              = "git::https://github.com/cypik/terraform-gcp-instance-group.git?ref=v1.0.0"
  region              = "asia-northeast1"
  target_size         = 1
  hostname            = "test"
  environment         = "mig-simple"
  instance_template   = module.instance_template.self_link_unique
  autoscaling_enabled = false

  autoscaling_cpu = [
    {
      target            = 0.7
      predictive_method = null
    },
  ]
}
```
This example demonstrates how to create various GCP resources using the provided modules. Adjust the input values to suit your specific requirements.

## Module Inputs

- `name`  : The name of the service account.
- `environment` : The environment type.
- `project_id` : The GCP project ID.
- `region`: A reference to the region where the regional forwarding rule resides.
- `min_replicas`: The minimum number of replicas that the autoscaling can scale down to.
- `autoscaling_cpu` : Defines the CPU utilization policy.
- `health_check` : The health check resource that signals autoscaling.
- `instance_template` : The full URL to an instance template from which all new instances of this version will be created.
- `named_ports` : The named port configuration.
- `target_pools` :  The full URL of all target pools to which new instances in the group are added.
- `autoscaling_lb` : Configuration parameters of autoscaling based on a load balancer.
- `min_replicas` : The minimum number of replicas that the autoscaling can scale down to.

## Module Outputs
Each module may have specific outputs. You can retrieve these outputs by referencing the module in your Terraform configuration.

- `id` :  An identifier for the resource with format.
- `self_link` : The URI of the created resource.
- `fingerprint` : The fingerprint of the instance group manager.
- `instance_group` :The full URL of the instance group created by the manager.
- `health_check_self_links` : The URL of the created resource.

## Examples
For detailed examples on how to use this module, please refer to the [Examples](https://github.com/cypik/terraform-gcp-instance-group/tree/master/example/mig) directory within this repository.

## Author
Your Name Replace **'[License Name]'** and **'[Your Name]'** with the appropriate license and your information. Feel free to expand this README with additional details or usage instructions as needed for your specific use case.

## License
This project is licensed under the MIT License - see the [LICENSE](https://github.com/cypik/terraform-gcp-instance-group/blob/master/LICENSE) file for details.
