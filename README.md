# memoraq-infra
This repo contains infrastructure for memoraq project.
The provisioning is implemented using Ansible for both provisioning the nodes on Hetzner cloud and bootstrapping the k8s cluster.

# Architecture
The cluster consists of:
- 1 control plane
- 1 worker node
