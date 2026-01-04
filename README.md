# AWS Multi-Layer Infrastructure Factory

My personal multi-tier cloud infrastructure framework using AWS CloudFormation. This repository implements a **Tiered Authority Model**, separating global governance and shared environment foundations from individual project lifecycles.

## Prerequisites

Before deploying any layers, ensure your environment is configured:

- AWS CLI v2: Installed and configured with AdministratorAccess (for Core/Space) or PowerUserAccess (for Project).

- Permissions: Your IAM Identity must have AdministratorAccess policy temporarily.

## Projects

This repository hosts diverse application patterns that demonstrate the flexibility of this model.

### 1. Two-Tier Web Architecture

A classic high-availability web pattern designed for fault tolerance and scalability.

![](./projects/two-tier/resources/diagram.drawio.png)

- **Architecture**: An Application Load Balancer (ALB) in the Space public subnets routing traffic to an Auto Scaling Group (ASG) in the private subnets.
- **State Management**: Uses a Launch Template to bootstrap EC2 instances with a Python 3 web server.
- **Layer Integration**: Imports VPC and Subnet IDs from the Space layer and Security Group rules from the Project layer.
- **Path**: `projects/two-tier/`

### 2. Serverless Office Hours Instance Scheduler

An event-driven cost-optimization tool tailored for teams in the Philippine Timezone (PHT).

![](./projects/serverless-office-hours-instance-scheduler/resources/diagram.drawio.png)

- **Architecture**: EventBridge Scheduler triggers a containerized Lambda function to START and STOP environments.
- **Logic**: Natively supports Asia/Manila time to ensure instances are only running during 09:00 - 18:00 PHT.
- **Registry**: Pulls Docker images from a centralized Core Layer ECR repository.
- **Codebase**: The application logic (Python/Docker) is maintained in the [serverless-office-hours-instance-scheduler](https://github.com/hyoaru/serverless-office-hours-instance-scheduler) repository.
- **Path**: `projects/serverless-office-hours-instance-scheduler/`

## Repository Structure

```
.
├── core/    # ADMIN: Global Foundational Resources
├── spaces/    # OPERATOR: Shared Regional Infrastructure (VPC, NAT)
│   ├── infrastructure/    # Multi-AZ Networking & Shared IAM Roles
│   └── parameters/    # Configs for dev, stage, and prod spaces
├── projects/   # PROJECT: Application-specific workloads
│   └── two-tier/    # Example: ALB -> ASG Architecture
├── scripts/    # AUTOMATION: Deployment & Destruction logic
└── Makefile    # INTERFACE: Standardized entry point for all layers deployment
```

## The Three-Layer Authority Model

The architecture is governed by who owns the resources and the scope of their impact:

### 1. Core Layer (The Admin Foundation)

- **Scope:** Global / Account-wide.
- **Authority:** Cloud Administrators.
- **Purpose:** Establishes the immutable baseline. It manages identity discovery policies, global IAM groups, and baseline security guardrails that apply to every resource in the account.
- **Stability:** High (Rarely changes).

### 2. Space Layer (The Operator Environment)

- **Scope:** Shared Environment-wide [`dev`, `stage`, `prod`].
- **Authority:** Operators / DevOps.
- **Purpose:** The "Landing Zone" for a specific environment. It manages the VPC, Regional NAT Gateways, shared connectivity, and the IAM Roles that allow Projects to function.

### 3. Project Layer (The Application Workspace)

- **Scope:** Project and environment specific [`dev`, `stage`, `prod`].
- **Authority:** Project Owners / Developers.
- **Purpose:** Where the actual business value resides. It consumes resources (Subnets, Security Groups, Roles) provided by the **Space** and **Core** layers to deploy ALBs, Auto Scaling Groups, and Databases.

## Cross-Stack Reference Logic

This repository utilizes a Loose Coupling strategy via Export and `Fn::ImportValue`.

1. Lower Layers (Space) export their Resource IDs (e.g., dev-vpc-id).

2. Upper Layers (Project) import those IDs using `!ImportValue`.

3. Constraint: You cannot delete a Space stack if a Project stack is currently using its exports. You must destroy in the order: `Project` -> `Space` -> `Core`.

## Security & Governance

- Tagging Policy: Every resource is automatically tagged with Environment and Project to support ABAC (Attribute-Based Access Control).

## Deployment Workflow

Deployment follows a "Strict Dependency" chain. Resources are Exported from lower layers and Imported into higher layers.
| Order | Layer | Responsibility | Primary Resources |
| :--- | :--- | :--- | :--- |
| 1 | **Core** | Administration | Core Policies, IAM Groups |
| 2 | **Space** | Infrastructure | Shared VPC, Subnets, Roles, NAT |
| 3 | **Project** | Application | ALB, Target Groups, Launch Templates, ASG |

### Automation Interface

The `Makefile` acts as the primary entry point for all infrastructure operations. It abstracts the complex AWS CLI commands into simple, positional arguments mapped to specific scripts in the `/scripts` directory.

#### Command Summary

| Layer       | Action  | Command                | Variable Arguments              |
| :---------- | :------ | :--------------------- | :------------------------------ |
| **Core**    | Deploy  | `make deploy-core`     | `group` `layer`                 |
| **Core**    | Destroy | `make destroy-core`    | `group` `layer`                 |
| **Space**   | Deploy  | `make deploy-space`    | `env` `group` `layer`           |
| **Space**   | Destroy | `make destroy-space`   | `env` `group` `layer`           |
| **Project** | Deploy  | `make deploy-project`  | `env` `project` `group` `layer` |
| **Project** | Destroy | `make destroy-project` | `env` `project` `group` `layer` |

### Usage Examples

The scripts use these variables to locate the correct `.yaml` templates in `/infrastructure` and their matching `.json` parameters.

#### 1. Core (Global Baseline)

To deploy the discovery policies for the Compute group:

```bash
make deploy-core group=000-iam-policies layer=005-compute-services-discovery
```

#### 2. Space (Environment Foundation)

To deploy the security group foundation in the dev environment:

```bash
make deploy-space env=dev group=003-network-core layer=002-security
```

#### 3. Project (Application Workload)

To deploy the Auto Scaling Group for the two-tier project in dev:

```bash
make deploy-project env=dev project=two-tier group=001-app-core layer=002-auto-scaling-group
```
