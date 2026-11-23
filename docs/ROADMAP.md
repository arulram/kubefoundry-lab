# KubeFoundry Lab

## Infrastructure and Kubernetes Learning Roadmap

**Project name:** KubeFoundry Lab\
**Document purpose:** Learning roadmap, architecture overview, and
phased implementation plan\
**Status:** Planning\
**Last updated:** 2026-11-22

------------------------------------------------------------------------

## 1. Project Purpose

KubeFoundry Lab is a hands-on infrastructure and Kubernetes learning
project. The objective is to build a reproducible, maintainable
Kubernetes environment on a local Ubuntu desktop while learning each
technology in a deliberate sequence.

This is not intended to be a one-step Kubernetes installation. Each
phase introduces a technology or capability, explains its role in the
architecture, implements a small working result, and validates that
result before moving forward.

The project will use upstream Kubernetes rather than a Kubernetes
distribution. Kubespray will be evaluated and selected when a suitable
stable release is available.

### Learning objectives

-   Understand KVM, QEMU, and libvirt virtualization.
-   Design and manage virtual networking and storage.
-   Learn Terraform for declarative infrastructure provisioning.
-   Learn cloud-init for first-boot VM initialization.
-   Build a reusable infrastructure-as-code repository.
-   Learn Ansible and Kubespray for Kubernetes deployment and lifecycle
    management.
-   Learn containerd and upstream Kubernetes architecture.
-   Learn Cilium, eBPF, kube-proxy replacement, LoadBalancer IPAM, L2
    announcements, and Gateway API.
-   Understand Kubernetes persistent storage and its failure/recovery
    boundaries.
-   Develop repeatable build, validation, backup, and recovery
    procedures.

------------------------------------------------------------------------

## 2. Overall Architecture

### 2.1 Host environment

The Ubuntu desktop is the virtualization host. KVM/QEMU run the virtual
machines, while libvirt manages VM domains, virtual networks, and
storage pools.

Terraform manages the libvirt infrastructure. cloud-init provides each
VM's initial identity, access, and network configuration.

Ansible/Kubespray will later prepare the guest operating systems and
deploy upstream Kubernetes.

### 2.2 Technology stack

  -----------------------------------------------------------------------
  Layer                   Technology              Responsibility
  ----------------------- ----------------------- -----------------------
  Physical host           Ubuntu 24.04 desktop    Runs the lab

  Virtualization          KVM/QEMU                Runs guest virtual
                                                  machines

  Virtualization          libvirt                 Manages VM domains,
  management                                      networks, and storage

  Infrastructure as code  Terraform               Creates and manages
                                                  libvirt resources

  VM initialization       cloud-init              Configures guests on
                                                  first boot

  Configuration           Ansible                 Automates guest and
  management                                      cluster configuration

  Kubernetes deployment   Kubespray               Deploys and manages
                                                  upstream Kubernetes

  Container runtime       containerd              Runs Kubernetes
                                                  containers

  Container networking    Cilium                  CNI, eBPF networking,
                                                  and policy capabilities

  LoadBalancer services   Cilium LB-IPAM and L2   Allocates and announces
                          announcements           service IP addresses

  Application routing     Gateway API through     Routes application
                          Cilium                  traffic

  Persistent storage      Local Path Provisioner  Provides node-local
                                                  persistent volumes

  Source control and      Git                     Tracks code,
  documentation                                   configuration, and
                                                  build instructions
  -----------------------------------------------------------------------

### 2.3 Target virtual machine layout

The lab will contain one control-plane/etcd VM and three worker VMs.

  VM          Kubernetes role             vCPU         RAM   Virtual disk
  ----------- ------------------------ ------- ----------- --------------
  cp1         Control plane and etcd         2        4 GB          20 GB
  w1          Worker                         1        4 GB          15 GB
  w2          Worker                         1        4 GB          15 GB
  w3          Worker                         1        4 GB          15 GB
  **Total**                              **5**   **16 GB**      **65 GB**

The virtual disks will be thin-provisioned. Virtual capacity is not the
same as host disk consumption. Actual host usage must be monitored, and
rebuilds or snapshots must account for the host's available disk space.

The single control-plane/etcd design is intentional for this learning
lab. It is not highly available. If `cp1` fails, the Kubernetes API and
the single-member etcd service will be unavailable.

### 2.4 Proposed virtual network

