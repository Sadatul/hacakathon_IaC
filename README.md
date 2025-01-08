# Infrastructure as Code - BUET CSE Fest DevOps Hackathon

This repository contains the infrastructure setup for a project developed during the BUET CSE Fest DevOps Hackathon. The infrastructure is managed using Terraform and Kubernetes, deployed on Google Cloud Platform (GCP).

## Project Overview

The infrastructure setup includes:
- GKE (Google Kubernetes Engine) clusters for QA and Production environments
- Cloud SQL (MySQL) database instances
- Redis instances for caching
- RabbitMQ for message queuing
- OpenTelemetry collector for observability
- Nginx Ingress Controller
- Cert-Manager for SSL/TLS certificate management

## Repository Structure

```
.
├── backend/          # Backend Terraform state configuration
├── global/          # Global service APIs configuration
├── k8s/             # Kubernetes manifests and configurations
│   ├── config/      # Environment-specific configurations
│   └── manifests/   # Kubernetes resource definitions
├── modules/         # Reusable Terraform modules
│   └── app-backend/ # Main application infrastructure module
├── prod/           # Production environment configuration
└── qa/             # QA environment configuration
```

## Features

- **Multi-Environment Setup**: Separate QA and Production environments
- **Private Network**: VPC with private subnets and appropriate firewall rules
- **Managed Services**:
  - Cloud SQL with private networking
  - Redis with private service access
  - GKE clusters with workload identity
- **Observability**:
  - OpenTelemetry collector for metrics and traces
- **Security**:
  - Secret Manager integration
  - Service accounts with minimal permissions
  - Private networking for all components
- **Load Balancing & SSL**:
  - Nginx Ingress Controller
  - Let's Encrypt integration via cert-manager

## Prerequisites

- Google Cloud SDK
- Terraform >= 1.0
- kubectl
- Access to a GCP project
- Required GCP APIs enabled:
  - Compute Engine
  - Kubernetes Engine
  - Cloud SQL
  - Secret Manager
  - Redis
  - Service Networking

## Monitoring and Observability

- Distributed tracing with Zipkin
- Metrics collection with OpenTelemetry
- Google Cloud monitoring integration
- RabbitMQ monitoring dashboard

## Security Considerations

- All sensitive data stored in Secret Manager
- Private networking for databases and Redis
- Workload Identity for secure pod authentication
- Basic authentication for monitoring dashboards
- SSL/TLS certificates managed by cert-manager

## Contributing

1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Create a new Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.
