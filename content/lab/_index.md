---
title: 'The lab'
linkTitle: 'Lab'
description: 'What theTinyLab runs: the services, the hardware they run on, and the architecture that ties them together.'
---

The whole design hangs on one idea: **a zone per trust domain**. Everything
the lab runs lives where it can only talk to what it must. This page is the
inventory — what is live today, what is being built, and what is queued.

## What it hosts

### Deployed

| Service | Software |
|---------|----------|
| Internal certificate authority | step-ca + theTinyCA web UI |
| Internal DNS | Technitium pair, custom blockers + DoH forwarders |
| External DNS | Cloudflare |
| Backups | Proxmox Backup Server, 3-2-1 strategy — offsite leg pending |
| Patch & compliance monitoring | PatchMon |
| Inference engine | Ollama |

### In flight

| Service | Software |
|---------|----------|
| Git + CI/CD | self-hosted Gitea build with native runners |
| Identity provider | Pocket ID, passkey-first OIDC |

### Planned

| Service | Software |
|---------|----------|
| Edge firewall pair | OPNSense in HA, WAN transit from the home ISP |
| Zero-trust remote access | self-hosted NetBird control plane + client |
| Public reverse proxy + WAF | hardened Caddy + Coraza/OWASP CRS + CrowdSec |
| Internal reverse proxy | hardened Caddy |
| Kubernetes platform | Talos Linux + custom Headlamp |
| File sync / drive | OpenCloud or similar |
| Monitoring / SIEM | Wazuh + CrowdSec + LGTM stack |
| File converter | custom Transmute build |
| Network boot | iVentoy iPXE server |
| Email archiving | OpenArchiver / Bichon |
| Hosted office | Collabora |
| Device management | FleetDM |
| Object storage | Garage S3 |

## The metal

| Role | Machines | CPU | Memory | Storage | Status |
|------|----------|-----|--------|---------|--------|
| Virtualization (Proxmox cluster) | 3 × Dell OptiPlex Micro 7040 | i5-6500T | 16 GB DDR4 | 256 GB NVMe | live |
| Kubernetes nodes | 3 × Intel NUC 7i7BNK | i7-7567U | 16 GB DDR4 | 256 GB NVMe | in flight |
| AI node | 1 × Mac Mini (M1) | M1 | 16 GB unified | 256 GB NVMe | live |
| Lab workstation | 1 × Dell XPS 9350, custom Arch build ("theTinyOS") | i7-1165G7 | 16 GB DDR4 | 500 GB NVMe | live |

## Architecture

The lab is segmented by trust, not by convenience. A hardened border pair
separates the household network from everything below it, and inside the lab
each zone exists because it is allowed to talk to different things than its
neighbours. Here's the shape of it, with the numbers deliberately left out.

```
 family internet
        │
  ┌─────▼─────┐
  │   home    │      the production network the lab nests under —
  │  network  │      it plays the part of the ISP and nothing more
  └─────┬─────┘
        │  a single quiet uplink
  ┌─────▼──────────────────────────┐
  │  border · firewall pair (HA)   │   two firewalls, one virtual address,
  └─────┬──────────────────────────┘   failover between them
        │
  ┌─────┴─────────────────────────────────────────────┐
  │                     the lab                       │
  │                                                   │
  │  scratch ─ experiments, throwaway builds          │
  │  infra ─── DNS, certificates, identity, backups   │
  │  k8s ───── Kubernetes platform & apps             │
  │  svc ───── shared services                        │
  │  edge ──── the only zone that faces the internet  │
  └───────────────────────────────────────────────────┘
```

| Zone | Role | Status |
|------|------|--------|
| **edge** | Public publishing. Strict ingress; nothing else may be reached from outside | planned |
| **svc** | Shared services for the household-lab boundary | planned |
| **k8s** | Talos Kubernetes: apps and platform workloads | hardware in flight |
| **infra** | DNS, certificates, identity, backups, monitoring | live |
| **scratch** | General lab workloads, safe to break | planned |

### Three doors

Everything about access control reduces to which door you arrive through:

1. **Public.** From the internet you will be able to reach exactly one thing:
   the edge reverse proxy — behind a web application firewall, certificates
   issued through a DNS-based challenge so no administrative port is ever
   opened. Building now.
2. **Remote.** Away from home, a zero-trust overlay will bring the lab to the
   laptop — scoped per zone, switched on automatically only when the laptop
   leaves home. Planned: self-hosted NetBird.
3. **Trusted.** On the home network, management traffic never crosses the
   firewalls at all: direct layer-2 access survives even a total border
   outage, which is what makes it the break-glass path.

## Where it stands today

Certificates, DNS, backups, patch monitoring and local inference are live.
The git forge and identity provider are being deployed next, then the
high-availability firewall pair. Kubernetes hardware is racked and waiting
for its platform. The lab documents the build as it happens — including the
parts that don't go to plan — over at the [agent
journal](https://agent.thetinylab.cloud).
