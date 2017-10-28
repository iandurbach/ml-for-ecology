# Creating your own deep learning R server from a prebuilt image

This section assumes that someone else has built an Amazon Machine Image (AMI) and has shared this with you. It shows you how to set up your own Amazon EC2 instance - a web server - from this image.

In order to share an AMI with you, you will need to already have an [Amazon Web Services](https://aws.amazon.com/free) account, so I also assume you already have one of these.

#### Step 1
Go to the [AWS Console](https://aws.amazon.com/console/) an log in to AWS. In the top right corner of the screen set your region to the region in which the AMI was set up (I use *EU (Ireland)*, so if you are using an image I have shared with you, select this region).

#### Step 2
Click on the orange box in the top left of the screen to bring up the AWS services dashboard. Find and select "EC2". Select "Images" from the left-hand menu.

#### Step 3
* Step 3.1: Choose an Amazon Machine Image (AMI): Select the check box of the AMI you want to you and click the "Launch" button.

* Step 3.2: Choose an Instance Type: scroll down, tick the box for the instance type you want ("t2.micro" is the free-tier option, while "t2.small" and "t2.medium" are good cheaper options costing under $0.05/hour). Click "Next: Configure Instance Details".

> For some kinds of servers (e.g. the "p2" instances used for GPU computing) you need to make a special request for access before you can launch a instance. Beware though, these are expensive! See [here](https://aws.amazon.com/blogs/aws/increasing-your/) for more details 

* Step 3.3: Configure Instance Details: leave everything as default here and click "Next: Add Storage".

* Step 3.4: Add Storage: this step depends on what you'll be using the instance for. Most instances comes with a root volume of 50Gb, which is more than enough for our needs. Note that you pay for storage space regardless of whether you use it or not, at a rate of about 10 USc per Gb per month. Costs are prorated by the number of hours you have the storage available for i.e. you don't pay for a month if you terminate an instance after a few days. Recommended step here is to leave as is and click "Next: Add tags"

* Step 3.5: Add Tags: Select "click to add a Name tag". The "Key" box should say *Name*. Add a descriptive label for your instance in the "Value" text box. Then click "Next: Configure Security Group"

* Step 3.6: Configure Security Group: This step is quite important as it specifies the IP addresses that can access your instance (bearing in mind you are paying for the instance). We'll add two rules: 
    
    1. Set "Type" to *SSH*, "Protocol" to *TCP*, "Port Range" to *22*. Change "Source" to *My IP* (the adjacent box should change to reflect your IP address) and give the group a "Description" like "SSH for Ian". This rule is so that we can use SSH to access the instance. Once you're done, click "Add rule".
    2. Set "Type" to *Custom TCP*, "Protocol" to *TCP*, "Port Range" to *8888*. Change "Source" to *My IP* and give it a description like "Jupyter Notebook for Ian". As the name suggests this rule is so that we can use Jupyter notebooks on our instance. 
 
If you are going to access the instance from different IP addresses (e.g. home and office networks) you will need to add a rule for each of these (you can add or modify security at any stage; see point 7 below). Click "Review and Launch" and then "Launch". A window will come up "Select an existing key pair or create a new key pair".

#### Step 4
In this step you create a private key that will allow you to log in to the instance securely later on. Select "Create a new key pair" and give it a name in the "Key pair name" text box. Note the advice to "Store it in a secure and accessible location"! Then download the key pair and save it somewhere. If you create new instances later on you can use the same key pair (then select "Choose an existing key pair" when you start this step). Click "Launch instances".

#### Step 5
You should get a message saying "Your instances are now launching". Note the box below "Get notified of estimated charges". Now would be a good time to set up a billing alert! Click "View instances" at the bottom of the screen.

#### Step 6
You will then be taken to the "Instances" dashboard, which you can always access by selecting "Instances" from the menu on the left hand side of the screen. The instance you just created will probably say "Initializing", which refers to some checks that are done when an instance is started. These checks can take some time to complete (a few minutes). Wait until the "Status Checks" column says *2/2 checks...*, which means the checks are complete. 

> The Instance dashboard is your "main" page on EC2. It shows you which of your instances are running (green circle, labelled *running*) and which are available but not running (red circle, labelled *stopped*). The running instances are the expensive ones. Do not leave an instance running unless you need to! We need to leave the instance we just created running while we add some software and do the rest of this notebook, but afterwards, remember to come back to this screen and stop the instance! You stop an instance by selecting the box next to its name, clicking the "Actions" button and choosing "Instance state" and "Stop". When you want to start the instance again, do the same thing but choose "Start". When you are totally done with the instance, do the same but choose "Terminate". Once you have terminated an instance you will not be charged anything for it, but of course if you want to do anything you will need to create a whole new instance from scratch. It really boils down to how much you value your time! If the instance you just created has a blank entry in the "Name" box enter a name there.

#### Step 7
While you wait for the checks to complete, select the "Description" tab towards the bottom of the screen and scroll down until you see "Security groups". This is where you can add more security groups if you are using multiple IP addresses to access the instance (see point 6, step 3). To add a new rule, select the security group (should be something like `launch-wizard-X`), then select the "Inbound" tab, click "Edit" and "Add rule". You will see the set of security options you encountered previously.

#### Step 8
Once the checks are complete, tick the box next to your instance if it is not already ticked. Under the "Description" tab , identify the "IPv4 Public IP" of your instance. Copy this to the clipboard. Then open the terminal and browse to where you saved your private key (.pem) file in Step 4. Now type
```
chmod 600 <name-of-private-key-file>
```
and then 
```
ssh ec2-user@<ip-address> -oIdentityFile=<name-of-private-key-file>
```
Where `<ip-address>` is the IPv4 Public IP you just copied. You'll get a warning that "The authenticity of host `<ip-address>` can't be established" and asking you if you want to continue. Type "yes". You should now see something like:
```
[ec2-user@ip-193-54-61-203 ~]$
```
which means you are up and running and are now working on the instance! 

#### Step 9 
Launch jupyter notebook
```
jupyter notebook
```
Copy the URL that Jupyter provides in the terminal after launching, and paste it into your browser. Replace "localhost" with the instance's IPv4 Public IP address, which you can find under the "Description" tab on the Instances dashboard. The final URL will look something like
```
http://<aws-IPv4-address>:8888/?token=3fvf4cb0fd52a31c2ed4f2c6e521372bad435bba608307dd6d
```

## Launching the instance

The steps above only need to be done **once**. If you've done the steps above you're already logged into the server and all the software you need is installed, so you don't need to do the following *this time*. But once you've stopped the instance and want to restart it, you need to do the following. 

1. SSH into AWS server
```
ssh ec2-user@<ip-address> -oIdentityFile=<name-of-private-key-file>
```
2. Launch jupyter notebook
```
jupyter notebook
```
3. Copy the URL that Jupyter provides in the terminal after launching, and paste it into your browser. Replace "localhost" with the instance's IPv4 Public IP address, which you can find under the "Description" tab on the Instances dashboard. The final URL will look something like
```
http://<aws-IPv4-address>:8888/?token=3fvf4cb0fd52a31c2ed4f2c6e521372bad435bba608307dd6d
```