The initial network design is:

  Component                  Address
  -------------------------- -----------------------------------
  Libvirt network            `192.168.100.0/24`
  Gateway                    `192.168.100.1`
  cp1                        `192.168.100.10`
  w1                         `192.168.100.11`
  w2                         `192.168.100.12`
  w3                         `192.168.100.13`
  Cilium LoadBalancer pool   `192.168.100.200-192.168.100.220`
  Kubernetes Pod CIDR        `10.233.64.0/18`
  Kubernetes Service CIDR    `10.233.0.0/18`

Planned network characteristics:

-   Static guest IP addresses will be configured through cloud-init.
-   DHCP will be disabled for the dedicated lab network after the
    static-address design is validated.
-   The Ubuntu desktop is the intended client for LoadBalancer IPs and
    exposed services.
-   The lab network is intended to be isolated from the physical LAN.
-   Host, VPN, Docker, and other existing routes must be inspected
    before finalizing the proposed subnets.
-   Cilium L2 announcements must be validated from the desktop across
    the libvirt network. Physical LAN access is not part of the initial
    design.

These addresses are proposed design values, not yet implemented
configuration.

### 2.5 Component ownership boundaries

Each tool should have a clear responsibility. Avoid managing the same
resource through multiple tools.

  -----------------------------------------------------------------------
  Component/resource                  Owner
  ----------------------------------- -----------------------------------
  Libvirt network                     Terraform

  Libvirt storage pool                Terraform

  Base cloud image reference/download Terraform-managed workflow

  VM disks and domains                Terraform

  Cloud-init configuration and seed   Terraform and cloud-init
  disks                               

  Initial guest user, SSH access,     cloud-init
  hostname, and static network        
  configuration                       

  Guest OS preparation for Kubernetes Kubespray/Ansible

  containerd and Kubernetes           Kubespray/Ansible
  installation                        

  Kubernetes cluster configuration    Kubespray/Ansible
  and supported addons                

  Cilium LoadBalancer IP pool         Kubernetes manifests or
                                      Helm-managed configuration

  Cilium L2 announcement policy       Kubernetes manifests or
                                      Helm-managed configuration

  Gateway API and HTTPRoute resources Kubernetes manifests

  Application workloads               Kubernetes manifests

  Local Path Provisioner              Kubespray addon, subject to release
                                      compatibility verification
  -----------------------------------------------------------------------

Terraform will not initially use the Kubernetes provider to manage
Kubernetes resources. Terraform provisioners will not be used to install
Kubernetes. These boundaries keep infrastructure provisioning separate
from cluster lifecycle management.

------------------------------------------------------------------------

## 3. Phased Learning and Implementation Roadmap

Each phase follows the same sequence:

1.  Learn the concepts.
2.  Review the architecture and design.
3.  Agree on the configuration.
4.  Implement a small, controlled change.
5.  Validate using actual command output.
6.  Troubleshoot and document the result.
7.  Confirm the phase is complete before proceeding.

### Phase 0 --- Architecture and host preparation

**Goal:** Understand the architecture and verify that the desktop can
support the proposed lab.

**Topics to learn:** - KVM, QEMU, and libvirt responsibilities. - How a
VM is created and started. - Terraform's declarative workflow. -
cloud-init's first-boot lifecycle. - Ansible's configuration-management
model. - Git-based infrastructure project organization.

**Activities:** 1. Review the complete target architecture. 2. Inspect
host CPU, memory, disk, and virtualization support. 3. Inspect installed
virtualization and development tools. 4. Identify existing network
interfaces and routes. 5. Review available host disk space and the
implications of thin provisioning.

**Completion criteria:** - The technology roles and their relationships
are understood. - Host capacity is checked. - No unresolved host-level
constraint prevents the design from proceeding.

**Scope boundary:** No Kubernetes installation and no production-like VM
build in this phase.

### Phase 1 --- Learn and configure libvirt networking

**Goal:** Understand virtual networking and establish the dedicated lab
network.

**Topics to learn:** - Linux bridges. - NAT networking. - libvirt
virtual networks. - DHCP and static addressing. - Routing, gateways, and
DNS. - Host-to-guest connectivity. - Network isolation and subnet
overlap.

**Activities:** 1. Inspect the existing host network interfaces and
routing table. 2. Inspect the default libvirt network, if present. 3.
Check the proposed lab subnet against host, VPN, Docker, and other
routes. 4. Finalize the lab network design. 5. Create the dedicated
libvirt network. 6. Validate the network gateway and host connectivity.

**Completion criteria:** - The lab subnet is confirmed not to overlap
with relevant existing routes. - The dedicated libvirt network is
active. - The desktop can reach a test guest on the network.

