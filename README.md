# INTEGRATING-GITHUB-JENKINS-AWS-WITH-TERRAFORM

## TASK DESCRIPTION:

   #### 1. Create the key and security group which allow the port 80.
   #### 2. Launch EC2 instance.
   #### 3. Developer have uploded the code into github repo also the repo has some images.
   #### 4.   Copy the github repo code into /var/www/html
   #### 5.   Create S3 bucket, and copy/deploy the images from github repo into the s3 bucket and change the permission to public 
   #### 6.   Create a Cloudfront using s3 bucket(which contains images) and use the Cloudfront URL to update in code in /var/www/html
   #### 7.   Create snapshot of ebs
   #### 8. Those who are familiar with jenkins or are in devops AL have to integrate jenkins in this task wherever you feel can be integrated
   
   ## TERRAFORM 

### INFRASTRUCTURE AS A CODE

Write Infrastructure as Code
Terraform users define infrastructure in a simple, human-readable configuration language called HCL (HashiCorp Configuration Language). Users can write unique HCL configuration files or borrow existing templates from the public module registry.

### Manage Configuration Files in VCS

Most users will store their configuration files in a version control system (VCS) repository and connect that repository to a Terraform Cloud workspace. With that connection in place, users can borrow best practices from software engineering to version and iterate on infrastructure as code, using VCS and Terraform Cloud as a delivery pipeline for infrastructure.

### Automate Provisioning

When you push changes to a connected VCS repository, Terraform Cloud will automatically trigger a plan in any workspace connected to that repository. This plan can be reviewed for safety and accuracy in the Terraform UI, then it can be applied to provision the specified infrastructure.

### TERRAFORM COMMANDS:
     
 1. The `terraform init` command is used to initialize a working directory containing Terraform configuration files. This is the first        command that should be run after writing a new Terraform configuration or cloning an existing one from version control. It is safe       to run this command multiple times. 
 2. The `terraform plan`command is used to create an execution plan. Terraform performs a refresh, unless explicitly disabled, and then     determines what actions are necessary to achieve the desired state specified in the configuration files.
   
 3. The `terraform apply` command is used to apply the changes required to reach the desired state of the configuration, or the pre-          determined set of actions generated by a `terraform plan` execution plan.
  
 4. The `terraform destroy` command is used to destroy the Terraform-managed infrastructure.
  
 5. The `terraform validate` command validates the configuration files in a directory, referring only to the configuration and not            accessing any remote services such as remote state, provider APIs, etc.
 
 6. The `terraform taint` command manually marks a Terraform-managed resource as tainted, forcing it to be destroyed and recreated on       the next apply.
  
 
 
 NOTE: If `-auto-approve` is set for apply and destroy , then the confirmation will not be shown.
 
 
I have used Windows as the slave but docker would be the efficient slave as it is dynamic and faster .
So some commands of Windows which i have used  are as under:
