# boilerplate-infrastructure

## Initial steps in the [GCP Console](https://console.cloud.google.com)

Long story short - we want to create a project, bucket, service account and generate a private key which 
we will use to authorize ourselves during builds, infrastructure deployment scripts etc.

Unfortunately, we have to do it manually so that everything happens automatically later.
This is a popular "what came first - the chicken or the egg" problem.

1. Create a [project](https://console.cloud.google.com/projectcreate) `[project_name]`
2. After creating a project, you will have available the project id `[project_id]`
2. Create a [service account](https://console.cloud.google.com/iam-admin/serviceaccounts/create) `[service_account_name]`
3. Assign "Owner" role (yes, I know, too general, but with the next commits I will be narrowing down these permissions (after proper testing))
4. Generate key for created service account - [service accounts](https://console.cloud.google.com/iam-admin/serviceaccounts) -> "Manage keys" -> "Create new key"
5. Now you have generated the key pair and the private key (`[keyfile_json]`) has been downloaded to your computer
6. Create a [bucket](https://console.cloud.google.com/storage/create-bucket) `[bucket_name]` in the Cloud Storage
7. Now you need to set some variables in GitHub repository secrets (your repository -> Settings -> Secrets -> Actions -> "New repository secret"):

| secret name / repository | boilerplate-infrastructure | boilerplate-frontend | boilerplate-backend |
| ------------------------ |           :---:            |        :---:         |        :---:        |
| GCP_KEYFILE_JSON         | `[keyfile_json]`           | `[keyfile_json]`     | `[keyfile_json]`    |
| GCP_PROJECT_ID           | `[project_id]`             | `[project_id]`       | `[project_id]`      |
| GCP_REGION               | `us-central1`              | `us-central1`        | `us-central1`       |
| GCP_BUCKET_NAME          | `[bucket_name]`            |                      |                     |

With the above settings, using GitHub Actions will be possible and internal scripts will be able to perform operations on the GCP cloud.

**Note that the keyfile json has also been uploaded to the `boilerplate-infrastructure` repo - which means that infrastructure is code too, 
and with changes to the configuration (terraform in our case), the production infrastructure will be affected.**

## Working with code (manual changes from the local environment)

### Infrastructure setup

* Authenticate to your `gcloud` account to fully manage your cloud resources.
* Set the environment variables on your machine (the same ones that are required in the `boilerplate-infrastructure` repository secrets).
* Apply configuration (networking, sql, cluster, k8s configuration etc.):

```shell
$ bin/terraform init -backend-config=backend.conf
$ bin/terraform apply
```

* Push front-end and back-end images to the Artifact Registry.

Once you have properly configured your repositories based 
on `boilerplate-frontend` and `boilerplate-backend`, all you 
need to do is run the CI process and the images will be 
found in the registry.

### Infrastructure destroying

```shell
$ bin/terraform destroy
```

### Code formatting

```shell
$ bin/terraform fmt -recursive
```

### Working with `kubectl` locally

#### Initial settings to access the cluster

1. Get credentials and update KUBECONFIG (`~/.kube/config`):

```shell
$ gcloud container clusters get-credentials [cluster_name] --region [region]
```

2. Verify that you are in the right context:

```shell
$ gcloud config current-context
```

3. Verify that you see resources from your cluster:

```shell
$ kubectl get pods --namespace [namespace]
```

#### Connect to the kubernetes pod

```shell
$ kubectl exec --stdin --tty [pod_name] -c [container_name] --namespace=[namespace] -- /bin/bash
```

#### For more details - see k8s configurations - [/terraform/k8s/config/main.tf](https://github.com/rootsher/boilerplate-infrastructure/tree/main/terraform/k8s/config/main.tf)

## Troubleshooting - popular problems

* **"Google Cloud APIs is not ready yet"**

First time running `terraform apply` - there may be problems with 
Google Cloud APIs. Terraform does not know when a particular API 
will be available. You'll have to wait a few minutes. Subsequent 
runs should pass without problems - this is due to 
the `disable_on_destroy` configuration.

* **"Zone unavailability"**

Sometimes a zone may not be available or there is no space 
for the resources you want to create. Don't worry - it can 
happen - just wait and try again in a few minutes.

* Getting dynamic values from the configuration:

```shell
$ bin/terraform output -raw database_host
```
