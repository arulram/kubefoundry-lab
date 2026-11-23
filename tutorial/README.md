# KubeFoundry Lab — Tutorials

## Purpose

This directory contains the learning material, practical exercises, implementation notes, and validation results for the KubeFoundry Lab project.

The objective is to understand each technology before using it to build the Kubernetes infrastructure.

## Learning Roadmap

| No. | Tutorial | Technology | Status |
|---|---|---|---|
| 01 | Terraform Fundamentals | Terraform | Not started |
| 02 | Virtual Networking | KVM / QEMU / libvirt | Not started |
| 03 | VM Initialization | cloud-init | Not started |
| 04 | Kubernetes Deployment Automation | Ansible / Kubespray | Pending stable release |
| 05 | Kubernetes Fundamentals | Upstream Kubernetes / containerd | Not started |
| 06 | Kubernetes Networking | Cilium / eBPF / Gateway API | Not started |
| 07 | Persistent Storage | Local Path Provisioner | Not started |
| 08 | Operations and Maintenance | Terraform / Kubernetes / etcd | Not started |

## Tutorial Structure

Each technology has its own directory.

- `README.md`: Learning objectives, scope, progress, and completion criteria.
- `concepts.md`: Technical concepts and architecture explanations.
- `labs/`: Step-by-step practical exercises.
- `results/`: Command output, validation results, and observations.

## Learning Method

Each topic follows this process:

1. Understand the technology and its purpose.
2. Learn the important concepts.
3. Understand how it fits into KubeFoundry Lab.
4. Complete practical exercises.
5. Validate the results.
6. Document observations and troubleshooting.
7. Review the completion criteria.

## Documentation Rules

- Record actual commands and their results.
- Explain why a command or configuration is required.
- Document important design decisions.
- Include expected results and validation commands.
- Record errors and their resolutions.
- Do not document untested assumptions as verified results.
- Keep reusable infrastructure configuration in the appropriate project directory, not in the tutorial directory.

## Current Progress

**Current tutorial:** 01 — Terraform Fundamentals

**Current status:** Not started.
