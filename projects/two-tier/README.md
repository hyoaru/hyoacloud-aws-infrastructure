# Project: Two-Tier Web Application

This repository contains the **Project Layer** infrastructure for a highly available, two-tier web application. It is designed to consume shared networking resources (VPC, Subnets, NAT) provided at the **Space** level.

## Architecture

The project implements a classic web architecture spanning multiple Availability Zones for fault tolerance.

![](./resources/diagram.drawio.png)

### Component Ownership

- **Networking (Space Layer):** This project imports the VPC, Public Subnets (for the ALB), and Private Subnets (for the ASG) from the **Space** layer.
- **Security (Project Layer):** Defines the Security Group boundaries specific to the application.
- **Load Balancing (Project Layer):** An Application Load Balancer (ALB) that handles external traffic on Port 80 and routes to the app tier on Port 8080.
- **Compute (Project Layer):** An Auto Scaling Group (ASG) managing EC2 instances running a Python 3 web server.
