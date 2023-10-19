# wodbooster
Automation to enroll daily workouts in WodBuster web application.

## Requirements

You will need [Packer] to build an EC2 image that contains all the tools required to run this application.

```shell
brew install packer
```

## Infrastructure

### Build

To build the image execute:

```shell
cd iac/image
packer init .
packer fmt .
packer validate .
packer build aws.pkr.hcl
```

### Deploy

To deploy the required infrastructure execute:

```shell
terraform init
terraform validate
terraform plan
terraform apply
```

[Packer]: https://www.packer.io/
