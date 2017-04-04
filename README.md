update-route53
======
Script to update AWS Route 53 record set upon EC2 instance startup.

### 1. Create AWS IAM Role.
Your EC2 instance will need permissions to update a Route53 recordset. To avoid storing keys on the EC2 instance, you will setup a new role in IAM. (We'll use  the console to create the role.)

  1. Within IAM's navigation pane, click on 'Roles.'
  2. Click the 'Create New Role' button.
![Create New Role Button](/../readme-images/images/1-create-new-role.png?raw=true "Create New Role")


### 2. Install PIP and AWS-CLI


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


