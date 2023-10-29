# wodbooster

Automation to enroll daily workouts in WodBuster web application.

## Run

We can run this locally connecting to an existing Google Chrome window by doing:

```shell
open -a 'Google Chrome' --args --no-sandbox --disable-setuid-sandbox --remote-debugging-port=9222

cd src && yarn build && cd -

export WB_CHROME_ENDPOINT=127.0.0.1:9222
export WB_CONFIG_FILE=config.yml
export WB_LOCAL_SCREENSHOTS=0
export WB_USERNAME_1=josriolop@gmail.com
export WB_PASSWORD_1=REDACTED

node src/.build/local.js
```

## Environment Variables

| Name                           | Description                           | Default |
|--------------------------------|---------------------------------------|---------|
| WB_BUCKET_NAME                 | S3 bucket where to upload screenshots |         |
| WB_CHECK_HEADERS               | Check headers for debugging purposes  |         |
| WB_CHROME_ENDPOINT             | Chrome debug endpoint to connect to   |         |
| WB_CHROME_PATH                 | Chrome executable path                |         |
| WB_CONFIG_FILE                 | Configuration file                    |         |
| WB_LOCAL_SCREENSHOTS           | Do take local screenshots             |         |
| WB_LOCAL_SCREENSHOTS_BASE_PATH | Location to store local screenshots   |         |
| WB_NO_HEADLESS                 | Do not use headless chrome            |         |
| WB_NO_SCREENSHOTS              | Do not take screenshots               |         |
| WB_USERNAME_1                  | User 1 username                       |         |
| WB_PASSWORD_1                  | User 1 password                       |         |

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