### Phase 2 --- Learn libvirt storage and VM fundamentals

**Goal:** Understand how libvirt stores and runs virtual machines.

**Topics to learn:** - Libvirt storage pools and volumes. - QCOW2 and
raw disk formats. - Backing files and copy-on-write clones. - Thin
provisioning. - VM CPU and memory allocation. - VM lifecycle
operations. - QEMU guest agent.

**Activities:** 1. Inspect libvirt storage pools. 2. Learn the
difference between QCOW2 and raw images. 3. Understand base images and
copy-on-write disks. 4. Create or configure a dedicated storage pool. 5.
Obtain an Ubuntu 24.04 cloud image. 6. Create one temporary test VM. 7.
Connect to the VM and inspect its resources. 8. Shut down the VM and
inspect its storage.

**Completion criteria:** - A test VM can be created, started, accessed,
and shut down. - The storage layout and disk allocation behavior are
understood.

**Scope boundary:** Use one temporary test VM before building the
four-node environment.

### Phase 3 --- Learn cloud-init

**Goal:** Automate the initial configuration of a new Ubuntu VM.

**Topics to learn:** - cloud-init and its datasource. - `user-data`. -
`meta-data`. - `network-config`. - SSH public-key injection. - User and
hostname configuration. - Static IP configuration. - First-boot
execution and cloud-init stages. - cloud-init logs and troubleshooting.

**Activities:** 1. Create a cloud-init configuration for the test VM. 2.
Configure its hostname. 3. Configure the intended SSH user and public
key. 4. Configure its static IP address. 5. Install and enable QEMU
guest agent. 6. Boot the VM and inspect cloud-init status and logs. 7.
Recreate the VM and verify repeatability.

**Completion criteria:** - The VM boots with the expected hostname,
user, SSH access, and IP address. - Initial configuration is repeatable
without manual guest setup.

### Phase 4 --- Learn Terraform with libvirt

**Goal:** Replace manual infrastructure creation with declarative
Terraform configuration.

**Topics to learn:** - Terraform providers and resources. - Variables,
outputs, and locals. - Expressions and `for_each`. - Resource
dependencies. - Terraform state. - `init`, `validate`, `plan`, `apply`,
and `destroy`. - Idempotency and drift detection. - Provider
permissions, libvirt URI, and AppArmor considerations.

**Activities:** 1. Configure the libvirt provider. 2. Validate access to
the intended libvirt connection. 3. Manage the lab network through
Terraform. 4. Manage the storage pool through Terraform. 5. Reference or
download the Ubuntu base image. 6. Create a VM disk and cloud-init seed
disk. 7. Create one VM through Terraform. 8. Export useful VM
information through Terraform outputs. 9. Expand the configuration to
all four VMs. 10. Validate plan, apply, refresh, and controlled
destroy/recreate behavior.

**Completion criteria:** - Terraform manages the agreed libvirt
infrastructure. - Repeated plans do not show unexplained changes. -
State handling and provider permissions are understood. - Sensitive
state and credentials are protected from Git.

### Phase 5 --- Create the reusable project repository

**Goal:** Organize the project for repeatable builds and future
maintenance.

**Topics to learn:** - Infrastructure-as-code repository organization. -
Separation of configuration and secrets. - Version pinning and
dependency documentation. - `.gitignore` design. - Terraform state
protection. - Documentation and validation conventions.

**Proposed repository structure:**

``` text
kubefoundry-lab/
├── terraform/
│   ├── providers.tf
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   └── cloud-init/
│
├── kubespray/
│   └── inventory/
│
├── cilium/
│   ├── lb-ipam/
│   ├── l2-announcements/
│   └── gateway-api/
│
├── storage/
├── scripts/
├── docs/
│   └── BUILD_FROM_SCRATCH.md
├── tmp/
└── .gitignore
```

The repository structure may evolve as the implementation becomes
clearer.

**Activities:** 1. Create the Git repository. 2. Establish directory and
naming conventions. 3. Add the initial documentation. 4. Configure
`.gitignore`. 5. Define how Terraform state and secrets are stored. 6.
Record tool versions and compatibility decisions. 7. Keep the upstream
Kubespray checkout separate from custom inventory and configuration.

**Completion criteria:** - The repository has a clear structure. -
Private keys, credentials, kubeconfig files, Terraform state, and
sensitive logs are excluded from Git. - Build instructions and version
decisions have an authoritative location.

### Phase 6 --- Provision the four Kubernetes-ready VMs

**Goal:** Use Terraform and cloud-init to create the complete VM
environment.

