update-route53
======
Script to update AWS Route 53 record set upon EC2 instance startup.

### 1. Create AWS IAM Role.
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

### 2. Install the AWS Command Line Interface (AWS-CLI)
Install the AWS CLI using [pip](http://docs.aws.amazon.com/cli/latest/userguide/awscli-install-linux.html) or use the [bundled installer](http://docs.aws.amazon.com/cli/latest/userguide/awscli-install-bundle.html).

>Note: I used an AMI from the marketplace and experienced several conflicts when installing `pip`. The bundled installer was much easier in this case.


### 3. Create SymLink
Add a symlink for the AWS-CLI to the `/usr/bin` directory.
```bash
ln -s /home/bitnami/.local/bin/aws /usr/bin/aws
```

### 4. Create the Script
Create your script, `update-route53.sh`, in the `/etc/init.d` directory.

### 5. Update Script AWS Variables
Update the `ZONEID` and `RECORDSET` variables in the script to reflect the Zone and Route53 record you want to change.

### 6. Set Script Permissions
Give the script execute permissions.
```bash
sudo chmod +x /etc/init.d/update-route53.sh
```

### 7. Add to Runlevels
Add the script to the default runlevels so it will be called at runtime.
```bash
sudo update-rc.d update-route53.sh defaults
```
>Note: To remove the script from runlevels...
>```sudo update-rc.d /etc/init.d/update-route53.sh remove```


