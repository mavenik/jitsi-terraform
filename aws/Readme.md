# Jitsi setup on Amazon AWS

## How it works

* Creates an EC2 instance with a cloud-init script to install and configure Jitsi Meet.  
* Creates a security group that acts as firewall to regulate web traffic to your Jitsi Meet instance.  
* Creates a Route53 A Record under a previously hosted subdomain that points to this EC2 instance. E.g. 511066ad.meet.example.com  
* Jitsi Meet server can be accessed at https://<UUIDv4>.<hosted-subdomain> E.g. https://511066ad.meet.example.com  
* Anonymous meetings cannot be initiated on this setup. One needs a moderator username and password to be able to initiate meets.  

[Prerequisites](#prerequisites)  

[Initial Setup](#initial-setup)

* [Amazon AWS Console](#amazon-aws-console)
 * [Create a new public hosted zone](#create-a-new-public-hosted-zone-for-your-subdomain)
 * [Note nameservers](#note-nameservers-for-your-public-hosted-zone)
 * [Create AWS IAM User credentials](#create-aws-iam-user-credentials)

* [Domain Provider](#domain-provider)
 * [Add NS Records for your subdomain](#add-ns-records-for-your-subdomain)

* [Terminal](#terminal)
 * [Configure AWS CLI](#configure-aws-cli)
 * [Clone this repository](#clone-this-repository)
 * [Set variables](#set-variables)

* [Creating and destroying your infrastructure](#creating-and-destroying-your-infrastructure)
 * [Creating your Jitsi Meet Server](#creating-your-jitsi-meet-server)
 * [Destroying your Jitsi Meet Server](#destroying-your-jitsi-meet-server)

## Prerequisites
* Registered domain and access to DNS Management
* Amazon AWS Account - [Creating an AWS Account](https://aws.amazon.com/premiumsupport/knowledge-center/create-and-activate-aws-account/)
* Terraform - [Installing Terraform](https://learn.hashicorp.com/terraform/getting-started/install.html)
* AWS CLI - [Installing AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html)

## Initial setup
-----------------

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
1. Copy `variables.tf.example` as  
    `cp variables.tf.example variables.tf`  
2. Refer following table to edit relevant variable values against `default = `

| Variable | Function | Example |
| -------- |:--------:| -------:|
| aws_profile | Name of AWS profile created during `aws configure` | default |
| aws_region | Name of AWS Region where Jitsi server will be deployed | ap-south-1 for (Mumbai) |
| email_address | Email used to generate SSL Certificates via Let's Encrypt | email@example.com |
| admin_username | Moderator username for Jitsi. Anonymous meetings are disabled. | admin@example.com |
| admin_password | Password for moderator account | Pa$sw0rd |
| ssh_key_name | (Optional) SSH Key Pair name from AWS Console. Required for debugging via SSH access. | jitsi_key |
| instance_type | Type of AWS instance for your Jitsi Meet server | m5.xlarge |
| parent_subdomain | Subdomain under which Jitsi Meet will be hosted. | meet.example.com |

3. Initialize Terraform
    `terraform init`

## Creating and destroying your infrastructure
-----------------------------------------------

#### Creating a new Jitsi Meet server
    
    cd jitsi-terraform/aws
    terraform apply

Type 'yes' when prompted and hit enter.  
This will create the following resources:
1. An Amazon EC2 instance
2. A Route53 DNS A Record with `<UUIDv4>.<parent_subdomain>` E.g. `511066ad.meet.example.com` pointing to the public IPv4 address of newly created Amazon EC2 instance.
3. Security group that acts as a firewall for our EC2 instance. Allows traffic on `UDP 10000` (jitsi-videobridge) `TCP 80` (HTTP) `TCP 443` (HTTPS) and `UDP 53` (DNS). SSH access can optionally be enabled by uncommenting relevant lines in `main.tf`, but is not enabled by default.

The command will print address of server host and an HTTPS URL for your Jitsi Meet server. E.g. `https://511066ad.meet.example.com`

**Please note** that Jitsi Meet will take a few minutes to configure itself after `terraform apply` has finished execution. Navigate to your web browser to check if Jitsi Meet was up and running.

#### Destroying your Jitsi Meet infrastructure

    cd jitsi-terraform/aws
    terraform destroy

Type 'yes' when prompted and hit enter.  
This will destroy all resources created in AWS during `terraform apply`.
