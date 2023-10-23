# wodbooster
Automation to enroll daily workouts in WodBuster web application.

## Run

We can run this locally connecting to an existing Google Chrome window by doing:

```shell
open -a 'Google Chrome' --args --no-sandbox --disable-setuid-sandbox --remote-debugging-port=9222

cd src && yarn build && cd -

export AWS_PROFILE=jotadrilo
export WB_BUCKET_NAME=wodbooster-screenshots
export WB_CHROME_ENDPOINT=127.0.0.1:9222
export WB_CONFIG_FILE=$PWD/config.yml
export WB_NO_HEADLESS=0
export WB_NO_SCREENSHOTS=0
export WB_PASSWORD_1=REDACTED
export WB_USERNAME_1=josriolop@gmail.com

node src/.build/local.js
```

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
