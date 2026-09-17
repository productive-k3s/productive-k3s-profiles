locals {
  server_name   = "${var.cluster_name}-server"
  agent_names   = [for index in range(var.agent_count) : "${var.cluster_name}-agent-${index + 1}"]
  rancher_host  = "rancher.${var.base_domain}"
  registry_host = "registry.${var.base_domain}"

  server_nodes = {
    (local.server_name) = {
      name       = local.server_name
      image      = var.image
      cpus       = tostring(var.server_cpus)
      memory     = var.server_memory
      disk       = var.server_disk
      cloud_init = "${path.module}/cloud-init/server.yaml"
    }
  }

  agent_nodes = {
    for index, agent_name in local.agent_names : agent_name => {
      name       = agent_name
      image      = var.image
      cpus       = tostring(var.agent_cpus)
      memory     = var.agent_memory
      disk       = var.agent_disk
      cloud_init = "${path.module}/cloud-init/agent-${index + 1}.yaml"
    }
  }

  nodes = merge(local.server_nodes, local.agent_nodes)
}

resource "null_resource" "multipass_instance" {
  for_each = local.nodes

  triggers = {
    name       = each.value.name
    image      = each.value.image
    cpus       = each.value.cpus
    memory     = each.value.memory
    disk       = each.value.disk
    cloud_init = each.value.cloud_init
  }

  provisioner "local-exec" {
    command = "${path.module}/../scripts/tofu-ensure-instance.sh apply '${self.triggers.name}' '${self.triggers.image}' '${self.triggers.cpus}' '${self.triggers.memory}' '${self.triggers.disk}' '${self.triggers.cloud_init}'"
  }

  provisioner "local-exec" {
    when    = destroy
    command = "${path.module}/../scripts/tofu-ensure-instance.sh destroy '${self.triggers.name}'"
  }
}

resource "null_resource" "generated_artifacts" {
  depends_on = [null_resource.multipass_instance]

  triggers = {
    cluster_name  = var.cluster_name
    base_domain   = var.base_domain
    remote_dir    = var.remote_dir
    server_name   = local.server_name
    agent_names   = join(",", local.agent_names)
    rancher_host  = local.rancher_host
    registry_host = local.registry_host
  }

  provisioner "local-exec" {
    command = "${path.module}/../scripts/refresh-generated-artifacts.sh --cluster-name '${self.triggers.cluster_name}' --base-domain '${self.triggers.base_domain}' --remote-dir '${self.triggers.remote_dir}' --server-name '${self.triggers.server_name}' --agent-names '${self.triggers.agent_names}' --rancher-host '${self.triggers.rancher_host}' --registry-host '${self.triggers.registry_host}'"
  }
}
