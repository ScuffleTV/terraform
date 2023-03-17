output "cluster_id" {
  value = linode_lke_cluster.cluster.id
}

output "kubeconfig" {
  value     = linode_lke_cluster.cluster.kubeconfig
  sensitive = true
}
