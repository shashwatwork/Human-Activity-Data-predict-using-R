source('/home/shashwat/Desktop/VIT PROJECTS/UCI HAR Dataset/PredictionHumanActivity_R/code/mcErrorRate.R')
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
image(1:561,1:561,abs(train.pearson))
spear.im <- abs(t(train.spearman))[,nrow(train.spearman):1]
image(1:562,1:562,spear.im, xlab="Column #", ylab="Row #", cex=0.7)
#image(1:561,1:561,train.spearman, cex=0.7)
#heatmap(abs(train.spearman),Rowv=NA,Colv=NA)

source('/home/shashwat/Desktop/VIT PROJECTS/UCI HAR Dataset/PredictionHumanActivity_R/code/cutoff.corr.R')

#### filter highly correlated values using spearman (monotonic, not linear)
spearmancut <- cutoff.corr(train.spearman,0.95)
cols.omit <- c(spearmancut)*-1
trainSet.2 <- trainSet[,cols.omit]

### decrease spearman Cuttfoff
spearmancut2 <- cutoff.corr(train.spearman,0.90)
cols.omit <- c(spearmancut2)*-1
trainSet.2_2 <- trainSet[,cols.omit]

#### filter highly correlated values using pearson (linear)
pearsoncut <- cutoff.corr(train.pearson,0.95)
cols.omit <- c(pearsoncut)*-1
trainSet.3 <- trainSet[,cols.omit]


par(mfrow=c(3,1))
hist(trainSet[trainSet$activity=="laying",]$tBodyGyro.energy...X)
hist(trainSet[trainSet$activity=="walkup",]$tBodyGyro.energy...X)
hist(trainSet[trainSet$activity=="walk",]$tBodyGyro.energy...X)


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
### cut at 7 nodes

#### create Tree, using omitted Spearman corr vars
train.tree.2 <- tree(factor(activity)~.,data=trainSet.2)
par(mfrow=c(1,1))
plot(train.tree.2)
text(train.tree.2, cex=0.5)
summary(train.tree.2)
#### result has 11 nodes

### cross validate
cv2.dev <- cv.tree(train.tree.2, FUN=prune.tree)
par(mfrow=c(2,1))
plot(cv.tree(train.tree.2,FUN=prune.tree,method="misclass"))
plot(cv2.dev)
cv2.dev
### prune to 8 nodes

#### create Tree, using omitted Pearson correlated vars
train.tree.3 <- tree(factor(activity)~.,data=trainSet.3)
par(mfrow=c(1,1))
plot(train.tree.3)
text(train.tree.3, cex=0.5)
summary(train.tree.3)
#### result has 11 nodes

### cross validate
cv3.dev <- cv.tree(train.tree.3, FUN=prune.tree)
par(mfrow=c(2,1))
plot(cv.tree(train.tree.3,FUN=prune.tree,method="misclass"))
plot(cv3.dev)
cv3.dev

#### try pruning to 7 nodes
train.tree.p7 <- prune.tree(train.tree,best=7)
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

#### create Tree, using omitted Spearman corr vars; prune to 8 nodes
train.tree.2.p8 <- prune.tree(train.tree.2, best=8)
par(mfrow=c(1,1))
plot(train.tree.2.p8)
text(train.tree.2.p8, cex=0.5)
summary(train.tree.2.p8)

#### create Tree, using omitted Pearson corr vars; prune to 8 nodes
train.tree.3.p8 <- prune.tree(train.tree.3, best=8)
par(mfrow=c(1,1))
plot(train.tree.3.p8)
text(train.tree.3.p8, cex=0.5)
summary(train.tree.3.p8)

#### random Forest
#### can only change ntree, mtry

#### Do RF on original trainSet with all columns
library(randomForest)
set.seed(37043)
train.rf <- randomForest(factor(activity) ~., data=trainSet, prox=TRUE, ntree=200)
print(train.rf)
importance(train.rf, type=2)
par(mfrow=c(1,1))
plot(train.rf)
varImpPlot(train.rf, main="Importance Plot", cex=0.6)
set.seed(37043)
tuneRF(trainSet[,-563], factor(trainSet$activity), 100, ntreeTry=100, stepFactor=2, improve=0.05,
       trace=TRUE, plot=TRUE)
#getTree(train.rf,k=1)

### use Spearman set
set.seed(37043)
train.2.rf <- randomForest(factor(activity) ~., data=trainSet.2, prox=TRUE, ntree=200)
print(train.2.rf)
importance(train2.rf, type=2)
par(mfrow=c(1,1))

plot(train.2.rf)
varImpPlot(train.2.rf, main="Importance Plot", cex=0.6)
set.seed(37043)
tuneRF(trainSet.2[,-563], factor(trainSet$activity), 100, ntreeTry=100, stepFactor=2, improve=0.05,
       trace=TRUE, plot=TRUE)