**Activities:** 1. Create `cp1`, `w1`, `w2`, and `w3`. 2. Apply the
agreed CPU, RAM, and disk sizing. 3. Configure static IP addresses and
hostnames. 4. Configure SSH access. 5. Validate QEMU guest agent
functionality. 6. Validate host-to-guest and guest-to-guest
connectivity. 7. Check disk allocation and actual host storage
consumption. 8. Test a controlled Terraform rebuild.

**Completion criteria:** - All four VMs are running the expected Ubuntu
version. - Hostnames, IP addresses, resources, and SSH access are
correct. - The environment can be recreated from the repository.

**Scope boundary:** The VMs are prepared for Kubernetes, but Kubernetes
is not installed yet.

### Phase 7 --- Learn Ansible and deploy Kubernetes with Kubespray

**Goal:** Understand Ansible and use Kubespray to deploy upstream
Kubernetes.

**Entry condition:** Select a stable Kubespray release whose
dependencies and supported versions have been verified. Do not use an
unpinned development branch as the production build reference.

**Topics to learn:** - Ansible inventories. - Playbooks, roles, and task
execution. - Variables and group variables. - Ansible Vault. - Kubespray
architecture and execution flow. - Operating-system preparation. -
containerd configuration. - Kubernetes certificates and etcd. -
Kubernetes control-plane and worker components.

**Activities:** 1. Select and pin a stable Kubespray release or commit.
2. Verify its supported Ubuntu, Python, Ansible, Kubernetes, and addon
versions. 3. Prepare an isolated Python environment. 4. Install the
exact Ansible dependencies. 5. Create the inventory for `cp1` and
`w1`--`w3`. 6. Configure one control-plane/etcd node and three workers.
7. Review the deployment variables before execution. 8. Deploy
Kubernetes. 9. Validate API availability, node readiness, and system
components. 10. Document the cluster health checks and rebuild
procedure.

**Completion criteria:** - The Kubernetes API is available. - One
control-plane node and three workers are Ready. - The deployed versions
match the approved compatibility record. - Cluster deployment is
reproducible from the documented process.

### Phase 8 --- Learn Cilium and Kubernetes networking

**Goal:** Understand Cilium's networking architecture and expose
applications through Kubernetes networking capabilities.

**Learning sequence:**

1.  **Cilium CNI and eBPF**
    -   Understand the CNI role.
    -   Learn the basic eBPF datapath concepts.
    -   Inspect Cilium agents and their health.
2.  **kube-proxy replacement**
    -   Understand the role of kube-proxy.
    -   Learn how Cilium can implement Kubernetes service handling.
    -   Validate the selected replacement mode.
3.  **LoadBalancer IPAM**
    -   Configure an IP pool for the agreed lab range.
    -   Create a LoadBalancer service.
    -   Validate address allocation.
4.  **L2 announcements**
    -   Understand announcement and leader-election behavior.
    -   Configure an L2 announcement policy.
    -   Verify reachability from the Ubuntu desktop.
    -   Confirm that the design does not unintentionally expose services
        to the physical LAN.
5.  **Gateway API**
    -   Understand Gateway API resources and their relationship.
    -   Install compatible Gateway API CRDs as required by the selected
        Cilium release.
    -   Configure a Gateway.
6.  **HTTPRoute**
    -   Deploy a sample application.
    -   Configure HTTPRoute-based application routing.
    -   Validate access from the desktop.

**Completion criteria:** - Cilium is healthy. - The selected kube-proxy
replacement mode is verified. - A LoadBalancer IP is allocated and
reachable from the desktop. - L2 announcements behave as expected. - A
sample application is reachable through Gateway API and HTTPRoute.

### Phase 9 --- Learn Kubernetes persistent storage

**Goal:** Understand Local Path Provisioner and the operational
boundaries of node-local storage.

**Topics to learn:** - PersistentVolumes (PV). - PersistentVolumeClaims
(PVC). - StorageClasses. - Dynamic provisioning. - Access modes and
reclaim policies. - Node-local data placement. - Pod recreation versus
node failure. - Backup and restore limitations.

**Activities:** 1. Deploy Local Path Provisioner through the selected
Kubespray-supported mechanism. 2. Inspect its StorageClass and
provisioner configuration. 3. Create a PVC and a test workload. 4. Write
data to the mounted volume. 5. Delete and recreate the pod. 6. Verify
that data remains available when the workload returns to the same node.
7. Document what happens when the node becomes unavailable. 8. Define an
appropriate backup and recovery approach.

