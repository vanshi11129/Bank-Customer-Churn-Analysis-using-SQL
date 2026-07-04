import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
import xgboost as xgb
from sklearn.model_selection import train_test_split
from sklearn.metrics import accuracy_score, confusion_matrix, classification_report
from sklearn.preprocessing import LabelEncoder
from xgboost import XGBClassifier
from sklearn.linear_model import LogisticRegression
from imblearn.over_sampling import SMOTE  # NEW: Import SMOTE

sns.set_style("whitegrid")

# 1. Load Data
df = pd.read_csv(r"C:\Users\dhami\Downloads\Datasets\Bank Customer Churn Prediction.csv")

# 3. Handle Missing Values & Duplicates
df.dropna(inplace=True)
df.drop_duplicates(inplace=True)

# 4. Drop ID column - not predictive
df.drop(columns=['customer_id'], inplace=True)

# 5. Encoding Categorical Variables
label_encoder = LabelEncoder()	
df['gender'] = label_encoder.fit_transform(df['gender'])

# CRITICAL FIX: Cast boolean columns to integers so XGBoost doesn't break
df = pd.get_dummies(df, dtype=int)

X = df.drop(columns=['churn'])
y = df['churn']

# 6. Split Data
X_train, X_test, y_train, y_test = train_test_split(
    X, y, test_size=0.35, random_state=42, stratify=y
)

# NEW: Apply SMOTE only to the training set to prevent data leakage
smote = SMOTE(sampling_strategy=0.7,random_state=42)
X_train_resampled, y_train_resampled = smote.fit_resample(X_train, y_train)

# 7. Model Definition & Training (Using resampled training data)
params = {
   'objective': 'binary:logistic',
    'learning_rate': 0.03,     
    'max_depth': 5,            
    'n_estimators': 250,      
    'subsample': 0.5,          
    'colsample_bytree': 0.5,
   }

model = XGBClassifier(**params)
model.fit(X_train_resampled, y_train_resampled)  # NEW: Fit on resampled data

# 8. Evaluate on original, untouched test data
y_pred = model.predict(X_test)
cm = confusion_matrix(y_test, y_pred)
accuracy = accuracy_score(y_test, y_pred)

print("Model Accuracy:", accuracy)
print("\nClassification Report")
print(classification_report(y_test, y_pred))
print("Confusion Matrix:\n", cm)

