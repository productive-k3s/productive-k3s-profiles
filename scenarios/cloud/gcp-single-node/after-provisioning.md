# After Provisioning

Run:

```bash
make -C scenarios/cloud/gcp-single-node status
```

Read the public IP and hostnames:

```bash
jq . scenarios/cloud/gcp-single-node/generated/cluster.json
```

Connect to the VM:

```bash
ssh -i /absolute/path/to/id_ed25519 ubuntu@SERVER_IP
```

On the VM:

```bash
sudo k3s kubectl get nodes -o wide
sudo k3s kubectl get pods -A
sudo k3s kubectl get ingress -A
sudo k3s kubectl get storageclass
```

The expected topology is one `Ready` x86_64 node.

For browser validation, point the configured Rancher and registry hostnames to
the VM public IP from `generated/cluster.json`.
