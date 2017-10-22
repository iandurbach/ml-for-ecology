#### Regression trees II: Validation

# - dividing your data into training, validation, and test sets
# - model validation (accuracy on test set)
# - overfitting

library(tree)

load("data/aloe.RData")
head(aloe)

# make training, validation, test datasets (60/20/20 split)

# shuffle rows
set.seed(123)
aloe <- aloe[sample(1:nrow(aloe)),]

# get numbers in train, valid, test sets
ntrain <- round(0.6 * nrow(aloe))
nvalid <- round(0.2 * nrow(aloe))
ntest <- nrow(aloe) - ntrain - nvalid

# allocate data to train, valid, test sets
aloe$train_id <- c(rep(1,ntrain), rep(2, nvalid), rep(3, ntest))

#### fit data on train + valid, assess on test

# since we're not doing any fine tuning (e.g. pruning), we don't need
# a separate validation set (see later)

# build tree
tree_aloe <- tree(log(tottrees) ~ Latitude + Longitude , 
                  data = subset(aloe, train_id != 3),
                  split = "deviance")

# plot the tree
plot(tree_aloe)
text(tree_aloe, cex=0.9)

# assess training accuracy
pred_aloe <- predict(tree_aloe)
mean((tree_aloe$y - pred_aloe)^2)

# assess *test* accuracy
pred_aloe <- predict(tree_aloe, newdata = subset(aloe, train_id == 3))
observed <- log(aloe[aloe$train_id == 3, "tottrees"])
mean((observed - pred_aloe)^2)

## try again with the overfitted tree

# build tree
tree_aloe <- tree(log(tottrees) ~ Latitude + Longitude , 
                  data = subset(aloe, train_id != 3),
                  split = "deviance",
                  mincut = 1, 
                  minsize = 2, 
                  mindev = 0)

# plot the tree
plot(tree_aloe)
text(tree_aloe, cex=0.9)

# assess training accuracy
pred_aloe <- predict(tree_aloe)
mean((tree_aloe$y - pred_aloe)^2)

# assess *test* accuracy
pred_aloe <- predict(tree_aloe, newdata = subset(aloe, train_id == 3))
observed <- log(aloe[aloe$train_id == 3, "tottrees"])
mean((observed - pred_aloe)^2)

