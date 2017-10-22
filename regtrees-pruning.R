#### Regression trees III: Pruning

# - pruning with a validation set
# - pruning with k-fold cross validation

library(tree)

load("data/aloe.RData")
head(aloe)

#? now we want to choose a value of alpha that will optimally "prune"
#? the tree. We shouldn't use the training data to do this - why?

# build the tree *on the training data only*
tree_aloe <- tree(log(tottrees) ~ Latitude + Longitude + MAP + MAT, 
                  data = subset(aloe, train_id == 1),
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

# choosing alpha for pruning using the validation data
tree_cv2 <- prune.tree(tree_aloe, newdata = subset(aloe, train_id == 2))
plot(tree_cv2)

### see how the tree varies with values of k 

# get and plot pruned tree
pruned_aloe <- prune.tree(tree_aloe, k = 50)
plot(pruned_aloe)
text(pruned_aloe)

# assess *test* accuracy
pred_aloe <- predict(pruned_aloe, newdata = subset(aloe, train_id == 3))
observed <- log(aloe[aloe$train_id == 3, "tottrees"])
mean((observed - pred_aloe)^2)


#########################################################

### since we don't have a lot of data, choosing alpha with the 
### validation set isn't the best idea. We can use pool the training 
### and validation sets and then use k-fold CV on this pooled data.

# build the tree on the *training and validation data*
tree_aloe <- tree(log(tottrees) ~ Latitude + Longitude + MAP + MAT, 
                  data = subset(aloe, train_id != 3),
                  split = "deviance")

# choosing alpha for pruning (run a few times and see variability of results)
tree_cv <- cv.tree(tree_aloe)
plot(tree_cv, type="b")
#? this seems to suggest a bigger tree

# see how the tree varies with values of k 
pruned_aloe <- prune.tree(tree_aloe, k = 0)
plot(pruned_aloe)
text(pruned_aloe)

# assess *test* accuracy
pred_aloe <- predict(pruned_aloe, newdata = subset(aloe, train_id == 3))
observed <- log(aloe[aloe$train_id == 3, "tottrees"])
mean((observed - pred_aloe)^2)



