# Introduction
Obesity is a condition due to excessive fat in the body, which can endanger health. Several risk factors that cause obesity in adult women are marital status, household income, domicile area, physical activity, energy and carbohydrate intake. Besides, genetic factors, psychological factors, improper lifestyle, bad eating habits, stress, and other trigger factors. The increasing availability of data and knowledge in the medical field has contributed to the rapid development in this field. Powerful machine learning is required to meet the pattern recognition needs of medical data, including obesity data. This study is aimed to determine the factors that influence obesity status in Indonesia. XGBoost (Extreme Gradient Boosting) is a classification method that is often used because it has many advantages over classical classification methods. Adaptive Synthetic Nominal Algorithm (ADASYN-N) can be used to improve the prediction accuracy of imbalanced data. Both methods will be applied to the Obesity data from the 2013 Indonesian Basic Health Research. 

# Data Source
The data used in this study is secondary data, namely Indonesian obesity data obtained through the 2013 Indonesian Basic Health Research. The obesity data had 722.329 observations and 12 variables. After filtering process, there were found 17.352 data with "NA" (missing values). The data were then reduced to 704.977.         

# Algorithm
1. Data Preparation
- Data filtering is conducted with the aim of obtaining complete and ready to-use data in research. The variables used are selected variables based on the relevant literature, which consists of categorical data.
2. Data Partition
- Data is divided into training data and testing data with the proportion of 80% and 20%.
3. ADASYN Method
- Balancing the imbalanced data using ADASYN-N.
4. Modelling Stage
-  Using XGBoost to build model.
5. Model Performance Evaluation
-  Evaluating the model built by calculating the values of accuracy, sensitivity, specifications, and AUC.
6. Feature Importance
- Ranking the features by using the best model obtained after comparing the XGBoost with ADASYN-N model and the XGBoost without ADASYN-N model.

# Result

![Model Comparison](https://user-images.githubusercontent.com/98592375/151652483-feeb7dd5-ea79-48d8-8067-63b11b473f6c.JPG)

Based on the image above, the best model obtained is XGBoost with ADASYN. We then conduct the feature importance based on the best model obtained.

![Feature Importance](https://user-images.githubusercontent.com/98592375/151652491-29f14fb1-2bc2-4618-9179-858eadd28521.JPG)

Based on the XGBoost model with ADASYN-N, the most important factor influencing obesity status based on the 2013 Basic Health Research data is gender (female) factor, meaning that gender (X1) can reduce the highest heterogeneity. Other influencing factors are age 35-54 years (X2), strenuous activity (X4), and eating vegetables for 6 days (X7).

# *Author*
* Yoris Rombe (yoris.rombe.95@gmail.com)
  - [LinkedIn](www.linkedin.com/in/yoris-rombe-327115146)
