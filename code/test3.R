setwd("~/Users/SMW/Dropbox/Coursera/DA_012213/Homework/HW2/code")
source('mcErrorRate.R')
##download.file("https://spark-public.s3.amazonaws.com/dataanalysis/samsungData.rda", "../data/samsungData.rda")

load("../data/samsungData.rda")
names(samsungData)
table(is.na(samsungData)) ## no NAs
rtable(samsungData$subject)

### Data Munging
#### Make current names syntactically valid and unique
names(samsungData) <- make.names(names(samsungData),unique=TRUE)
names(samsungData)

### Split Data
#### use 30% in test set
test1 <- c(27,28,29,30)
train1 <-c(1,3,5,6)
rest <- unique(samsungData$subject)
rest <- setdiff(setdiff(rest,test1),train1)
set.seed(35252)
test1 <- c(test1, sample(rest,3, replace=FALSE))
train1 <- setdiff(c(train1,rest),test1)
trainSet <- samsungData[samsungData$subject %in% train1,]
testSet <- samsungData[samsungData$subject %in% test1,]
table(trainSet$subject)
table(testSet$subject)

### Pick Features
#### Check correlations
train.pearson <- cor(trainSet[,-c(562,563)])
train.pearson
train.spearman <- cor(trainSet[,-c(562,563)], method="spearman")
train.spearman

for (i in 1:561) {
  
  
}


#### Find gravity vector
par(mfrow=c(3,1))
hist(trainSet[trainSet$activity=="laying",]$tGravityAcc.max...X)
hist(trainSet[trainSet$activity=="laying",]$tGravityAcc.max...Y)
hist(trainSet[trainSet$activity=="laying",]$tGravityAcc.max...Z)

hist(trainSet[trainSet$activity=="laying",]$tGravityAcc.mean...X)
hist(trainSet[trainSet$activity=="laying",]$tGravityAcc.mean...Y)
hist(trainSet[trainSet$activity=="laying",]$tGravityAcc.mean...Z)

hist(trainSet[trainSet$activity=="standing",]$tGravityAcc.mean...X)
hist(trainSet[trainSet$activity=="standing",]$tGravityAcc.mean...Y)
hist(trainSet[trainSet$activity=="standing",]$tGravityAcc.mean...Z)

hist(trainSet[trainSet$activity=="standing",]$tGravityAcc.max...X)
hist(trainSet[trainSet$activity=="standing",]$tGravityAcc.max...Y)
hist(trainSet[trainSet$activity=="standing",]$tGravityAcc.max...Z)

hist(trainSet[trainSet$activity=="sitting",]$tGravityAcc.max...X)
hist(trainSet[trainSet$activity=="sitting",]$tGravityAcc.max...Y)
hist(trainSet[trainSet$activity=="sitting",]$tGravityAcc.max...Z)

par(mfrow=c(1,1))
plot(1:nrow(trainSet),trainSet[order(trainSet$activity),"tGravityAcc.max...X"],
     col=as.factor(unique(trainSet[order(trainSet$activity),"activity"])), pch=19, cex=0.5)
legend("bottomright", legend=unique(trainSet$activity), col=as.factor(unique(trainSet$activity)), 
       pch=19, cex=0.8)

par(mfrow=c(1,1))
plot(1:nrow(trainSet),trainSet$tGravityAcc.mean...Y,
     col=as.factor(unique(trainSet$activity)), pch=19, cex=0.5)
legend("bottomright", legend=unique(trainSet$activity), col=as.factor(unique(trainSet$activity)), 
       pch=19, cex=0.8)


### Pick Function

### Try a tree
#### create Tree, first using all variables
library(tree)
train.tree <- tree(factor(activity)~.,data=trainSet)
par(mfrow=c(1,1))
plot(train.tree)
text(train.tree, cex=0.5)
summary(train.tree)

#### cross-validate results, check misclassifications
cv1.dev <- cv.tree(train.tree, FUN=prune.tree)
par(mfrow=c(2,1))
plot(cv.tree(train.tree,FUN=prune.tree,method="misclass"))
plot(cv1.dev)
cv1.dev

#### Based on cv result, prune to 8 nodes

#### check predict results
tree.predict <- predict(train.tree, predict(train.tree, type="class"))
head(tree.predict)
tree.cmat <- table(trainSet$activity, tree.predict)
tree.cmat
mcErrorRate(trainSet$activity,tree.predict)

#### try pruning to 7 nodes
train.tree.p7 <- prune.tree(train.tree,best=8)
par(mfrow=c(1,1))
plot(train.tree.p7)
text(train.tree.p7, cex=0.5)
summary(train.tree.p7)
#### cross-validate results, check misclassifications
par(mfrow=c(2,1))
p7.cv <- cv.tree(train.tree.p7)
p7.cv
plot(cv.tree(train.tree.p7,FUN=prune.tree,method="misclass"))
plot(p7.cv)
mcErrorRate(predict(train.tree.p7, trainSet, type="class"),trainSet$activity)
table(trainSet$activity,predict(train.tree.p7,trainSet, type="class"))

#### random Forest
#### can only change ntree, mtry
library(randomForest)
set.seed(37043)
train.rf <- randomForest(factor(activity) ~., data=trainSet, prox=TRUE, ntree=200)
print(train.rf)
importance(train.rf, type=2)
par(mfrow=c(1,1))
plot(train.rf)
par(mfrow=c(2,2))
#partialPlot(train.rf,trainSet,tGravityAcc.max...Y,"standing", cex=0.5)
#partialPlot(train.rf,trainSet,tGravityAcc.mean...Y,"standing", cex=0.5)
#partialPlot(train.rf,trainSet,tGravityAcc.max...X,"standing", cex=0.5)
#partialPlot(train.rf,trainSet,angle.Y.gravityMean.,"standing", cex=0.5)
varImpPlot(train.rf, main="Importance Plot", cex=0.6)
set.seed(37043)
tuneRF(trainSet[,-563], factor(trainSet$activity), 100, ntreeTry=100, stepFactor=2, improve=0.05,
       trace=TRUE, plot=TRUE)
#getTree(train.rf,k=1)

### Cross-validate
train.rf.cv <- rfcv(trainSet[,-c(562,563)], as.factor(trainSet$activity))

### Refine if validation

### Apply to test set
table(testSet$activity,predict(train.tree,testSet, type="class"))
mcErrorRate(predict(train.tree, testSet, type="class"),testSet$activity)
mcErrorRate(predict(train.tree.p6, testSet, type="class"),testSet$activity)
table(testSet$activity,predict(train.tree.p8,testSet, type="class"))
mcErrorRate(predict(train.tree.p8, testSet, type="class"),testSet$activity)

table(testSet$activity,predict(train.rf,testSet))
mcErrorRate(predict(train.rf, testSet, type="class"),testSet$activity)
