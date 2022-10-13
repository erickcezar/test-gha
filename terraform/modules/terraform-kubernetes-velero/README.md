# Terraform Kubernetes Velero

Taking backup is very important! While we usually set automatic backups of other managed services, there isn't a proper feature to take backup from kubernetes cluster. [Velero](https://github.com/heptio/velero) takes backups of kubernetes objects on a bucket and integrates with the cloud provider (DigitalOcean, AWS, GCP, etc) to also take snapshots of attached volumes (PV).

This module relies on the official [helm chart](https://github.com/vmware-tanzu/helm-charts/tree/master/charts/velero) to deploy velero on kubernetes.

This module was specifically designed to backup kubernetes running on DigitalOcean (DOKS) and store it in 2 different locations: DigitalOcean spaces and AWS S3.

Velero can be configured to make backups in a specific schedule, for each destination provider. The schedule uses a [CRON](https://velero.io/docs/v1.8/backup-reference/#schedule-a-backup) approach and the time is defined on UTC.

## Limitations

The official helm chart can configure only one credential for one cloud provider. Therefore, to enable
backups to a second provider it is necessary do apply the velero CRD for the second backup location, snapshot location and schedule.

For this module, the main helm chart configures backups stored in AWS while the file "digitalocean.tf" contains the terraform resources for the secondary backup location.

## Volume snapshots

Velero uses plugins to interact with the Cloud provider where the kubernetes cluster is running (as well as its physical volumes) to create volume snapshots. Volume snapshots are a copy a volume's contents at a particular point in time without the need of creating an entirely new volume.
Because snapshots are specifically bonded to the cloud provider, it is not exportable to another. In other words, a snapshot made on DigitalOcean volume exists only in the DigitalOcean provider and is not exported or copied to AWS. In AWS, the backup will contain all kubernetes objects definitions plus the volume snapshot path in DigitalOcean that can be restored in that specific point in time.
