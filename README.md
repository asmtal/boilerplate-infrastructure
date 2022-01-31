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
| GCP_REGION               | `europe-central2`          | `europe-central2`    | `europe-central2`   |
| GCP_BUCKET_NAME          | `[bucket_name]`            |                      |                     |

With the above settings, using GitHub Actions will be possible and internal scripts will be able to perform operations on the GCP cloud.

**Note that the keyfile json has also been uploaded to the `boilerplate-infrastructure` repo - which means that infrastructure is code too, 
and with changes to the configuration (terraform in our case), the production infrastructure will be affected.**

## Setup infrastructure

```shell
$ bin/terraform init -backend-config=backend.conf
$ bin/terraform apply
```

## Destroy infrastructure

```shell
$ bin/terraform destroy
```

## Infrastructure code formatting

```shell
$ bin/terraform fmt -recursive
```
