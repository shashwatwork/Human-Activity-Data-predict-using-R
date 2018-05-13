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
train1 <- sample(subjects.rest, 9, replace=FALSE)
train1 <- c (train1, c(1,3,5,6))
test1 <- c(27,28,29,30)
notvalid <- c(train1,test1)
#trainSet <- samsungData[samsungData$subject == c(1,3,5,6),]
trainSet <- samsungData[samsungData$subject %in% train1,]
validateSet <- samsungData[!(samsungData$subject %in% notvalid),]
testSet <- samsungData[samsungData$subject %in% test1,]
table(trainSet$subject)
table(validateSet$subject)
table(testSet$subject)

### Pick Features

#### Try SVD
numericActivity <- as.numeric(as.factor(samsungData$activity))[which(samsungData$subject %in% c(1,3,5,6))]
train.svd <- svd(trainSet[,1:561])
par(mfrow=c(1,2))
plot(train.svd$u[,1], xlab="Row", col=numericActivity, pch=19)
legend("topleft",legend=unique(numericActivity), col=unique(numericActivity), pch=19, cex=0.8)
plot(train.svd$u[,2], xlab="Col", col=numericActivity, pch=19)

par(mfrow=c(1,2))
plot(train.svd$v[1,], xlab="Row", col=numericActivity, pch=19)
legend("bottomleft",legend=unique(numericActivity), col=unique(numericActivity), pch=19, cex=0.8)
plot(train.svd$v[2,], xlab="Col", col=numericActivity, pch=19)

par(mfrow=c(1,2))
plot(train.svd$d^2/sum(train.svd$d^2),pch=19, cex=0.5)

print(train.svd)

#### Try plots of various columns
par(mfrow=c(1,2))
plot(trainSet[,41],trainSet[,42], col=numericActivity,pch=19, cex=0.5)
plot(trainSet[,41],trainSet[,43], col=numericActivity,pch=19, cex=0.5)
plot(trainSet[,42],trainSet[,43], col=numericActivity,pch=19, cex=0.5)
plot(trainSet[,41],trainSet[,214], col=numericActivity,pch=19, cex=0.5)
legend("topright",legend=unique(numericActivity), col=unique(numericActivity), pch=19, cex=0.8)
par(mfrow=c(1,1))
hist(trainSet[,214])

#### Try PCA
train.pca <- prcomp(trainSet[,-563], center=TRUE, scale=TRUE)
summary(train.pca)
train.pca$rotation[,1][order(train.pca$rotation[,1])]   # look at LOADINGs matrix

biplot(train.pca, col=c("gray","red"), choices=1:2, cex=0.7)
plot(train.pca)
predict(train.pca)[,1]

### Pick Function

### use a tree first
library(tree)
train.tree <- tree(factor(activity)~.,data=trainSet)
par(mfrow=c(1,1))
plot(train.tree)
text(train.tree, cex=0.5)
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
getTree(train.rf,k=1)

### Cross-validate

### Apply to test set

### Refine if validation