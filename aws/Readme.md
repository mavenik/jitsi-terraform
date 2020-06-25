# Jitsi setup on Amazon AWS

## How it works

* Creates an EC2 instance with a cloud-init script to install and configure Jitsi Meet.  
* Creates a security group that acts as firewall to regulate web traffic to your Jitsi Meet instance.  
* Creates a Route53 A Record under a previously hosted subdomain that points to this EC2 instance. E.g. `511066ad.meet.example.com`  
* Jitsi Meet server can be accessed at `https://<UUIDv4>.<hosted-subdomain>` E.g. `https://511066ad.meet.example.com`  
* Anonymous meetings cannot be initiated on this setup. One needs a moderator username and password to be able to initiate meets.  

[Prerequisites](#prerequisites)  

[Initial Setup](#initial-setup)  
* [Amazon AWS Console](#amazon-aws-console)
  - [Create a new public hosted zone](#create-a-new-public-hosted-zone-for-your-subdomain)
  - [Note nameservers](#note-nameservers-for-your-public-hosted-zone)
  - [Create AWS IAM User credentials](#create-aws-iam-user-credentials)
* [Domain Provider](#domain-provider)
  - [Add NS Records for your subdomain](#add-ns-records-for-your-subdomain)
* [Terraform Cloud](#terraform-cloud)
  - [Fork this repository](#fork-this-repository)
  - [Create a workspace](#create-a-workspace-in-terraform-cloud)
  - [Configure variables](#configure-variables)
  - [Launching your Jitsi Meet infrastructure](#launching-your-jitsi-meet-infrastructure)
  - [Destroying your Jitsi Meet infrastructure](#destroying-your-jitsi-meet-infrastructure)
* [Terminal (local execution)](#terminal)
  - [Configure AWS CLI](#configure-aws-cli)
  - [Clone this repository](#clone-this-repository)
  - [Set variables](#set-variables)
    - [Simulcast Streaming and Recording (Optional)](#simulcast-streaming-and-recording-with-jibri-optional)
  - [Creating your Jitsi Meet Server](#creating-your-jitsi-meet-server)
  - [Destroying your Jitsi Meet Server](#destroying-your-jitsi-meet-server)

## Prerequisites
* Registered domain and access to DNS Management
* Amazon AWS Account - [Creating an AWS Account](https://aws.amazon.com/premiumsupport/knowledge-center/create-and-activate-aws-account/)
* Terraform (required for local execution, can be skipped for Terraform Cloud) - [Installing Terraform](https://learn.hashicorp.com/terraform/getting-started/install.html)
* AWS CLI (required for local execution, can be skipped for Terraform Cloud) - [Installing AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html)

## Initial setup

### Amazon AWS Console

#### Create a new public hosted zone for your subdomain  
It is recommended to use a subdomain E.g. meet.example.com for your videoconferencing needs, so that it would stay separate from your parent domain and any other services such as email, FTP, etc hosted on other subdomains.  

We will use Amazon AWS Route53 for DNS Management of this subdomain. DNS A Records will be created each time fresh infrastructure is created and they will be removed each time the infrastructure is destroyed. For this, we will need to add a public hosted zone for our subdomain (E.g. meet.example.com).

[AWS guide for creating a new hosted zone for your subdomain](https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/dns-routing-traffic-for-subdomains.html#dns-routing-traffic-for-subdomains-creating-hosted-zone)

#### Note nameservers for your public hosted zone  
Once created, your public hosted zone will list a set of nameservers. 

E.g.
 
    ns-1232.awsdns-26.org
    ns-1704.awsdns-21.co.uk
    ns-346.awsdns-43.com
    ns-681.awsdns-21.net

We will need to add these records as NS Records for our subdomain. Jump to: [Add NS Records for your subdomain](#add-ns-records-for-your-subdomain)

#### Create AWS IAM User credentials  
1. Create an IAM User by navigating to Services -> IAM -> Users (left pane) -> Add User.  
2. Provide a name E.g. jitsi-user and select **Programmatic Access** as **Access type**. Click on **Next:Permissions**.  
3. Select **Attach existing policies directly**, then select the checkbox against **AdministratorAccess** and click on **Next:Tags**. Then click **Next:Review**.  
4. Review your settings. If everything looks good, click on **Create User**. This will create a new user.  

Note the **Access key ID** and **Secret access key**. We will use this to configure AWS CLI. Jump to: [Configure AWS CLI](#configure-aws-cli)  

### Domain Provider

#### Add NS Records for your subdomain  
1. Navigate to DNS Management on your domain registrar's portal.  
2. Add a new record for [each nameserver in your public hosted zone](#note-nameservers-for-your-public-hosted-zone) by selecting **NS** as the record type and value as the nameserver address E.g. ns-1323.awsdns-26.org  
3. Save all NS records.  
4. Verify DNS changes with the following command on your terminal/shell  
   `dig NS meet.example.com`

It should return AWS nameservers in response.

### Terraform Cloud

#### Fork this repository  
Fork this repository([https://github.com/mavenik/jitsi-terraform](https://github.com/mavenik/jitsi-terraform)) on Github

#### Create a workspace in Terraform Cloud  
1. [Sign Up or Sign In](https://github.com/mavenik/jitsi-terraform) to Terraform Cloud
2. Create a new workspace by clicking on *+New Workspace*. If you just signed up, you will be taken to workspace creation flow directly.
3. Follow instructions to connect Github and select your fork of this repository.
4. On *Configure Settings* tab of workspace creation, click on *Advanced* and type `aws` as *Terraform Working Directory*
5. Click on *Create Workspace* to finalize workspace creation

#### Configure variables  
1. After a workspace is created, you will be prompted to set variables for this workspace. Click on *Configure variables*.
2. Under *Terraform Variables*, click on *+Add variable* to add variables from the list of variables. You could skip the optional variables. [Click here](#set-variables) to see the list of variables.
3. Under *Environment Variables*, add *AWS_ACCESS_KEY_ID* and *AWS_SECRET_ACCESS_KEY* variables. Use values [obtained after IAM user creation](#create-aws-iam-credentials). Choose the checkbox against *Sensitive* to mask this information.

#### Launching your Jitsi Meet infrastructure  
Within your workspace, click on *Queue Plan* to apply your Terraform configuration. By default, Terraform Cloud will ask for a confirmation before applying changes.

#### Destroying your Jitsi Meet infrastructure
Within your workspace, navigate to *Settings* -> *Destruction and Deletion* and click on *Queue destroy plan*. You will be prompted for a confirmation by typing the workspace name and then again before destroying your infrastructure.

### Terminal

#### Configure AWS CLI
1. On your Terminal/Shell, type  
    `aws configure`  
2. Enter your Access Key ID and Secret Key [obtained after IAM user creation](#create-aws-iam-user-credentials)  
3. Enter default region name. E.g. ap-south-1  

This will create a [default] set of credentials at ~/.aws/credentials

#### Clone this repository  

    git clone https://github.com/mavenik/jitsi-terraform.git
    cd jitsi-terraform/aws

#### Set variables  
1. Copy `terraform.tfvars.example` as  
    `cp terraform.tfvars.example terraform.tfvars`  
2. Refer following table to edit relevant variable values

| Variable | Description | Example |
| -------- |:--------:| -------:|
| aws_profile | (Optional) Name of AWS profile created during `aws configure` | default |
| aws_region | Name of AWS Region where Jitsi server will be deployed | ap-south-1 for (Mumbai) |
| email_address | Email used to generate SSL Certificates via Let's Encrypt | `email@example.com` |
| admin_username | Moderator username for Jitsi. Anonymous meetings are disabled. | `admin@example.com` |
| admin_password | Password for moderator account | Pa$sw0rd |
| enable_ssh_access | (Optional) Enable SSH access via pre-imported SSH key pair. | false |
| ssh_key_name | SSH Key Pair name from AWS Console. Required for debugging via SSH access when `enable_ssh_access` is set. | jitsi_key |
| instance_type | Type of AWS instance for your Jitsi Meet server | m5.xlarge |
| parent_subdomain | Subdomain under which Jitsi Meet will be hosted. | `meet.example.com` |
| subdomain | (Optional) Subdomain under parent subdomain at which Jitsi Meet will be hosted | `dev`, `test`, `stage` |

##### Simulcast Streaming and Recording with Jibri (Optional)

Out of the box, Jitsi only supports streaming via YouTube. Based on this [nifty hack](https://community.jitsi.org/t/stream-to-any-or-multiple-rtmp-destinations-record-simultaneously/51943), it is possible to bypass this limitation and stream to multiple endpoints simultaneously. It is also possible to record and stream at the same time.

The way this is achieved is by introducing an RTMP proxy with Nginx that pushes incoming RTMP stream from Jibri to pre-defined RTMP endpoints.

To stream, start all your streams on streaming services like Facebook, Periscope, YouTube, Twitch, etc to get your stream keys and RTMP endpoints.  
Click on **Start Live Streaming**->**Enter any dummy BUT VALID YouTube stream key E.g. `cafe-dead-face-fab9`**->**Start streaming**  
Jitsi Meet requires a valid YouTube stream key, so we provide a dummy but valid one. Our proxy RTMP server then relays incoming stream to multiple pre-configured endpoints.

All recordings whether streamed or recorded, will be available at `https://my-server.net/recordings/` E.g. `https://511066ad.meet.example.com/recordings/`. This endpoint will require basic auth and use the same credentials as Moderator/Host username and password set using `admin_username` and `admin_password` variables respectively.

| Variable | Description | Default |
| -------- |:-----------:| -------:|
| enable_recording_streaming | Enables recording and streaming capability with Jibri | false |
| recorded_stream_dir | Base directory to save recorded meets. Should be accessible via www-data user or group | /var/www/html/recordings |
| record_all_streaming | Implicitly records every streaming session if enabled | false |
| facebook_stream_key | Stream key for Facebook | Empty string |
| youtube_stream_key | Stream key for YouTube | Empty string |
| twitch_ingest_endpoint | RTMP server or ingest endpoint for Twitch | rtmp://live-sin.twitch.tv/app |
| twitch_stream_key | Stream key for Twitch | Empty string |
| periscope_server_url | RTMP server URL for Periscope/Twitter | rtmp://in.pscp.tv:80/x |
| periscope_stream_key | Stream key for Periscope/Twitter | Empty string |
| rtmp_stream_urls | Generic RTMP URLs | [] |

3. Initialize Terraform
    `terraform init`

#### Creating a new Jitsi Meet server
    
    cd jitsi-terraform/aws
    terraform apply

Type 'yes' when prompted and hit enter.  
This will create the following resources:
1. An Amazon EC2 instance
2. A Route53 DNS A Record with `<UUIDv4>.<parent_subdomain>` or `<subdomain>.<parent_subdomain>` E.g. `511066ad.meet.example.com` or `test.meet.example.com` pointing to the public IPv4 address of newly created Amazon EC2 instance.
3. Security group that acts as a firewall for our EC2 instance. Allows traffic on `UDP 10000` (jitsi-videobridge) `TCP 80` (HTTP) `TCP 443` (HTTPS) and `UDP 53` (DNS). SSH access can optionally be enabled by setting `enable_ssh_access` variable to true.

The command will print address of server host and an HTTPS URL for your Jitsi Meet server. E.g. `https://511066ad.meet.example.com`

**Please note** that Jitsi Meet will take a few minutes to configure itself after `terraform apply` has finished execution. Navigate to your web browser to check if Jitsi Meet was up and running.

#### Destroying your Jitsi Meet infrastructure

    cd jitsi-terraform/aws
    terraform destroy

Type 'yes' when prompted and hit enter.  
This will destroy all resources created in AWS during `terraform apply`.
