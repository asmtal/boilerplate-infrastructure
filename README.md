# boilerplate-infrastructure

## Initial steps in the [GCP Console](https://console.cloud.google.com)

Long story short - we want to create a project, bucket, service account and generate a private key which 
we will use to authorize ourselves during builds, infrastructure deployment scripts etc.

Unfortunately, we have to do it manually so that everything happens automatically later.
This is a popular "what came first - the chicken or the egg" problem.

1. Create a [project](https://console.cloud.google.com/projectcreate) `[project-name]`
2. Create a [service account](https://console.cloud.google.com/iam-admin/serviceaccounts/create) `[service-account-name]`
3. Assign "Owner" role (yes, I know, too general, but with the next commits I will be narrowing down these permissions (after proper testing))
4. Generate key for created service account - [service accounts](https://console.cloud.google.com/iam-admin/serviceaccounts) -> "Manage keys" -> "Create new key"
5. Now you have generated the key pair and the private key has been downloaded to your computer
6. Create a [bucket](https://console.cloud.google.com/storage/create-bucket) `[bucket-name]` in the Cloud Storage
7. Now you need to set some variables in GitHub repository secrets (your repository -> Settings -> Secrets -> Actions -> "New repository secret"):

| repository / secret name   | GCP_KEYFILE_JSON | GCP_PROJECT_NAME | GCP_BUCKET_NAME |
| -------------------------- |      :---:       |      :---:       |      :---:      |
| boilerplate-infrastructure | •                | •                | •               |
| boilerplate-frontend       | •                |                  |                 |
| boilerplate-backend        | •                |                  |                 |

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
