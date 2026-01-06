## Google Cloud OIDC Login using GitHub Actions (Step-by-Step)

This document explains how to login to Google Cloud from GitHub Actions using OIDC
without using Service Account keys.

This is the recommended and secure approach by Google Cloud.

# Overall Flow
1. Login to Google Cloud Console
2. Go to IAM → Workload Identity Federation (WIF)
3. Create Workload Identity Pool
4. Create OIDC Provider (GitHub)
5. Create Service Account
6. Bind Service Account with Provider
7. Create GitHub Repository
8. Create GitHub Actions YAML
9. Run the workflow

## 1. Login to Google Cloud Console

Open: https://console.cloud.google.com

Login using your Google account

Select or create a GCP Project

Example:

Project ID: my-sample-project

## 2️. Go to Workload Identity Federation (WIF)

Open IAM & Admin

Click Workload Identity Federation

Click Create Pool

Path:

IAM & Admin → Workload Identity Federation

## 3. Create Workload Identity Pool

Fill the form with example values:

Field	Example
Pool name	github-pool
Pool ID	github-pool
Description	Pool for GitHub Actions

Click Create

Pool is created

## 4. Create OIDC Provider (GitHub)

Inside the pool, click Add Provider

Provider Details (Example)
Field	Value
Provider name	github-provider
Provider ID	github-provider
Issuer URL	https://token.actions.githubusercontent.com
Audience

Use default audience
(or Google auto-fills it)

Example:

https://iam.googleapis.com/projects/PROJECT_NUMBER/locations/global/workloadIdentityPools/github-pool/providers/github-provider

Attribute Mapping (Example)
Google Attribute	OIDC Attribute
google.subject	assertion.sub
attribute.repository	assertion.repository
attribute.actor	assertion.actor
Attribute Condition (Optional but Recommended)

Restrict access to a specific repository:

assertion.sub.startsWith("repo:example-org/example-repo:")


Click Save

 Provider is created

## 5. Create Service Account

Go to:

IAM & Admin → Service Accounts → Create Service Account


Example values:

Field	Example
Name	github-deployer
ID	github-deployer
Description	GitHub OIDC Service Account

Click Create

## 6️. Bind Service Account with Provider

This allows GitHub to impersonate the service account.

Binding Concept (Important)
GitHub Repo → OIDC Provider → Service Account


Example binding:

Role: roles/iam.workloadIdentityUser

Principal set:

principalSet://iam.googleapis.com/projects/PROJECT_NUMBER/locations/global/workloadIdentityPools/github-pool/attribute.repository/example-org/example-repo


 Save the binding

## 7️. Create GitHub Repository

Go to https://github.com

Create a new repository

Example:

Repository name: example-repo
Owner: example-org

## 8. Create GitHub Actions Workflow File

Inside your repository, create this file:

.github/workflows/gcp-login.yml

Example GitHub Actions YAML
name: GCP OIDC Login Test

on:
  push:
    branches:
      - main

jobs:
  login:
    runs-on: ubuntu-latest

    permissions:
      id-token: write
      contents: read

    steps:
      - name: Checkout Code
        uses: actions/checkout@v4

      - name: Authenticate to Google Cloud
        uses: google-github-actions/auth@v2
        with:
          workload_identity_provider: projects/PROJECT_NUMBER/locations/global/workloadIdentityPools/github-pool/providers/github-provider
          service_account: github-deployer@my-sample-project.iam.gserviceaccount.com

      - name: Verify Login
        run: gcloud projects list

## 9️. Run the Workflow
How to trigger the workflow

Commit the YAML file

Push to the main branch

git add .
git commit -m "Add GCP OIDC login workflow"
git push origin main

 Verify Result

Go to GitHub → Actions

Open the workflow run

If you see gcloud projects list output

## Google Cloud login is successful

# Security Benefits

 ## No service account keys

 ## Short-lived tokens

 ## Repository-restricted access

# Recommended by Google

📌 Notes for New Developers

Always use OIDC, not JSON keys

Attribute condition is highly recommended

Workflow must be inside .github/workflows/

id-token: write permission is mandatory

# Summary
Step	Status
Google Cloud Login	
WIF Pool & Provider	
Service Account	
GitHub Actions	
Secure Authentication	
