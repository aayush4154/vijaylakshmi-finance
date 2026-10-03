from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
import pandas as pd
import joblib

app = FastAPI(title="Vijaylakshmi Finance AI")
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=False,
    allow_methods=["*"],
    allow_headers=["*"],
)

model = joblib.load("loan_risk_model.pkl")


class LoanData(BaseModel):
    income: float
    loan_amount: float
    tenure_months: int
    previous_loans: int
    late_payments: int
    overdue_installments: int
    payment_completion: float


@app.get("/")
def home():
    return {"message": "Vijaylakshmi Finance AI is running"}


@app.post("/predict")
def predict(data: LoanData):

    input_data = pd.DataFrame([{
        "income": data.income,
        "loan_amount": data.loan_amount,
        "tenure_months": data.tenure_months,
        "previous_loans": data.previous_loans,
        "late_payments": data.late_payments,
        "overdue_installments": data.overdue_installments,
        "payment_completion": data.payment_completion
    }])

    prediction = model.predict(input_data)[0]
    probability = model.predict_proba(input_data)[0][1] * 100

    if probability < 35:
        risk = "LOW"
    elif probability < 65:
        risk = "MEDIUM"
    else:
        risk = "HIGH"

    return {
        "risk_probability": round(probability, 2),
        "risk_level": risk,
        "prediction": "Default Risk" if prediction == 1 else "Lower Default Risk"
    }