### use Pearson set
set.seed(37043)
train.3.rf <- randomForest(factor(activity) ~., data=trainSet.3, prox=TRUE, ntree=200)
print(train.3.rf)
importance(train3.rf, type=2)
par(mfrow=c(1,1))
plot(train.3.rf)
varImpPlot(train.3.rf, main="Importance Plot", cex=0.6)
set.seed(37043)
tuneRF(trainSet.3[,-563], factor(trainSet$activity), 100, ntreeTry=100, stepFactor=2, improve=0.05,
       trace=TRUE, plot=TRUE)

### choose Spearman set, reduce ntrees and mtry
set.seed(37043)
train.22.rf <- randomForest(factor(activity) ~., data=trainSet.2, prox=TRUE, ntree=150)
print(train.22.rf)
importance(train22.rf, type=2)
par(mfrow=c(1,1))
plot(train.22.rf)
varImpPlot(train.22.rf, main="Importance Plot", cex=0.6)
set.seed(37043)
tuneRF(trainSet.2[,-201], factor(trainSet.2$activity), ntreeTry=150, stepFactor=1.5, improve=0.05,
       trace=TRUE, plot=TRUE)
### consensus is mtry=14, ntrees=150


### choose 2nd Spearman set, reduce ntrees and mtry
set.seed(37043)
train.23.rf <- randomForest(factor(activity) ~., data=trainSet.2_2, prox=TRUE, ntree=150)
print(train.23.rf)
importance(train.23.rf, type=2)
par(mfrow=c(1,1))
plot(train.23.rf)
varImpPlot(train.23.rf, main="Importance Plot", cex=0.6)
set.seed(37043)
tuneRF(trainSet.2_2[,-162], factor(trainSet.2_2$activity), ntreeTry=150, stepFactor=1.5, improve=0.05,
       trace=TRUE, plot=TRUE)
#
### Cross-validate
train.2.rf.cv <- rfcv(trainSet.2[,-c(201)], as.factor(trainSet.2$activity))

### Refine if validation

### Apply to test set
table(testSet$activity,predict(train.tree,testSet, type="class"))
mcErrorRate(predict(train.tree, testSet, type="class"),testSet$activity)
table(testSet$activity,predict(train.tree.2,testSet, type="class"))
mcErrorRate(predict(train.tree.2, testSet, type="class"),testSet$activity)
table(testSet$activity,predict(train.tree.3,testSet, type="class"))
mcErrorRate(predict(train.tree.3, testSet, type="class"),testSet$activity)
table(testSet$activity,predict(train.tree.p7,testSet, type="class"))
mcErrorRate(predict(train.tree.p7, testSet, type="class"),testSet$activity)
table(testSet$activity,predict(train.tree.2.p8,testSet, type="class"))
mcErrorRate(predict(train.tree.2.p8, testSet, type="class"),testSet$activity)
table(testSet$activity,predict(train.tree.3.p8,testSet, type="class"))
mcErrorRate(predict(train.tree.3.p8, testSet, type="class"),testSet$activity)


table(testSet$activity,predict(train.rf,testSet))
mcErrorRate(predict(train.rf, testSet, type="class"),testSet$activity)
table(testSet$activity,predict(train.2.rf,testSet))
mcErrorRate(predict(train.2.rf, testSet, type="class"),testSet$activity)
table(testSet$activity,predict(train.3.rf,testSet))
mcErrorRate(predict(train.3.rf, testSet, type="class"),testSet$activity)

table(trainSet$activity,predict(train.22.rf,trainSet))
mcErrorRate(predict(train.22.rf, trainSet, type="class"),trainSet$activity)

## Final Test -- use RF model with Correlation-based filtering
#### ntree = 150
table(testSet$activity,predict(train.22.rf,testSet))
mcErrorRate(predict(train.22.rf, testSet, type="class"),testSet$activity)

table(testSet$activity,predict(train.23.rf,testSet))
mcErrorRate(predict(train.23.rf, testSet, type="class"),testSet$activity)


#Final Plots
#-----------------
pdf(file="../figures/finalfigure1.pdf", heigh=4, width=2*4)
#palette(rainbow(3))
par(mfrow=c(1,2))
## Fig 1a -- Spearman coeff heatmap
spear.im <- abs(t(train.spearman))[,nrow(train.spearman):1]
image(1:562,1:562,spear.im, main="(a)", xlab="Column #", ylab="Row #", cex=0.7)

## Fig 1b
varImpPlot(train.22.rf, n.var=20, type=2, main="(b)", cex=0.7)

## Fig 1c

dev.off()