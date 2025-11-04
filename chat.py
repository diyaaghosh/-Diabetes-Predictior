import subprocess
import sys


try:
    import joblib
except ImportError:
    subprocess.check_call([sys.executable, "-m", "pip", "install", "joblib"])
    import joblib

import streamlit as st
import pandas as pd


@st.cache_resource
def load_model():
    model = joblib.load("diabetes_model.pkl")
    model_columns = joblib.load("model_columns.pkl")
    return model, model_columns

model, model_columns = load_model()


st.markdown("""
    <style>
    .stApp {
        background: linear-gradient(135deg, #d4fc79 0%, #96e6a1 100%);
        font-family: 'Poppins', sans-serif;
    }
    h1 {
        text-align:center;
        color:#1a1a1a;
        background: -webkit-linear-gradient(45deg, #2b5876, #4e4376);
        -webkit-background-clip: text;
        -webkit-text-fill-color: transparent;
        font-weight:800;
    }
    .main-card {
        background:white;
        padding:25px;
        border-radius:20px;
        box-shadow:0 4px 20px rgba(0,0,0,0.1);
        margin-top:20px;
    }
    div.stButton > button {
        background-color:#4e4376;
        color:white;
        font-weight:bold;
        border-radius:10px;
        border:none;
        padding:0.6em 1.5em;
        transition:0.3s;
    }
    div.stButton > button:hover {
        background-color:#2b5876;
        transform:scale(1.05);
    }
    .result-box {
        background: linear-gradient(135deg, #89f7fe 0%, #66a6ff 100%);
        padding:20px;
        border-radius:15px;
        text-align:center;
        font-size:20px;
        font-weight:bold;
        color:white;
        margin-top:20px;
    }
    </style>
""", unsafe_allow_html=True)

st.markdown("<h1>🩺 Diabetes Prediction App</h1>", unsafe_allow_html=True)
st.markdown("<p style='text-align:center;font-size:18px;'>AI-powered early health risk detection 🌿</p>", unsafe_allow_html=True)


st.markdown('<div class="main-card">', unsafe_allow_html=True)
st.subheader("📋 Enter Your Health Details")

with st.form("diabetes_form"):
    col1, col2 = st.columns(2)

    with col1:
        pregnancies = st.number_input("Pregnancies", min_value=0, max_value=20, step=1)
        glucose = st.number_input("Glucose Level", min_value=0, max_value=300, step=1)
        blood_pressure = st.number_input("Blood Pressure", min_value=0, max_value=200, step=1)
        skin_thickness = st.number_input("Skin Thickness", min_value=0, max_value=100, step=1)

    with col2:
        insulin = st.number_input("Insulin Level", min_value=0, max_value=1000, step=1)
        bmi = st.number_input("BMI", min_value=0.0, max_value=70.0, step=0.1)
        dpf = st.number_input("Diabetes Pedigree Function", min_value=0.0, max_value=3.0, step=0.01)
        age = st.number_input("Age", min_value=1, max_value=120, step=1)

    submitted = st.form_submit_button("🔍 Predict")

st.markdown('</div>', unsafe_allow_html=True)


def preprocess_input(glucose, blood_pressure, skin_thickness, insulin, bmi, pregnancies, age, dpf):
    data = {}

    # 1. DiabetesPedigreeFunction (kept as numeric)
    data["DiabetesPedigreeFunction"] = dpf

    # 2. SkinThickness bins
    if skin_thickness < 20:
        data["SkinThickness_Low"] = 1
        data["SkinThickness_Normal"] = 0
        data["SkinThickness_High"] = 0
    elif skin_thickness <= 40:
        data["SkinThickness_Low"] = 0
        data["SkinThickness_Normal"] = 1
        data["SkinThickness_High"] = 0
    else:
        data["SkinThickness_Low"] = 0
        data["SkinThickness_Normal"] = 0
        data["SkinThickness_High"] = 1

    # 3. Age bins
    if age < 35:
        data["Young"] = 1; data["Mid Age"] = 0; data["Senior Citizen"] = 0
    elif age < 60:
        data["Young"] = 0; data["Mid Age"] = 1; data["Senior Citizen"] = 0
    else:
        data["Young"] = 0; data["Mid Age"] = 0; data["Senior Citizen"] = 1

    # 4. BMI bins
    if bmi < 25:
        data["Optimal_BMI"] = 1; data["Risky_BMI"] = 0
    else:
        data["Optimal_BMI"] = 0; data["Risky_BMI"] = 1

    # 5. Insulin bins
    if insulin < 100:
        data["Low_insulin"] = 1; data["Medium_Insulin"] = 0; data["High_Insulin"] = 0
    elif insulin < 200:
        data["Low_insulin"] = 0; data["Medium_Insulin"] = 1; data["High_Insulin"] = 0
    else:
        data["Low_insulin"] = 0; data["Medium_Insulin"] = 0; data["High_Insulin"] = 1

    # 6. Blood Pressure bins
    if blood_pressure < 80:
        data["Low_Pressure"] = 1; data["Normal Pressure"] = 0; data["High_Pressure"] = 0
    elif blood_pressure <= 120:
        data["Low_Pressure"] = 0; data["Normal Pressure"] = 1; data["High_Pressure"] = 0
    else:
        data["Low_Pressure"] = 0; data["Normal Pressure"] = 0; data["High_Pressure"] = 1

    # 7. Pregnancy bins
    if pregnancies <= 3:
        data["Normal_count_Pregnancy"] = 1; data["Risky_count_Pregnancy"] = 0
    else:
        data["Normal_count_Pregnancy"] = 0; data["Risky_count_Pregnancy"] = 1

    # 8. Glucose bins
    if glucose < 100:
        data["Low_Glucose_level"] = 1; data["Normal_Glucose_Level"] = 0; data["High_Glucose_Level"] = 0
    elif glucose <= 140:
        data["Low_Glucose_level"] = 0; data["Normal_Glucose_Level"] = 1; data["High_Glucose_Level"] = 0
    else:
        data["Low_Glucose_level"] = 0; data["Normal_Glucose_Level"] = 0; data["High_Glucose_Level"] = 1

    return pd.DataFrame([data])


if submitted:
    input_df = preprocess_input(glucose, blood_pressure, skin_thickness, insulin, bmi, pregnancies, age, dpf)

    # Ensure all model columns exist
    input_df = input_df.reindex(columns=model_columns, fill_value=0)

    st.write("🧩 Processed Input Data:")
    st.dataframe(input_df)

    prediction = model.predict(input_df)[0]
    prob = model.predict_proba(input_df)[0][1] if hasattr(model, "predict_proba") else None

    if prediction == 0:
        st.markdown("<div class='result-box' style='background: linear-gradient(135deg, #00b09b 0%, #96c93d 100%);'>🟢 You are not likely diabetic.</div>", unsafe_allow_html=True)
    else:
        st.markdown("<div class='result-box' style='background: linear-gradient(135deg, #ff0844 0%, #ffb199 100%);'>🔴 You are likely diabetic. Please consult a doctor.</div>", unsafe_allow_html=True)

    if prob is not None:
        st.progress(int(prob * 100))
        st.write(f"**Confidence:** {prob*100:.2f}%")

