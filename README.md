# Rearc-Quest 

### nodejs/
This directory contains the application files for the quest.

### Application Container
The included dockerfile uses the latest official node.js image to run the Quest app. The application is copied to the working 
directory, port 3000 is opened, and node.js is started. 

To build and register the app container with a Linux or Mac, perform the following steps (Note: awscli is required):
- `aws ecr get-login-password --region us-east-2 | docker login --username AWS --password-stdin 670620370144.dkr.ecr.us-east-2.amazonaws.com`
- `docker build -t rearc-quest ./`
- `docker tag rearc-quest 670620370144.dkr.ecr.us-east-2.amazonaws.com/quest:latest`
- `docker push 670620370144.dkr.ecr.us-east-2.amazonaws.com/quest:latest`

Now the container image has been uploaded to AWS ECR and is ready to be used.

### AWS Configuration with Terraform
#### terraform/variables.tf
This file contains a few variables that are consumed by Terraform. This file provides a convenient place to adjust these variables as needed. 

- `subnet_cidrs`: Defines the IP space for the AZ subnets.
- `secret_word_key`: Defines the environment variable name for the `SECRET_WORD`
- `secret_word_value`: Defines the environment variable value for the `SECRET_WORD`

#### terraform/provider.tf
Basic file to set up a local backend for Terraform and configures the AWS provider for use with US-East-2. 

#### terraform/vpc.tf
This file contains the necessary resources to configure our VPC for use. The main cidr block for our network is defined as 10.0.0.16.
An Internet Gateway is attached to the VPC to allow deployed resources to communicate on the public internet.
A route table is created and attached to the VPC. Default routes are added to the route table. 3 /24 subnets are created for each of the availability zones in US-East-2. Our Quest app container will be added to one of these subnets.

#### terraform/quest.tf
##### Security Groups
A security group is created for use with our application. This SG will allow our app to send and recieve to it's clients.
Allows inbound ports 80/TCP, 443/TCP, 3000/TCP from any source address. 
Allows all outbound traffic on any port using any protocol destined for the default gateway.   

##### AWS Load Balancer
A few resources are needed to configure an Application Load Balancer for this task:
- The load balancer itself `quest_lb`.
- Two listeners which will accept connections on:
    - `quest_listener_80`: HTTP
    - `quest_listener_443`: HTTPS
3. A target group, `quest_trgt_grp`, that will receive forwarded connections on 3000/TCP.

##### Elastic Container Service
Using the Elastic Container Serivce with Fargate for the Quest is ideal as it will allow us to only use the resources needed to
run the container, and we avoid the need to configure and run docker on a self-managed EC2 Instance.

- An ECS Cluster is defined as `quest_cluster`
- An ECS Task is defined for our app as `quest_task`:
    - An execution role is assigned
    - CPU and Memory requirements for the task are set.
    - The application container to use is defined and the `SECRET_WORD` environment variable is passed in.
- An ECS Service created as `quest_service` which configures our Image to be run in FARGATE.
- Load balancer targets are associated with the ECS Service. 
