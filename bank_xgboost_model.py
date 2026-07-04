import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
import xgboost as xgb
from sklearn.model_selection import train_test_split
from sklearn.metrics import accuracy_score, confusion_matrix, classification_report
from sklearn.preprocessing import LabelEncoder
from xgboost import XGBClassifier
sns.set_style("whitegrid")
# 1. Load Data
df = pd.read_csv(r"C:\Users\dhami\Downloads\Datasets\Bank Customer Churn Prediction.csv")
#a=df.isnull().sum().sum
#print(a);
#b=df.isnull().sum()
#print(b);
# 3. Handle Missing Values & Duplicates
df.dropna(inplace=True)
df.drop_duplicates(inplace=True)
# 4. Drop ID column - not predictive
df.drop(columns=['customer_id'], inplace=True)
# 5. Encoding Categorical Variables
label_encoder = LabelEncoder()	
df['gender'] = label_encoder.fit_transform(df['gender'])
df = pd.get_dummies(df)
#print(df.head())
X = df.drop(columns=['churn'])
y = df['churn']
X_train, X_test, y_train, y_test = train_test_split(
    X, y, test_size=0.35, random_state=42, stratify=y
)
# 7. Model Definition & Training
params = {
   'objective':'binary:logistic',
    'learning_rate':0.03,     
    'max_depth':5,            
    'n_estimators':250,      
    'subsample':0.3,          
    'colsample_bytree':0.7,
    'scale_pos_weight':3.9,
    'eval_metric':"aucpr",  # PR AUC is preferred over ROC AUC for imbalanced data
    'random_state':42,
    'min_child_weight':5,
   'colsample_bylevel': 0.75
}
model = XGBClassifier(**params)
model.fit(X_train, y_train)
y_pred = model.predict(X_test)
cm = confusion_matrix(y_test, y_pred)
accuracy = accuracy_score(y_test, y_pred)
print("Model Accuracy:", accuracy)
print("\nClassification Report")
print(classification_report(y_test, y_pred))
print("Confusion Matrix",cm)
