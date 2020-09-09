# AWS DevOps Exercises

[Adapted from this checklist - you can see my progress down below](https://www.reddit.com/r/sysadmin/comments/8inzn5/so_you_want_to_learn_aws_aka_how_do_i_learn_to_be/)

## Current Status
Requirements:
- Vagrant
- Ansible
- Packer
- Terraform
- AWS CLI credentials & Github credentials already in your environment

### First Steps
Set the name of your project directory in Github in `ansible/group_vars/all`, `test/variables.tf`, & `prod/variables.tf`.

### Dev Environment
To spin up a dev environment, enter the `dev` directory and use `vagrant up`.

This will call vagrant to create a virtual machine, which will then call ansible to provision it with the necessary packages and sync it to the local working directory specified in the global vars. Vagrant will then expose the webpage's port on [localhost:1234](localhost:1234).

Upon changing files in the project directory, run `vagrant provision --provision-with rsync` to only update the project files or setup a task runner to do the same (I'm using Grunt).

This configuration allows you to write code in your comfortable primary environment, but test and evaluate in a production-equivalent environment.

### Test Environment
To spin up a test environment, enter the `test` directory, run `packer build build-test-environment.json`, then run `terraform init`, then run `terraform apply`.

This will call packer to create an AMI based on the ansible playbook in the default branch of your github repo and leave it in AWS. Terrform will then deploy the image to an instance and output the automatically generated IP address to access for testing.

Don't forget to `terraform destroy` if you don't want to incur charges for the test environment. You may also want to delete the AMI and snapshot created, although they don't cost very much to host.

### Prod Environment
To spin up a test environment, enter the `prod` directory, run `packer build build-prod-environment.json`, then run `terraform init`, then run `terraform apply`.

This will call packer to create an AMI based on the ansible playbook in the default branch of your github repo and leave it in AWS. Terrform will then deploy the image to an instance and associate a pre-existing elastic IP named `{{ project_name }}-prod`. It is up to you to have DNS setup to point your prod URL to that IP already.

## Roadmap
### Introduction

So many people struggle with where to get started with AWS and cloud technologies in general. There is popular "How do I learn to be a Linux admin?" post that inspired me to write an equivalent for cloud technologies. This post serves as a guide of goals to grow from basic AWS knowledge to understanding and deploying complex architectures in an automated way. Feel free to pick up where you feel relevant based on prior experience.

#### Assumptions:

  - You have basic-to-moderate Linux systems administration skills
  - You are at least familiar with programming/scripting. You don't need to be a whiz but you should have some decent hands-on experience automating and programming.
  - You are willing to dedicate the time to overcome complex issues.
  - You have an AWS Account and a marginal amount of money to spend improving your skills.

#### How to use this guide:

  - This is not a step by step how-to guide.
  - You should take each goal and "figure it out". I have hints to guide you in the right direction.
  - Google is your friend. AWS Documentation is your friend. Stack Overflow is your friend.
  - Find out and implement the "right way", not the quick way. Ok, maybe do the quick way first then refactor to the right way before moving on.
  - Shut down or de-provision as much as you can between learning sessions. You should be able to do everything in this guide for literally less than $50 using the AWS Free Tier. Rebuilding often will reinforce concepts anyway.
  - Skip ahead and read the Cost Analysis and Automation sections and have them in the back of your mind as you work through the goals.
  - Lastly, just get hands on, no better time to start then NOW.

### Project Overview

This is NOT a guide on how to develop websites on AWS. This uses a website as an excuse to use all the technologies AWS puts at your fingertips. The concepts you will learn going through these exercises apply all over AWS.

This guide takes you through a maturity process from the most basic webpage to an extremely cheap scalable web application. The small app you will build does not matter. It can do anything you want, just keep it simple.

Need an idea? Here: Fortune-of-the-Day - Display a random fortune each page load, have a box at the bottom and a submit button to add a new fortune to the random fortune list.

### Account Basics

  - [x] Create an IAM user for your personal use.
  - [x] Set up MFA for your root user, turn off all root user API keys.
  - [x] Set up Billing Alerts for anything over a few dollars.
  - [x] Configure the AWS CLI for your user using API credentials.
  - [x] Checkpoint: You can use the AWS CLI to interrogate information about your AWS account.

### Web Hosting Basics

  - [x] Deploy a EC2 VM and host a simple static "Fortune-of-the-Day Coming Soon" web page.
  - [x] Take a snapshot of your VM, delete the VM, and deploy a new one from the snapshot. Basically disk backup + disk restore.
  - [x] Checkpoint: You can view a simple HTML page served from your EC2 instance.

### Auto Scaling

  - [x] Create an AMI from that VM and put it in an autoscaling group so one VM always exists.
  - [x] Put a Elastic Load Balancer infront of that VM and load balance between two Availability Zones (one EC2 in each AZ).
  - [x] Checkpoint: You can view a simple HTML page served from both of your EC2 instances. You can turn one off and your website is still accessible.

### Automation Checkpoint #1
  - [x] Use Ansible + Vagrant to spin up local dev boxes
  - [x] Use Ansible and Packer to build AMIs and Terraform to deploy test and prod boxes
  - [x] Some way to tear eveything down, too
  - [x] Update README to explain the current status

### External Data

  - [ ] Create a DynamoDB table and experiment with loading and retrieving data manually, then do the same via a script on your local machine.
  - [ ] Refactor your static page into your Fortune-of-the-Day website (Node, PHP, Python, whatever) which reads/updates a list of fortunes in the AWS DynamoDB table. (Hint: EC2 Instance Role)
  - [ ] Checkpoint: Your HA/AutoScaled website can now load/save data to a database between users and sessions

### Web Hosting Platform-as-a-Service

  - [ ] Retire that simple website and re-deploy it on Elastic Beanstalk.
  - [ ] Create a S3 Static Website Bucket, upload some sample static pages/files/images. Add those assets to your Elastic Beanstalk website.
  - [ ] Register a domain (or re-use and existing one). Set Route53 as the Nameservers and use Route53 for DNS. Make www.yourdomain.com go to your Elastic Beanstalk. Make static.yourdomain.com serve data from the S3 bucket.
  - [ ] Enable SSL for your Static S3 Website. This isn't exactly trivial. (Hint: CloudFront + ACM)
  - [ ] Enable SSL for your Elastic Beanstalk Website.
  - [ ] Checkpoint: Your HA/AutoScaled website now serves all data over HTTPS. The same as before, except you don't have to manage the servers, web server software, website deployment, or the load balancer.

### Microservices

  - [ ] Refactor your EB website into ONLY providing an API. It should only have a POST/GET to update/retrieve that specific data from DynamoDB. Bonus: Make it a simple REST API. Get rid of www.yourdomain.com and serve this EB as api.yourdomain.com
  - [ ] Move most of the UI piece of your EB website into your Static S3 Website and use Javascript/whatever to retrieve the data from your api.yourdomain.com URL on page load. Send data to the EB URL to have it update the DynamoDB. Get rid of static.yourdomain.com and change your S3 bucket to serve from www.yourdomain.com.
  - [ ] Checkpoint: Your EB deployment is now only a structured way to retrieve data from your database. All of your UI and application logic is served from the S3 Bucket (via CloudFront). You can support many more users since you're no longer using expensive servers to serve your website's static data.
- 
### Serverless

  - [ ] Write a AWS Lambda function to email you a list of all of the Fortunes in the DynamoDB table every night. Implement Least Privilege security for the Lambda Role. (Hint: Lambda using Python 3, Boto3, Amazon SES, scheduled with CloudWatch)
  - [ ] Refactor the above app into a Serverless app. This is where it get's a little more abstract and you'll have to do a lot of research, experimentation on your own.
      - [ ] The architecture: Static S3 Website Front-End calls API Gateway which executes a Lambda Function which reads/updates data in the DyanmoDB table.
      - [ ] Use your SSL enabled bucket as the primary domain landing page with static content.
      - [ ] Create an AWS API Gateway, use it to forward HTTP requests to an AWS Lambda function that queries the same data from DynamoDB as your EB Microservice.
      - [ ] Your S3 static content should make Javascript calls to the API Gateway and then update the page with the retrieved data.
      - [ ] Once you have the "Get Fortune" API Gateway + Lambda working, do the "New Fortune" API.
  - [ ] Checkpoint: Your API Gateway and S3 Bucket are fronted by CloudFront with SSL. You have no EC2 instances deployed. All work is done by AWS services and billed as consumed.

### Cost Analysis

  - [ ] Explore the AWS pricing models and see how pricing is structured for the services you've used.
  - [ ] Answer the following for each of the main architectures you built:
      - [ ] Roughly how much would this have costed for a month?
      - [ ] How would I scale this architecture and how would my costs change?
  - [ ] Architectures
      - [ ] Basic Web Hosting: HA EC2 Instances Serving Static Web Page behind ELB
      - [ ] Microservices: Elastic Beanstalk SSL Website for only API + S3 Static Website for all static content + DynamoDB Table + Route53 + CloudFront SSL
      - [ ] Serverless: Serverless Website using API Gateway + Lambda Functions + DynamoDB + Route53 + CloudFront SSL + S3 Static Website for all static content

### Automation

!!! This is REALLY important !!!

These technologies are the most powerful when they're automated. You can make a Development environment in minutes and experiment and throw it away without a thought. This stuff isn't easy, but it's where the really skilled people excel.
Automate the deployment of the architectures above. Use whatever tool you want. The popular ones are AWS CloudFormation or Teraform. Store your code in AWS CodeCommit or on GitHub. Yes, you can automate the deployment of ALL of the above with native AWS tools.
I suggest when you get each app-related section of the done by hand you go back and automate the provisioning of the infrastructure. For example, automate the provisioning of your EC2 instance. Automate the creation of your S3 Bucket with Static Website Hosting enabled, etc. This is not easy, but it is very rewarding when you see it work.

### Continuous Delivery

As you become more familiar with Automating deployments you should explore and implement a Continuous Delivery pipeline.

Develop a CI/CD pipeline to automatically update a dev deployment of your infrastructure when new code is published, and then build a workflow to update the production version if approved. Travis CI is a decent SaaS tool, Jenkins has a huge following too, if you want to stick with AWS-specific technologies you'll be looking at CodePipeline.

### Miscellaneous / Bonus

These didn't fit in nicely anywhere but are important AWS topics you should also explore:

 - IAM: You should really learn how to create complex IAM Policies. You would have had to do basic roles+policies for for the EC2 Instance Role and Lambda  Execution Role, but there are many advanced features.
 - Networking: Create a new VPC from scratch with multiple subnets (you'll learn a LOT of networking concepts), once that is working create another VPC and peer them together. Get a VM in each subnet to talk to eachother using only their private IP addresses.
 - KMS: Go back and redo the early EC2 instance goals but enable encryption on the disk volumes. Learn how to encrypt an AMI.
