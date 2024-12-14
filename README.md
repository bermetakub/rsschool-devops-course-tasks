# Grafana Setup and Dashboard Creation

This document explains how to set up Grafana in a Kubernetes cluster using Helm and how to create a custom dashboard.

## Table of Contents
1. [Prerequisites](#prerequisites)
2. [Setup Grafana using Helm](#setup-grafana-using-helm)
3. [Configure Grafana Values](#configure-grafana-values)
4. [Access Grafana](#access-grafana)
5. [Import the Custom Dashboard](#import-the-custom-dashboard)
6. [Troubleshooting](#troubleshooting)

---

## Prerequisites

Before deploying Grafana, ensure the following:

1. A **Kubernetes cluster** is running and accessible (created with kOps, EKS, or similar).
2. **kubectl** is configured to connect to the cluster.
3. Helm 3+ is installed.
4. AWS credentials are set up if you are using AWS services.
5. The `grafana-values.yml` file is configured for custom settings.
6. A `kubeconfig` file is added to GitHub Secrets as `KUBE_CONFIG`.

---

## Setup Grafana using Helm

To deploy Grafana in the Kubernetes cluster, follow these steps:

### Step 1: Add the Helm Repo
Add the Bitnami Helm repository (used for deploying Grafana):

```bash
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update
```

### Step 2: Deploy Grafana
Run the following Helm command to deploy Grafana:

```bash
helm upgrade --install grafana bitnami/grafana \
  -f grafana-values.yml \
  --set service.type=LoadBalancer \
  --set adminPassword=admin \
  --wait --timeout 10m
```

**Options explained:**
- `-f grafana-values.yml`: Path to the custom Grafana values file.
- `--set service.type=LoadBalancer`: Exposes Grafana via a LoadBalancer.
- `--set adminPassword=admin`: Sets the admin password to `admin`.

---

## Configure Grafana Values

The `grafana-values.yml` file is used to customize Grafana. Below is an example configuration:

```yaml
adminUser: admin
adminPassword: admin
service:
  type: LoadBalancer
dashboardProviders:
  dashboard.yaml:
    apiVersion: 1
    providers:
      - name: 'default'
        orgId: 1
        folder: ''
        type: file
        disableDeletion: false
        options:
          path: /var/lib/grafana/dashboards/default
dashboardsConfigMaps:
  default: "grafana-dashboards"
```

Place any dashboard JSON files in the appropriate folder or use ConfigMaps for importing dashboards.

---

## Access Grafana

Once Grafana is deployed, get the LoadBalancer URL using the following command:

```bash
kubectl get svc grafana -n monitoring
```

Look for the `EXTERNAL-IP` in the output. Open the IP address in your browser:

```
http://<EXTERNAL-IP>
```

Log in using the default credentials:
- **Username**: `admin`
- **Password**: `admin` (or the one you set in the values file)

---

## Import the Custom Dashboard

1. Go to the Grafana UI.
2. Navigate to **Dashboards** → **Import**.
3. Upload the `dashboard.json` file located in the root directory of the project:

```
dashboard.json
```

4. Click **Import** to create the dashboard.

The custom dashboard will display metrics as defined in the `dashboard.json` file.

---

## Troubleshooting

1. **Grafana not accessible**:
   - Ensure the service type is set to `LoadBalancer`.
   - Verify the Kubernetes cluster is running and accessible.

2. **Dashboard not loading**:
   - Check the JSON file syntax in `dashboard.json`.
   - Ensure the dashboard configuration path is correct in the `grafana-values.yml` file.

3. **Helm deployment fails**:
   - Run `helm status grafana -n monitoring` to view error details.
   - Ensure the cluster has sufficient resources (CPU/Memory).

---

## References
- [Bitnami Grafana Helm Chart](https://bitnami.com/stack/grafana/helm)
- [Grafana Documentation](https://grafana.com/docs/)

---


