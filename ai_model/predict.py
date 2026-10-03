import joblib
import pandas as pd

model = joblib.load("loan_risk_model.pkl")

income = float(input("Monthly Income: "))
loan_amount = float(input("Loan Amount: "))
tenure_months = int(input("Tenure (Months): "))
previous_loans = int(input("Previous Loans: "))
late_payments = int(input("Late Payments: "))
overdue_installments = int(input("Overdue Installments: "))
payment_completion = float(input("Payment Completion (%): "))

data = pd.DataFrame([{
    "income": income,
    "loan_amount": loan_amount,
    "tenure_months": tenure_months,
    "previous_loans": previous_loans,
    "late_payments": late_payments,
    "overdue_installments": overdue_installments,
    "payment_completion": payment_completion
}])

prediction = model.predict(data)[0]
probability = model.predict_proba(data)[0][1] * 100

if probability < 35:
    risk = "LOW"
elif probability < 65:
    risk = "MEDIUM"
else:
    risk = "HIGH"

print("\n===== AI LOAN RISK RESULT =====")
print(f"Risk Probability: {probability:.2f}%")
print(f"Risk Level: {risk}")
print(f"Prediction: {'Default Risk' if prediction == 1 else 'Lower Default Risk'}")