**Completion criteria:** - A PVC dynamically binds. - Data persists
through pod recreation under the tested conditions. - Node-local storage
limitations and recovery behavior are documented.

**Important:** Pod recreation is not proof of node-failure recovery.
Local Path Provisioner does not provide replicated storage or automatic
cross-node data migration.

### Phase 10 --- Operations, backup, recovery, and maintenance

**Goal:** Learn to operate and rebuild the lab reliably.

**Topics and activities:** - Terraform state backup and recovery. - VM
snapshot behavior and limitations. - etcd backup and restore. -
Application data backup and restore. - Kubernetes and Kubespray
upgrades. - Cilium and Gateway API compatibility during upgrades. -
Storage maintenance. - Cluster health checks. - Troubleshooting
procedures. - Full rebuild from the authoritative documentation.

**Backup principles:** - VM snapshots are not a replacement for etcd
backups. - etcd backups are not a replacement for application data
backups. - Application data needs its own backup and restore
procedure. - Snapshot consistency and disk capacity must be considered
before taking snapshots.

**Completion criteria:** - The lab can be rebuilt from documented
steps. - Important cluster state and application data have separately
documented recovery procedures. - Upgrade and maintenance procedures are
recorded.

------------------------------------------------------------------------

## 4. Working Rules

The project will follow these rules throughout implementation:

1.  Work through one phase and one design topic at a time.
2.  Explain the concept before asking the user to execute commands.
3.  Agree on architecture and configuration before implementation.
4.  Provide exact paths and commands.
5.  Inspect actual command output before deciding the next action.
6.  Use Zed as the editor; do not use `nano`.
7.  Use the repository-local `tmp/` directory for temporary files; avoid
    `/tmp` for project working files.
8.  Do not perform destructive actions without explicit user
    confirmation.
9.  Keep secrets separate from source-controlled configuration.
10. Do not introduce unnecessary automation before understanding the
    underlying technology.
11. Maintain one authoritative build runbook at
    `docs/BUILD_FROM_SCRATCH.md`.
12. Record expected results and validation commands for each significant
    step.
13. Do not proceed to the next phase until the current phase's
    completion criteria are met.
14. Pin versions and verify compatibility rather than assuming that the
    latest versions work together.

------------------------------------------------------------------------

## 5. Version and Compatibility Management

The technology versions must be selected as a compatible set, not
independently.

Before Kubernetes deployment, verify and record:

-   Terraform version.
-   Terraform libvirt provider version.
-   Ubuntu guest image version.
-   Python version.
-   Ansible and `ansible-core` versions.
-   Kubespray stable release or commit.
-   Kubernetes version.
-   containerd version.
-   Cilium version.
-   Gateway API version.
-   Local Path Provisioner version or Kubespray addon revision.

The compatibility record must be based on official release
documentation, tagged Kubespray defaults, dependency files, and
component release documentation.

Do not select a Kubespray development branch or an unsupported
dependency combination merely to use the newest component release.
Revisit the matrix when the next suitable stable Kubespray release is
available.

------------------------------------------------------------------------

## 6. Initial Project Scope and Non-Goals

### Included

-   Local Ubuntu desktop virtualization.
-   Four Ubuntu guest VMs.
-   One control-plane/etcd node and three workers.
-   Terraform-managed libvirt infrastructure.
-   cloud-init-based VM initialization.
-   Ansible/Kubespray-based upstream Kubernetes deployment.
-   containerd and Cilium.
-   Cilium LoadBalancer IPAM and L2 announcements.
-   Cilium Gateway API and HTTPRoute.
-   Local Path Provisioner.
-   Repeatable build and validation documentation.

### Not included in the initial build

-   High availability for the Kubernetes control plane or etcd.
-   Physical LAN exposure of LoadBalancer services.
-   Distributed or replicated persistent storage.
-   Production-grade disaster recovery.
-   Public cloud infrastructure.
-   Terraform management of Kubernetes resources through the Kubernetes
    provider.
-   Terraform provisioners for Kubernetes installation.

These may be considered later as separate learning extensions.

------------------------------------------------------------------------

## 7. Current Status and Next Step

**Current status:** Roadmap and high-level architecture proposed.
Implementation has not started.

**Next activity:** Phase 0, Topic 1 --- understand KVM, QEMU, and
libvirt, including how they work together and how the setup compares
with the previous Multipass/QEMU lab.

No host changes, VM creation, or Kubernetes installation should occur
until the relevant design and implementation steps have been reviewed
and approved.
