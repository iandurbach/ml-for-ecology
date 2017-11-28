#### Classification trees

library(tree)
source("utils.R")

load("data/frogs.RData")
head(frogs)

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
tree_frogs <- tree(Family ~ ., 
                     data = subset(frogs, 
                                   train_id != 3, 
                                   select = -c(Genus, Species, RecordID, train_id)),
                     split = "deviance")

# plot the tree
plot(tree_frogs)
text(tree_frogs, cex=0.9)

# assess training accuracy
pred_frogs <- predict(tree_frogs, type="class")
predtrain <- table(tree_frogs$y, pred_frogs)
predtrain
sum(diag(predtrain))/sum(predtrain) # training accuracy
#? is this good? can compare to size of most common class
max(table(tree_frogs$y))/length(tree_frogs$y)
#? or use "Cohen's kappa"

# accuracy in test dataset
pred_frogs <- predict(tree_frogs, 
                        type = "class",
                        newdata = subset(frogs, train_id == 3))
observed <- frogs[frogs$train_id == 3, "Family"]
predtest <- table(observed, pred_frogs)
predtest
sum(diag(predtest))/sum(predtest) # test accuracy
max(table(observed))/length(observed)
cohens_kappa(predtest) # test kappa
