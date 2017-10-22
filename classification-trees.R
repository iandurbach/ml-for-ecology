#### Classification trees

# - repeats the regression tree analysis for a binary classification problem

library(tree)

load("data/aloe.RData")
head(aloe_pa)

# ensure outcome is a factor variable
aloe_pa$present <- factor(aloe_pa$present)

# make training, validation, test datasets (60/20/20 split)

# shuffle rows
set.seed(123)
aloe_pa <- aloe_pa[sample(1:nrow(aloe_pa)),]

# get numbers in train, valid, test sets
ntrain <- round(0.6 * nrow(aloe_pa))
nvalid <- round(0.2 * nrow(aloe_pa))
ntest <- nrow(aloe_pa) - ntrain - nvalid

# allocate data to train, valid, test sets
aloe_pa$train_id <- c(rep(1,ntrain), rep(2, nvalid), rep(3, ntest))

#### fit data on train + valid, assess on test

# build tree
tree_aloe_pa <- tree(present ~ Latitude + Longitude + MAP + MAT, 
                  data = subset(aloe_pa, train_id != 3),
                  split = "deviance")

# plot the tree
plot(tree_aloe_pa)
text(tree_aloe_pa, cex=0.9)

# assess training accuracy
pred_aloe_pa <- predict(tree_aloe_pa, type="class")
predtrain <- table(tree_aloe_pa$y, pred_aloe_pa)
predtrain
sum(diag(predtrain))/sum(predtrain) # training accuracy
#? is this good? can compare to size of most common class
max(table(tree_aloe_pa$y))/length(tree_aloe_pa$y)
#? or use "Cohen's kappa"

# function calculating CK from a table of obs x pred
cohens_kappa = function(acc_table){
  p <- apply(acc_table,1,sum) / sum(acc_table)
  q <- apply(acc_table,2,sum) / sum(acc_table)
  p0 <- sum(diag(acc_table)) / sum(acc_table)
  
  kappa <- (p0 - sum(p * q)) / (1 - sum(p * q))
  
  return(kappa)
}
cohens_kappa(predtrain)

# accuracy in test dataset
pred_aloe_pa <- predict(tree_aloe_pa, 
                        type = "class",
                        newdata = subset(aloe_pa, train_id == 3))
observed <- aloe_pa[aloe_pa$train_id == 3, "present"]
predtest <- table(observed, pred_aloe_pa)
predtest
sum(diag(predtest))/sum(predtest) # test accuracy
max(table(observed))/length(observed)
cohens_kappa(predtest) # test kappa

## try again with the overfitted tree

# build tree
tree_aloe_pa <- tree(present ~ Latitude + Longitude + MAP + MAT, 
                  data = subset(aloe_pa, train_id != 3),
                  split = "deviance",
                  mincut = 1, 
                  minsize = 2, 
                  mindev = 0)

# plot the tree
plot(tree_aloe_pa)
text(tree_aloe_pa, cex=0.9)

# assess training accuracy
pred_aloe_pa <- predict(tree_aloe_pa, type="class")
predtrain <- table(tree_aloe_pa$y, pred_aloe_pa)
predtrain
sum(diag(predtrain))/sum(predtrain) # training accuracy
max(table(tree_aloe_pa$y))/length(tree_aloe_pa$y) 
cohens_kappa(predtrain) # training kappa

# accuracy in test dataset
pred_aloe_pa <- predict(tree_aloe_pa, 
                        type = "class",
                        newdata = subset(aloe_pa, train_id == 3))
observed <- aloe_pa[aloe_pa$train_id == 3, "present"]
predtest <- table(observed, pred_aloe_pa)
predtest
sum(diag(predtest))/sum(predtest) # test accuracy
max(table(observed))/length(observed)
cohens_kappa(predtest) # test kappa
# training accuracy >> test accuracy => over-fitting, but still better
# than previous tree!
