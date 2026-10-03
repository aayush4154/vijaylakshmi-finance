import pandas as pd
import numpy as np
from sklearn.model_selection import train_test_split
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import accuracy_score, classification_report
import joblib

np.random.seed(42)

rows = 1000

income = np.random.randint(15000, 100001, rows)
loan_amount = np.random.randint(5000, 100001, rows)
tenure_months = np.random.randint(3, 25, rows)
previous_loans = np.random.randint(0, 6, rows)
late_payments = np.random.randint(0, 10, rows)
overdue_installments = np.random.randint(0, 6, rows)
payment_completion = np.random.randint(40, 101, rows)

risk = (
    (loan_amount > income * 2).astype(int)
    + (late_payments >= 4).astype(int)
    + (overdue_installments >= 2).astype(int)
    + (payment_completion < 70).astype(int)
)

default = (risk >= 2).astype(int)

df = pd.DataFrame({
    "income": income,
    "loan_amount": loan_amount,
    "tenure_months": tenure_months,
    "previous_loans": previous_loans,
    "late_payments": late_payments,
    "overdue_installments": overdue_installments,
    "payment_completion": payment_completion,
    "default": default
})

df.to_csv("dataset.csv", index=False)

X = df.drop("default", axis=1)
y = df["default"]

X_train, X_test, y_train, y_test = train_test_split(
    X,
    y,
    test_size=0.2,
    random_state=42,
    stratify=y
)

model = RandomForestClassifier(
    n_estimators=200,
    random_state=42
)

model.fit(X_train, y_train)

predictions = model.predict(X_test)

print("Accuracy:", accuracy_score(y_test, predictions))
print("\nClassification Report:")
print(classification_report(y_test, predictions))

joblib.dump(model, "loan_risk_model.pkl")

print("\nModel saved successfully!")
print("Dataset saved successfully!")