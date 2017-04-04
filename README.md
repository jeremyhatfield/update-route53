update-route53
======
Script to update AWS Route 53 record set upon EC2 instance startup.

When restarting an EC2 instance, the public IP address changes causing any Route53 recordsets to become instantly outdated. An easy fix is using Elastic IPs, however [you can only have 5 per region](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/elastic-ip-addresses-eip.html#using-instance-addressing-limit) and need a really good excuse when asking Amazon to increase it.

So, to get around this limitation, with the help of some other articles, I created a procedure that allows each EC2 instance to update their IP address to its corresponding Route53 recordset.
 
### Table of Contents
&nbsp;&nbsp;[Pre-requisites](#1-pre-requisites)  
&nbsp;&nbsp;&nbsp;&nbsp;[IAM Role](#create-aws-iam-role)  
&nbsp;&nbsp;&nbsp;&nbsp;[AWS CLI](#install-the-aws-command-line-interface-aws-cli)  
&nbsp;&nbsp;[Create the Script](#2-create-the-script)  
&nbsp;&nbsp;[Update Script Variables](#3-update-script-aws-variables)  
&nbsp;&nbsp;[Set Script Permissions](#4-set-script-permissions)  
&nbsp;&nbsp;[Add to Runlevels](#5-add-to-runlevels)  


## 1. Pre-requisites

###  Create AWS IAM Role.
Your EC2 instance will need permissions to update a Route53 recordset. To avoid storing keys on the EC2 instance, you will setup a new role in IAM and attach it to your EC2 at launch. (We'll use  the console to create the role.)

  * Within IAM's navigation pane, click on 'Roles.'
  * Click the 'Create New Role' button.
  
![Create New Role Button](/../readme-images/images/1-create-new-role.png?raw=true "Create New Role")

  * Name your new role. I use `route53-editor`. Click Next Step.
  
![Set Role Name](/../readme-images/images/2-set-role-name.png?raw=true "Set Role Name")

  * Select the `Amazon EC2` service role, under the `AWS Service Roles` section.
  
![Select Role Type](/../readme-images/images/3-select-role-type.png?raw=true "Select Role Type")

  * Attach a policy. In the filter, type `route53`. Choose the `AmazonRoute53FullAccess` policy and click Next Step.
  
![Attach Policy](/../readme-images/images/4-attach-policy.png?raw=true "Attach Policy")

  * Review your settings on the next page, and if correct, click the Create Role button.
  
  * Use this new role when launching your EC2 instances. 
  >Note: If you have an existing role that you need to use, just attach the Route53 policy to your existing role.

### Install the AWS Command Line Interface (AWS-CLI)
Install the AWS CLI using [pip](http://docs.aws.amazon.com/cli/latest/userguide/awscli-install-linux.html) or use the [bundled installer](http://docs.aws.amazon.com/cli/latest/userguide/awscli-install-bundle.html).

>Note: I used an AMI from the marketplace and experienced several conflicts when installing `pip`. The bundled installer was much easier in this case.


### Create SymLink
Add a symlink for the AWS-CLI to the `/usr/bin` directory. The home directory is not always available at startup.
```bash
ln -s /home/bitnami/.local/bin/aws /usr/bin/aws
```

## 2. Create the Script
Create your script, `update-route53.sh`, in the `/etc/init.d` directory.

## 3. Update Script AWS Variables
Update the `ZONEID` and `RECORDSET` variables in the script to reflect the Zone and Route53 record you want to change.

## 4. Set Script Permissions
Give the script execute permissions.
```bash
sudo chmod +x /etc/init.d/update-route53.sh
```

## 5. Add to Runlevels
Add the script to the default runlevels so it will be called at runtime.
```bash
sudo update-rc.d update-route53.sh defaults
```
>Note: To remove the script from runlevels...
>```sudo update-rc.d /etc/init.d/update-route53.sh remove```


