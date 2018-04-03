# Machine learning for ecology

This repo contains material for the "Machine learning for ecology" workshop. The workshop aims to give a practical introduction to the use of machine learning methods for classification problems in ecology. 

It is aimed at ecologists doing some form of classification - either manually or model-based - in their own research work, especially those classifying images or audio/acoustic data. 

The workshop covers two machine learning methodologies: tree-based methods, and neural networks. All analysis will be done using R, using existing packages for tree-based methods (rpart, randomForest, gbm) and neural networks (keras).

Previous workshops:
* 23-25 October 2017 @ Centre for Ecological Sciences, Indian Institute of Science, Bangalore
* 20-22 November 2017 @ African Institute for Mathematical Sciences, Cape Town

#### Setting up

The easy option is to just download the repo as a .zip file and keep an eye on the repo for updates (you need to download a fresh .zip for each update). A better option is to make your own repository containing the workshop materials, explained below. 

1. Fork this repo to your own GitHub account. 
2. You can now clone the repo to your local machine. From *your* GitHub account, get the repo's URL by clicking the "Clone or download" button as before.
3. Start a new R project using version control (*File > New Project > Version Control > Git*). Enter the URL you copied in the previous step. You should see the contents of the target repo in your R project.
4. You can now work on the project and commit and push any changes. If you're not interested in developments in the target repo, or in collaborating by contributing changes to the target repo, then you don't need the following steps. Often though, you will want to keep your forked repo up-to-date with the target repo (say to keep track of new developments). In that case, read on.
5. To keep a forked repo up-to-date with the target repo, you first need to configure a remote that points from your repo to the "upstream" target repo. First check the current remote repository for your fork by opening the terminal, browsing to the project directory and typing `git remote -v`. You should see the URL of your repo.
6. Add the upstream target repo by typing `git remote add upstream https://github.com/ORIGINAL_OWNER/ORIGINAL_REPOSITORY.git`. Type `git remote -v` again to check that it has been added.
7. You can now pull any updates from the target repo into your local repo (fork) with `git pull upstream master`.
