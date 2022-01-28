#Set directory
setwd("E:/Yoris/Data seminar Yoris Rombe/Data Ibu Tuti/obese300")
setwd("E:/Yoris/Data seminar Yoris Rombe/Data Ibu Tuti/datafix")
set.seed(1234)

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
data <- read.csv("datanew.csv")

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

for (i in 1:dim(data)[2]) {
  data[,i] <- as.factor(data[,i])
}

o = table(data$x1, data$status_obesitas)
addmargins(o)
table(train$x1, train$status_obesitas)

data = table(train$X1)
data1 = round(data/sum(data)*100)
data1 = paste(names(data1), data1)
paste(data1, "%", sep = "")


#Dataset Plot
ggplot(train, aes(x2, ..count..)) + geom_bar(aes(fill = status_obesitas), position = "dodge")

ggplot(data, aes(x1, ..count..)) + geom_bar(aes(fill = status_obesitas), position = "dodge")

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

#evaluate model train
probt <- predict(model, newdata = train.x)

#evaluate model testing
prob <- predict(model, newdata = test.x)

#Classifying by probability (0.5)
pred <- ifelse(prob > 0.5, 2, 1)
pred <- as.factor(pred)
levels(pred) <- c(levels(pred))

#Confusion Matrix train data
cfmXGB <- confusionMatrix(pred, train$status_obesitas, positive = "2")
AUC <- auc(roc(train$status_obesitas,probt))


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

#view variable importance plot
b <- colnames(train.x)
b[b=="X1Perempuan"] <- "Jenis Kelamin"
b[b=="X255 - 74 Tahun"] <- "Umur 55 - 74 Tahun"
b[b=="X235 - 54 Tahun"] <- "Umur 35 - 54 Tahun"
b[b=="X275 - 94 Tahun"] <- "Umur 75 - 94 Tahun"
b[b=="X3Ya"] <- "Merokok"
b[b=="X4Ya"] <- "Aktifitas Berat"
b[b=="X5Ya"] <- "Aktifitas Sedang"
b[b=="X62 Hari"] <- "Makan Buah 2 Hari"
b[b=="X63 Hari"] <- "Makan Buah 3 Hari"
b[b=="X64 Hari"] <- "Makan Buah 4 Hari"
b[b=="X65 Hari"] <- "Makan Buah 5 Hari"
b[b=="X66 Hari"] <- "Makan Buah 6 Hari"
b[b=="X67 Hari"] <- "Makan Buah 7 Hari"
b[b=="X6Tidak Pernah"] <- "Tidak Pernah Makan Buah"
b[b=="X72 Hari"] <- "Makan Sayur 2 Hari"
b[b=="X73 Hari"] <- "Makan Sayur 3 Hari"
b[b=="X74 Hari"] <- "Makan Sayur 4 Hari"
b[b=="X75 Hari"] <- "Makan Sayur 5 Hari"
b[b=="X76 Hari"] <- "Makan Sayur 6 Hari"
b[b=="X77 Hari"] <- "Makan Sayur 7 Hari"
b[b=="X7Tidak Pernah"] <- "Tidak Pernah Makan Sayur"
b[b=="X8> 1 kali per hari"] <- "Makan Manis lebih dari sekali per Hari"
b[b=="X81 - 2 kali per minggu"] <- "Makan Manis 1 - 2 per Minggu"
b[b=="X81 kali per hari"] <- "Makan Manis sekali per Hari"
b[b=="X83 - 6 kali per minggu"] <- "Makan Manis 3 - 6 kali per Minggu"
b[b=="X8Tidak pernah"] <- "Tidak Pernah Makan Manis"
b[b=="X9> 1 kali per hari"] <- "Makan Asin lebih dari sekali per Hari"
b[b=="X91 - 2 kali per minggu"] <- "Makan Asin 1 - 2 kali per Minggu"
b[b=="X91 kali per hari"] <- "Makan Asin sekali per Hari"
b[b=="X93 - 6 kali per minggu"] <- "Makan Asin 3 - 6 per Minggu"
b[b=="X9Tidak pernah"] <- "Tidak Pernah Makan Asin"
b[b=="X10> 1 kali per hari"] <- "Makan Berlemak lebih dari sekali per Hari"
b[b=="X101 - 2 kali per minggu"] <- "Makan Berlemak 1 - 2 per Minggu"
b[b=="X101 kali per hari"] <- "Makan Berlemak sekali per Hari"
b[b=="X103 - 6 kali per minggu"] <- "Makan Berlemak 3 - 6 per Minggu"
b[b=="X10Tidak pernah"] <- "Tidak Pernah Makan Berlemak"
b[b=="X11Tidak Stres"] <- "Stress"

#fitur <- xgb.importance (feature_name = b, model=model)

fitur <- xgb.importance (model=model)

xgb.model.dt.tree(model = model)

RX <- xgb.ggplot.importance (importance_matrix = fitur[1:10])
ggsave(plot = RX, filename = "Feature Importance.jpg")

write.csv(fitur,"feature importance.csv")
