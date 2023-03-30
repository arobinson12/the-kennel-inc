#!/bin/bash

# This script searches through all projects within the GCP organization where it is run and enables GKE Security Posture Management (workload vulnerability scanning & workload config audit) on existing clusters

# Get all projects in the organization
projects=$(gcloud projects list --format='value(project_id)')

# Loop through each project
for project in $projects; do
  echo "Checking project $project..."

  # Get all GKE clusters in the project
  clusters=$(gcloud container clusters list --project="$project" --format='value(name, location)')

  # Loop through each cluster
  for cluster in $clusters; do
    name=$(echo "$cluster" | awk '{print $1}')
    region=$(echo "$cluster" | awk '{print $2}')

    # Enable workload-vulnerability-scanning
    echo "Enabling workload-vulnerability-scanning for cluster $name in region $region..."
    gcloud beta container clusters update "$name" --region="$region" --enable-workload-vulnerability-scanning

    # Wait for 10 seconds before enabling the next feature
    sleep 10

    # Enable workload-config-audit
    echo "Enabling workload-config-audit for cluster $name in region $region..."
    gcloud beta container clusters update "$name" --region="$region" --enable-workload-config-audit

    # Wait for 30 seconds before processing the next cluster
    sleep 30
  done
done
