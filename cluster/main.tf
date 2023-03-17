resource "linode_lke_cluster" "cluster" {
  label       = var.label
  k8s_version = var.k8s_version
  region      = var.region
  tags        = var.tags

  control_plane {
    high_availability = var.control_plane_high_availability
  }

  # Notice how the first pools will have an autoscaler.
  # we need to ignore the count field for these pools
  # so that the autoscaler can create nodes.
  dynamic "pool" {
    for_each = var.pools
    content {
      count = pool.value.count
      type  = pool.value.type
      autoscaler {
        min = pool.value.autoscaler != null ? pool.value.autoscaler.min : pool.value.count
        max = pool.value.autoscaler != null ? pool.value.autoscaler.max : pool.value.count
      }
    }
  }
}
