# Grafana Setup and Dashboard Creation

This document explains how to set up Grafana in a Kubernetes cluster using Helm and how to create a custom dashboard.

## Table of Contents
1. [Prerequisites](#prerequisites)
2. [Setup Grafana using Helm](#setup-grafana-using-helm)
3. [Configure Grafana Values](#configure-grafana-values)
4. [Access Grafana](#access-grafana)
5. [Import the Custom Dashboard](#import-the-custom-dashboard)
6. [Configure Alerts in Grafana](#configure-alerts-in-grafana)
7. [Troubleshooting](#troubleshooting)

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

---

```yaml
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update
Step 2: Deploy Grafana
Run the following Helm command to deploy Grafana:

```yaml
helm upgrade --install grafana bitnami/grafana \
  -f grafana-values.yml \
  --set service.type=LoadBalancer \
  --set adminPassword=admin \
  --wait --timeout 10m

Options explained:
```yaml
-f grafana-values.yml: Path to the custom Grafana values file.
--set service.type=LoadBalancer: Exposes Grafana via a LoadBalancer.
--set adminPassword=admin: Sets the admin password to admin.
Configure Grafana Values
The grafana-values.yml file is used to customize Grafana. Below is an example configuration:

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
Place any dashboard JSON files in the appropriate folder or use ConfigMaps for importing dashboards.

Access Grafana
Once Grafana is deployed, get the LoadBalancer URL using the following command:

```yaml
kubectl get svc grafana -n monitoring
Look for the EXTERNAL-IP in the output. Open the IP address in your browser:

```yaml
http://<EXTERNAL-IP>
Log in using the default credentials:

Username: admin
Password: admin (or the one you set in the values file)
Import the Custom Dashboard
Go to the Grafana UI.
Navigate to Dashboards → Import.
Upload the dashboard.json file located in the root directory of the project:
dashboard.json
Click Import to create the dashboard.
The custom dashboard will display metrics as defined in the dashboard.json file.

Configure Alerts in Grafana
1. Set up Email Notifications
To receive email alerts, configure the SMTP settings in Grafana. Add the following to your grafana-values.yml file:

```yaml
smtp:
  enabled: true
  host: email-smtp.eu-west-1.amazonaws.com:587
  user: <AWS_SES_SMTP_USER>
  password: <AWS_SES_SMTP_PASSWORD>
  fromAddress: <YOUR_VERIFIED_EMAIL>
  fromName: "Grafana Alerts"
Replace the placeholder values with your actual AWS SES SMTP credentials and your verified email address.

2. Create Alerts for CPU and Memory Usage
2.1 CPU Usage Alert
Go to Alerting → Alert Rules → New Alert Rule.
Set the alert for CPU usage using the following PromQL query:
```yaml
sum(rate(node_cpu_seconds_total{mode!="idle"}[5m])) by (instance) / sum(rate(node_cpu_seconds_total[5m])) by (instance) * 100

Set the alert condition to trigger when the CPU usage exceeds 80%:
Condition: When the average of the query is above 80.
Evaluation: Every 1 minute, for 3 minutes.
Name the alert High CPU Usage Alert and save it.
2.2 Memory Usage Alert
Create another alert using the following PromQL query to monitor memory usage:
```yaml
(1 - (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes)) * 100

Set the alert condition to trigger when memory usage exceeds 80%:
Condition: When the average of the query is above 80.
Evaluation: Every 1 minute, for 3 minutes.
Name the alert High Memory Usage Alert and save it.
3. Test Alerts
3.1 Test CPU Alert
To simulate high CPU usage, run the following stress test:

```yaml
stress --cpu 4 --timeout 300
3.2 Test Memory Alert
To simulate high memory usage, run the following stress test:

```yaml
stress --vm 1 --vm-bytes 90% --timeout 300
3.3 Verify Alerts
In Grafana, go to Alerting → Active Alerts to see the alerts transition to the Firing state. Check your email inbox for the notifications.

Troubleshooting
Grafana not accessible:

Ensure the service type is set to LoadBalancer.
Verify the Kubernetes cluster is running and accessible.
Dashboard not loading:

Check the JSON file syntax in dashboard.json.
Ensure the dashboard configuration path is correct in the grafana-values.yml file.
Helm deployment fails:

Run helm status grafana -n monitoring to view error details.
Ensure the cluster has sufficient resources (CPU/Memory).
References
Bitnami Grafana Helm Chart
Grafana Documentation