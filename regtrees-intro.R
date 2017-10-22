#### Regression trees I: Intro

# - building the tree
# - plotting the tree
# - assessing accuracy
# - choosing tuning parameters

library(tree)

load("data/aloe.RData")
head(aloe)

# build the full regression tree on all the data, later we'll do train/test
tree_aloe <- tree(log(tottrees) ~ Latitude + Longitude, 
                  data = aloe,
                  split = "deviance")

# plot the tree
plot(tree_aloe)
text(tree_aloe, cex=0.9)

# visualize the partitioned feature space
par(xaxs="i", yaxs="i")
plot(aloe$Longitude,aloe$Latitude, pch=21, cex=0.6, 
     col=terrain.colors(11)[1+floor(aloe$tottrees)],
     bg=terrain.colors(11)[1+floor(aloe$tottrees)],
     xlab="Longitude",ylab="Latitude",main="Predicted Log Abundance", bty="o")
partition.tree(tree_aloe,ordvars=c("Longitude","Latitude"), add=TRUE, lwd=3)

## assess accuracy (MSE/deviance)
# get predictions
pred_aloe <- predict(tree_aloe)
# check with scatterplot
plot(tree_aloe$y, pred_aloe, xlab = "Observed", ylab = "Predicted")
# mean square error 
mean((tree_aloe$y - pred_aloe)^2)

# tree.control allows you some finer control, experiment with options
# see help(tree.control) for details
# To produce a tree that fits the data perfectly, set mindev = 0 and 
# minsize = 2, if the limit on tree depth allows such a tree.

tree_aloe <- tree(log(tottrees) ~ Latitude + Longitude, 
                  data = aloe,
                  split = "deviance",
                  mincut = 1, 
                  minsize = 2, 
                  mindev = 0)

# plot the tree
plot(tree_aloe)
text(tree_aloe, cex=0.9)

# visualize the partitioned feature space
par(xaxs="i", yaxs="i")
plot(aloe$Longitude,aloe$Latitude, pch=21, cex=0.6, 
     col=terrain.colors(11)[1+floor(aloe$tottrees)],
     bg=terrain.colors(11)[1+floor(aloe$tottrees)],
     xlab="Longitude",ylab="Latitude",main="Predicted Log Abundance", bty="o")
partition.tree(tree_aloe,ordvars=c("Longitude","Latitude"), add=TRUE, lwd=3)

## assess accuracy (MSE/deviance)
pred_aloe <- predict(tree_aloe)
plot(tree_aloe$y, pred_aloe, xlab = "Observed", ylab = "Predicted")
mean((tree_aloe$y - pred_aloe)^2)
#? model looks great, but what's the problem?
