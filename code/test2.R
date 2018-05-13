#setwd("~/Users/SMW/Dropbox/Coursera/DA_012213/Homework/HW2/code")
source('mcErrorRate.R')
##download.file("https://spark-public.s3.amazonaws.com/dataanalysis/samsungData.rda", "../data/samsungData.rda")

load("../data/samsungData.rda")
names(samsungData)
table(is.na(samsungData)) ## no NAs
table(samsungData$subject)

### Data Munging
#### Make current names syntactically valid and unique
nameVec <- make.names(names(samsungData),unique=TRUE)
names(samsungData) <- nameVec
names(samsungData)

### Split Data
subjects.rest <- c(7,8,11,14,15,16,17,19,21,22,23,25,26)
set.seed(47033)
#train1 <- sample(subjects.rest, 9, replace=FALSE)
#train1 <- c (train1, c(1,3,5,6))
test1 <- c(27,28,29,30)
#notvalid <- c(train1,test1)
#trainSet <- samsungData[samsungData$subject == c(1,3,5,6),]
trainSet <- samsungData[!(samsungData$subject %in% test1),]
validateSet <- samsungData[!(samsungData$subject %in% notvalid),]
testSet <- samsungData[samsungData$subject %in% test1,]
table(trainSet$subject)
table(validateSet$subject)
table(testSet$subject)

### Pick Features

### Pick Function

### Try a tree
#### create Tree
library(tree)
train.tree <- tree(factor(activity)~.,data=trainSet)
par(mfrow=c(1,1))
plot(train.tree)
text(train.tree, cex=0.5)

#### check predict results
tree.predict <- predict(train.tree, trainSet[,-563])
head(tree.predict)
table(trainSet$activity, predict(train.tree, type="class"))

par(mfrow=c(2,1))
plot(cv.tree(train.tree,FUN=prune.tree,method="misclass"))
plot(cv.tree(train.tree))
table(validateSet$activity, predict(train.tree, validateSet[,-563], type="class"))


#### random Forest
library(randomForest)
set.seed(37043)
train.rf <- randomForest(factor(activity) ~., data=trainSet, prox=TRUE, ntree=500)
print(train.rf)
importance(train.rf)
par(mfrow=c(1,1))
varImpPlot(train.rf, main="Importance Plot", cex=0.7)
getTree(train.rf,k=1)
table(validateSet$activity,predict(train.rf,validateSet[,-563]))

### Cross-validate

### Apply to test set
table(testSet$activity,predict(train.rf,testSet[,-563]))
### Refine if validation