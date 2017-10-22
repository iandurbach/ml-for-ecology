#### Extensions of CART to ensemble methods

# - bagged trees
# - random forests
# - boosting
# - assessing in-bag, out-of-bag, test accuracy

library(randomForest)
library(gbm)

source("utils.R")

load("data/aloe.RData")
head(aloe_pa)
# ensure outcome is a factor variable
aloe_pa$present <- factor(aloe_pa$present)

# number of predictor variables
ncol(aloe_pa) - 2

##### bagging
bag <- randomForest(present ~ ., 
                    data = subset(aloe_pa, 
                                  train_id != 3, 
                                  select = -train_id),
                    mtry = 20,
                    importance = T, 
                    ntree = 5000)

# see how out-of-bag error rate decreases as more trees used
bag_errors <- bag$err.rate[,"OOB"]
plot(bag_errors, type = "l", ylab = "OOB error", xlab = "Number of trees")

# assess OOB accuracy
pred <- bag$confusion[1:2,1:2]
sum(diag(pred)) / sum(pred) # OOB accuracy
cohens_kappa(pred) # OOB kappa

# assess accuracy in test set
pred_aloe_pa <- predict(bag, 
                        type = "class",
                        newdata = subset(aloe_pa, train_id == 3))
observed <- aloe_pa[aloe_pa$train_id == 3, "present"]
predtest <- table(observed, pred_aloe_pa)
predtest
sum(diag(predtest))/sum(predtest) # test accuracy
max(table(observed))/length(observed)
cohens_kappa(predtest) # test kappa

###### random forest 

rf <- randomForest(present ~ ., 
                    data = subset(aloe_pa, 
                                  train_id != 3, 
                                  select = -train_id),
                    mtry = sqrt(20), # default for classification
                    importance = T, 
                    ntree = 5000)

# see how out-of-bag error rate decreases as more trees used
rf_errors <- rf$err.rate[,"OOB"]
plot(rf_errors, type = "l", ylab = "OOB error", xlab = "Number of trees")
lines(bag_errors, col = "red")
legend(x = "topright", lty = 1, col = c("black", "red"), 
       legend = c("Untuned RF", "Bagging"))

# assess OOB accuracy
pred <- rf$confusion[1:2,1:2]
sum(diag(pred)) / sum(pred) # OOB accuracy
cohens_kappa(pred) # OOB kappa

# assess accuracy in test set
pred_aloe_pa <- predict(rf, 
                        type = "class",
                        newdata = subset(aloe_pa, train_id == 3))
observed <- aloe_pa[aloe_pa$train_id == 3, "present"]
predtest <- table(observed, pred_aloe_pa)
predtest
sum(diag(predtest))/sum(predtest) # test accuracy
max(table(observed))/length(observed)
cohens_kappa(predtest) # test kappa


###### tuned random forest

# first search for optimal value of mtry
tuneRF <- tuneRF(x = subset(aloe_pa, 
                            train_id != 3, 
                            select = -c(present,train_id)),
                 y = subset(aloe_pa, train_id != 3)$present,
                 ntreeTry = 2000,
                 stepFactor = 2)

# select the optimal value found
tuneRF
mtry_tune <- tuneRF[which(tuneRF[,2]==min(tuneRF[,2]))[1],1]

# fit tuned RF
rf_tuned <- randomForest(present ~ ., 
                   data = subset(aloe_pa, 
                                 train_id != 3, 
                                 select = -train_id),
                   mtry = mtry_tune, # default for classification
                   importance = T, 
                   ntree = 5000)

# see how out-of-bag error rate decreases as more trees used
rf_tuned_errors <- rf_tuned$err.rate[,"OOB"]
plot(rf_tuned_errors, type = "l", 
     ylab = "OOB error", xlab = "Number of trees")
lines(rf_errors, col = "blue")
lines(bag_errors, col = "red")
legend(x = "topright", lty = 1, col = c("black", "blue", "red"), 
       legend = c("Tuned RF", "Untuned RF", "Bagging"))

# assess OOB accuracy
pred <- rf_tuned$confusion[1:2,1:2]
sum(diag(pred)) / sum(pred) # OOB accuracy
cohens_kappa(pred) # OOB kappa

# assess accuracy in test set
pred_aloe_pa <- predict(rf_tuned, 
                        type = "class",
                        newdata = subset(aloe_pa, train_id == 3))
observed <- aloe_pa[aloe_pa$train_id == 3, "present"]
predtest <- table(observed, pred_aloe_pa)
predtest
sum(diag(predtest))/sum(predtest) # test accuracy
max(table(observed))/length(observed)
cohens_kappa(predtest) # test kappa


##### boosting

# gbm crashes if response variable is a factor, so reload the data
load("data/aloe.RData")
aloe_pa$present <- as.logical(aloe_pa$present)

boost <- gbm(present ~ ., 
              data = subset(aloe_pa, 
                            train_id != 3, 
                            select = -train_id),
              distribution = "bernoulli",
              n.trees=20000,                # number of trees
              shrinkage=0.01,              # shrinkage or learning rate,
                                           # 0.001 to 0.1 usually work
              interaction.depth=1,         # 1: additive model, 2: two-way interactions, etc.
              bag.fraction = 0.5,          # subsampling fraction, 0.5 is probably best
              train.fraction = 0.7,        # fraction of data for training
              n.minobsinnode = 10,         # minimum total obs needed in each node
              cv.folds = 5,                # do 3-fold cross-validation
              keep.data=TRUE,              # keep a copy of the dataset with the object
              verbose=FALSE,               # don't print out progress
              n.cores=1)                   # use only a single core 

# check performance using an out-of-bag estimator
# OOB underestimates the optimal number of iterations
best.iter1 <- gbm.perf(boost, method="OOB")
print(best.iter1)

# check performance using a 20% heldout test set
best.iter2 <- gbm.perf(boost, method="test")
print(best.iter2)

# check performance using 5-fold cross-validation
best.iter3 <- gbm.perf(boost, method="cv")
print(best.iter3)

# assess training accuracy

# note predict.gbm returns a probability, so we turn the probability 
# into a class using a cut-off of 0.5

pred <- predict(boost, 
                type = "response",
                n.trees = best.iter3)
pred <- (pred > 0.5)
observed <- subset(aloe_pa, train_id != 3)$present
predtrain <- table(observed, pred)
sum(diag(predtrain)) / sum(predtrain) # OOB accuracy
cohens_kappa(predtrain) # OOB kappa

# assess test accuracy

pred_aloe_pa <- predict(boost, 
                        type = "response",
                        newdata = subset(aloe_pa, train_id == 3),
                        n.trees = best.iter3)
pred_aloe_pa <- (pred_aloe_pa > 0.5)

observed <- aloe_pa[aloe_pa$train_id == 3, "present"]
predtest <- table(observed, pred_aloe_pa)
predtest
sum(diag(predtest))/sum(predtest) # test accuracy
max(table(observed))/length(observed)
cohens_kappa(predtest) # test kappa

# save the models for later use
save(bag, rf, boost, file = "output/aloe_models.RData")
