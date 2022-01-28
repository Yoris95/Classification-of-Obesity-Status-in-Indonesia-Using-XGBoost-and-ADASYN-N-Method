#Set directory
setwd("E:/Yoris/obese300")


#Load packages
library(readxl)
library(memisc)
library(caret)
library(pROC)
library(ROCR)
library(dplyr)
library(e1071)
library(haven)
library(xgboost)
library(haven)
library(ggplot2)
library(DiagrammeR)
library(Matrix)
library(magrittr)

#Import the data
data <- read.csv("datanew.csv") #imbalanced data

data <- read.csv("obese300.csv") [,2:23] #balanced data

#Partition data
ind <- sample(2, nrow(data), replace = T, prob = c(0.8, 0.2))
train <- data[ind==1,]
test <- data[ind==2,]

# Convert to factor
for (i in 1:dim(test)[2]) {
  train[,i] <- as.factor(train[,i])
  test[,i] <- as.factor(test[,i])
}


#Data distribution plot
ggplot(train, aes(x2, ..count..)) + geom_bar(aes(fill = status_obesitas), position = "dodge")

#Transform to spare matrix
train.x <- model.matrix(status_obesitas~., data = train)[,-1]
train.y <- train[,22] == 2
test.x <- model.matrix(status_obesitas~., data = test)[,-1]

#state parameters
parameters <- list (eta = 0.1,
                    gamma = 0,
                    max_depth = 4,
                    reg_lambda = 1,
                    #scale_pos_weight= 1.5,
                    colsample_bytree = 1,
                    min_child_weight = 1,
                    subsample = 1,
                    eval_metric = "logloss",
                    objective = "binary:logistic",
                    booster = "gbtree")

#run xgboost
model <- xgboost(data = train.x,
                 label = train.y,
                 nround = 50,
                 params  = parameters,
                 early_stopping_rounds = 5,
                 verbose = 1)

#XGBOOST Tree plot
plotxgb <- xgb.plot.tree(model = model, trees = 1)

#Training Error Plot
c <- data.frame(model$evaluation_log)
k <- ggplot () + 
  geom_line(data = c, aes(x=iter, y=train_logloss)) +
  theme(plot.title = element_text(hjust = 0.5),
        
        panel.grid.major = element_line(color  = "lightgray",size = 0.25), 
        panel.background = element_rect(fill = "white", color = "black", size = 2)) + 
  labs(x = "Iteration", y = "LogLoss", 
       title = paste("Train logloss plot ")) + ylim(0.4,0.7) 

#evaluate model testing
prob <- predict(model, newdata = test.x)

#Classifying by probability (0.5)
pred <- ifelse(prob > 0.5, 2, 1)
pred <- as.factor(pred)
levels(pred) <- c(levels(pred))

#Confusion Matrix
cfmXGB <- confusionMatrix(pred, test$status_obesitas, positive = "2")

#ROC and AUC Plot Process
X <- prediction(predictions = prob, labels = test$status_obesitas)
R <- performance(X, "tpr", "fpr")
TPR <- R@y.values[[1]]
FPR <- R@x.values[[1]]
AUC <- auc(roc(test$status_obesitas,prob))
H <- data.frame(FPR = FPR, TPR = TPR)
X <- ggplot() + 
  geom_line(data = H, aes(x = FPR, y = TPR)) + 
  theme(plot.title = element_text(hjust = 0.5), 
        plot.subtitle = element_text(hjust = 0.5), 
        panel.grid.major = element_line(color  = "lightgray",size = 0.25), 
        panel.background = element_rect(fill = "white", color = "black", size = 2)) + 
  labs(x = "False Positive Rate", y = "True Positive Rate", 
       title = paste("Luas dibawah kurva KOP XGBoost =",
                     round(AUC*100,digits = 2),"%"), 
       subtitle = "Validation Dataset")

ggsave(plot = X, filename = "AUC.jpg")

#Saving metrics
confux <- cfmXGB$table
metric <- c(cfmXGB$byClass,cfmXGB$overall,  AUC, model$niter, 
            parameters$max_depth, parameters$eta, 
            parameters$gamma, parameters$subsample,
            parameters$reg_lambda, parameters$scale_pos_weight,
            parameters$colsample_bytree, parameters$min_child_weight)

names(metric)[19] <- "AUC"
names(metric)[20] <- "nRound"
names(metric)[21] <- "Max Depth"
names(metric)[22] <- "Eta"
names(metric)[23] <- "Gamma"
names(metric)[24] <- "subsample"
names(metric)[25] <- "reg_lambda"
names(metric)[26] <- "scale_pos_weight"
names(metric)[27] <- "colsample_bytree"
names(metric)[28] <- "min_child_weight"

metricX <- matrix(metric, 1, 28)

colnames(metricX) <- names(metric)

write.csv(metricX,"hasil.csv")

#Feature Importance
fitur <- xgb.importance (model=model)

RX <- xgb.ggplot.importance (importance_matrix = fitur[1:10])
ggsave(plot = RX, filename = "Feature Importance.jpg")

write.csv(fitur,"feature importance.csv")
