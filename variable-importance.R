#### Assessing variable importance and variable effects

# - variable importance plots
# - partial dependence plots

library(randomForest)
library(gbm)

source("utils.R")

# load data
load("data/aloe.RData")
head(aloe_pa)

# load previous models
load("output/aloe_models.RData")

##### variable importance and partial dependence plots

## for bagging

varImpPlot(bag, main = "")

partialPlot(bag, 
            pred.data = subset(aloe_pa, 
                               train_id != 3),
            x.var = Longitude,
            which.class = 1,
            n.pt = 50)

## for random forests

varImpPlot(rf, main = "")

partialPlot(rf, 
            pred.data = subset(aloe_pa, 
                               train_id != 3),
            x.var = Longitude,
            which.class = 1,
            n.pt = 50)

## for boosting

best.iter <- gbm.perf(boost, method="cv")

# plot variable influence
summary(boost, n.trees = best.iter, par(las=1)) # based on the estimated best number of trees

# plot marginal effects (watch out for scale!)
plot(boost, 1, best.iter, type = "response")
plot(boost, 2, best.iter, type = "response")
plot(boost, 3, best.iter, type = "response")

# lattice plot of Lat-Long effects
par(mfrow=c(1,1))
plot(boost, 1:2, best.iter, type = "response")
