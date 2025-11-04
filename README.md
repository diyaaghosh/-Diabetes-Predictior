#  Diabetes Prediction App

**AI-powered early health risk detection system** built using **Streamlit**, **Python**, and **Machine Learning**.  
This app predicts the likelihood of diabetes based on user health inputs such as glucose level, insulin, BMI, and age.

---

##  Features

- 🔹 Clean and interactive **Streamlit UI**
- 🔹 Accepts multiple health parameters
- 🔹 Uses the **best-trained ML model** (Logistic Regression, Random Forest, CatBoost, etc.)
- 🔹 Displays confidence score and prediction message
- 🔹 Shows processed input data for transparency
- 🔹 Beautiful color-coded output messages
  -  *Non-Diabetic*: “You are likely not diabetic.”
  -  *Diabetic*: “You are likely diabetic. Please consult a doctor.”

---

##  Model Information

The backend model was trained on the **Pima Indians Diabetes Dataset**, using multiple algorithms:
- Logistic Regression  
- Random Forest  
- CatBoost  
- LightGBM  
- XGBoost  
- Neural Network  

After evaluation, the model with **highest AUC and F1-score** was chosen as the best and saved as:


---

##  Tech Stack

| Component | Technology |
|------------|-------------|
| **Frontend** | Streamlit |
| **Backend** | Python |
| **ML Frameworks** | Scikit-learn, CatBoost, LightGBM, XGBoost |
| **Model Saving** | joblib |
| **Visualization** | matplotlib, seaborn |
| **Dataset** | Pima Indians Diabetes Dataset (UCI Repository) |

---

##  Input Parameters

| Parameter | Description |
|------------|-------------|
| Pregnancies | Number of times pregnant (if applicable) |
| Glucose Level | Plasma glucose concentration |
| Blood Pressure | Diastolic blood pressure (mm Hg) |
| Skin Thickness | Triceps skin fold thickness (mm) |
| Insulin Level | 2-Hour serum insulin (mu U/ml) |
| BMI | Body Mass Index |
| Diabetes Pedigree Function | Genetic likelihood of diabetes |
| Age | Age in years |

---

##  Installation

### 1️ Clone the Repository
```bash
git clone https://github.com/diyaaghosh/diabetes-predictor.git
```

### **Install Dependencies**
pip install -r requirements.txt
### **Run the Streamlit App**
streamlit run app.py
### **File Structure**
 diabetes-prediction-app
│
├── app.py                      # Streamlit app main file
├── best_diabetes_model.pkl     # Saved ML model
├── requirements.txt            # Dependencies
├── README.md                   # Project documentation
├── dataset.csv                 # (optional) Training dataset
└── assets/
    └── app_preview.png         # Screenshot of the app



git clone https://github.com/<your-username>/diabetes-prediction-app.git
cd diabetes-prediction-app
