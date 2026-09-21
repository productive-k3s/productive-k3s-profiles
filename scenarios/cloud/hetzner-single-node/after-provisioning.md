# After Provisioning

Run:

```bash
make -C scenarios/cloud/hetzner-single-node status
```

Read the public IP and hostnames:

```bash
jq . scenarios/cloud/hetzner-single-node/generated/cluster.json
```

Connect to the VM:

```bash
ssh -i /absolute/path/to/id_ed25519 root@SERVER_IP
```

On the VM:

```bash
k3s kubectl get nodes -o wide
k3s kubectl get pods -A
k3s kubectl get ingress -A
k3s kubectl get storageclass
```

The expected topology is one `Ready` x86_64 node.

For browser validation, point the configured Rancher and registry hostnames to
the VM public IP from `generated/cluster.json`.
