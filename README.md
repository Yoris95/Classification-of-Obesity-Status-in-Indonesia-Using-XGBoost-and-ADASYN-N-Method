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
- Balancing the imbalanced data using ADASYN.
4. Modelling Stage
-  Using XGBoost to build model.
5. Model Performance Evaluation
-  Evaluating the model built by calculating the values of accuracy, sensitivity, specifications, and AUC.

#Result
![Model comparison](
