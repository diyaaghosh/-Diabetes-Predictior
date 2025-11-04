import 'package:flutter/material.dart';

void main() {
  runApp(const DiabetesDashboardApp());
}

class DiabetesDashboardApp extends StatelessWidget {
  const DiabetesDashboardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Diabetes Prediction Dashboard',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        useMaterial3: true,
      ),
      home: const DashboardPage(),
    );
  }
}

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final _formKey = GlobalKey<FormState>();

  // Form fields
  String _name = '';
  String _sex = 'Male';
  int _pregnancyCount = 0; // visible only if Female
  double? _glucose;
  double? _insulin;
  double? _weight;
  double? _heightCm;
  int? _age;
  int? _bpSystolic;
  int? _bpDiastolic;
  bool _parentsDiabetes = false;

  // Result
  double? _bmi;
  String? _bmiCategory;
  double? _riskScore; // 0..100
  String? _riskLabel;

  void _calculateAndPredict() {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    // Calculate BMI
    final heightM = (_heightCm ?? 0) / 100.0;
    if (heightM > 0 && (_weight ?? 0) > 0) {
      _bmi = (_weight! / (heightM * heightM));
    } else {
      _bmi = null;
    }

    // BMI Category
    if (_bmi == null) {
      _bmiCategory = 'Unknown';
    } else if (_bmi! < 18.5) {
      _bmiCategory = 'Underweight';
    } else if (_bmi! < 25) {
      _bmiCategory = 'Normal';
    } else if (_bmi! < 30) {
      _bmiCategory = 'Overweight';
    } else {
      _bmiCategory = 'Obese';
    }

    // Simple heuristic risk score (client-side placeholder)
    // Weighted combination of features (this is NOT a medical diagnosis)
    double score = 0.0;

    // Glucose: common strong indicator
    if (_glucose != null) {
      // scale: 70-200 maps to 0-40
      final g = _glucose!.clamp(40.0, 400.0);
      score += ((g - 70) / 130.0).clamp(0.0, 1.0) * 40.0;
    }

    // BMI contribution (0-20)
    if (_bmi != null) {
      final bmiScore = ((_bmi! - 18.5) / (40 - 18.5)).clamp(0.0, 1.0);
      score += bmiScore * 20.0;
    }

    // Age contribution (0-10)
    if (_age != null) {
      final ageScore = ((_age! - 20) / 60.0).clamp(0.0, 1.0);
      score += ageScore * 10.0;
    }

    // Insulin: higher may increase risk slightly (0-10)
    if (_insulin != null) {
      final i = _insulin!.clamp(0.0, 1000.0);
      score += (i / 300.0).clamp(0.0, 1.0) * 10.0;
    }

    // Blood pressure: systolic contribution (0-10)
    if (_bpSystolic != null) {
      final bpScore = ((_bpSystolic! - 110) / 50.0).clamp(0.0, 1.0);
      score += bpScore * 10.0;
    }

    // Pregnancy count increases risk for females slightly (0-5)
    if (_sex == 'Female') {
      final p = (_pregnancyCount).clamp(0, 20);
      score += (p / 10.0).clamp(0.0, 1.0) * 5.0;
    }

    // Family history strong (0 or +15)
    if (_parentsDiabetes) score += 15.0;

    // Normalize to 0-100
    _riskScore = score.clamp(0.0, 100.0);

    if (_riskScore! < 30) {
      _riskLabel = 'Low';
    } else if (_riskScore! < 60) {
      _riskLabel = 'Moderate';
    } else {
      _riskLabel = 'High';
    }

    setState(() {});
  }

  Widget _buildTextField({
    required String label,
    String? hint,
    TextInputType keyboardType = TextInputType.text,
    required FormFieldSetter<String> onSaved,
    FormFieldValidator<String>? validator,
    String? initialValue,
  }) {
    return TextFormField(
      initialValue: initialValue,
      decoration: InputDecoration(labelText: label, hintText: hint),
      keyboardType: keyboardType,
      validator: validator,
      onSaved: onSaved,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Diabetes Prediction Dashboard'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 4,
              shape:
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _buildTextField(
                        label: 'Patient name',
                        onSaved: (v) => _name = v?.trim() ?? '',
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Please enter a name'
                            : null,
                      ),

                      // Sex dropdown
                      DropdownButtonFormField<String>(
                        value: _sex,
                        decoration: const InputDecoration(labelText: 'Sex'),
                        items: const [
                          DropdownMenuItem(value: 'Male', child: Text('Male')),
                          DropdownMenuItem(value: 'Female', child: Text('Female')),
                          DropdownMenuItem(value: 'Other', child: Text('Other')),
                        ],
                        onChanged: (v) => setState(() => _sex = v ?? 'Male'),
                        onSaved: (v) => _sex = v ?? 'Male',
                      ),

                      // Pregnancy count (visible only if Female)
                      if (_sex == 'Female')
                        TextFormField(
                          decoration: const InputDecoration(
                              labelText: 'Pregnancy count (if female)'),
                          keyboardType: TextInputType.number,
                          initialValue: '0',
                          onSaved: (v) => _pregnancyCount = int.tryParse(v ?? '0') ?? 0,
                          validator: (v) {
                            if (_sex == 'Female') {
                              final n = int.tryParse(v ?? '');
                              if (n == null || n < 0) return 'Enter a valid number';
                            }
                            return null;
                          },
                        ),

                      // Numeric inputs
                      _buildTextField(
                        label: 'Glucose level (mg/dL)',
                        keyboardType: TextInputType.number,
                        onSaved: (v) => _glucose = double.tryParse(v ?? ''),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Enter glucose';
                          if (double.tryParse(v) == null) return 'Enter valid number';
                          return null;
                        },
                      ),

                      _buildTextField(
                        label: 'Insulin level (mu U/ml)',
                        keyboardType: TextInputType.number,
                        onSaved: (v) => _insulin = double.tryParse(v ?? ''),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Enter insulin';
                          if (double.tryParse(v) == null) return 'Enter valid number';
                          return null;
                        },
                      ),

                      _buildTextField(
                        label: 'Weight (kg)',
                        keyboardType: TextInputType.number,
                        onSaved: (v) => _weight = double.tryParse(v ?? ''),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Enter weight';
                          if (double.tryParse(v) == null) return 'Enter valid number';
                          return null;
                        },
                      ),

                      _buildTextField(
                        label: 'Height (cm)',
                        keyboardType: TextInputType.number,
                        onSaved: (v) => _heightCm = double.tryParse(v ?? ''),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Enter height';
                          if (double.tryParse(v) == null) return 'Enter valid number';
                          return null;
                        },
                      ),

                      _buildTextField(
                        label: 'Age (years)',
                        keyboardType: TextInputType.number,
                        onSaved: (v) => _age = int.tryParse(v ?? ''),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Enter age';
                          if (int.tryParse(v) == null) return 'Enter valid number';
                          return null;
                        },
                      ),

                      // BP inputs
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              decoration:
                                  const InputDecoration(labelText: 'BP Systolic'),
                              keyboardType: TextInputType.number,
                              onSaved: (v) => _bpSystolic = int.tryParse(v ?? ''),
                              validator: (v) {
                                if (v == null || v.isEmpty) return 'Enter BP';
                                if (int.tryParse(v) == null) return 'Enter valid';
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              decoration:
                                  const InputDecoration(labelText: 'BP Diastolic'),
                              keyboardType: TextInputType.number,
                              onSaved: (v) => _bpDiastolic = int.tryParse(v ?? ''),
                              validator: (v) {
                                if (v == null || v.isEmpty) return 'Enter BP';
                                if (int.tryParse(v) == null) return 'Enter valid';
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // Parents history
                      SwitchListTile(
                        title: const Text('Parents had diabetes?'),
                        value: _parentsDiabetes,
                        onChanged: (v) => setState(() => _parentsDiabetes = v),
                      ),

                      const SizedBox(height: 12),

                      ElevatedButton.icon(
                        onPressed: _calculateAndPredict,
                        icon: const Icon(Icons.analytics_outlined),
                        label: const Text('Predict risk'),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Result card
            if (_riskScore != null)
              Card(
                color: _riskLabel == 'High'
                    ? Colors.red[50]
                    : _riskLabel == 'Moderate'
                        ? Colors.orange[50]
                        : Colors.green[50],
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Result for: ${_name.isEmpty ? '—' : _name}',
                          style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('BMI: ${_bmi != null ? _bmi!.toStringAsFixed(1) : '—'}'),
                                Text('BMI category: ${_bmiCategory ?? '—'}'),
                                Text('Risk score: ${_riskScore!.toStringAsFixed(1)}%'),
                                Text('Risk level: ${_riskLabel!}'),
                              ],
                            ),
                          ),
                          SizedBox(
                            width: 100,
                            height: 100,
                            child: Center(
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  SizedBox(
                                    width: 90,
                                    height: 90,
                                    child: CircularProgressIndicator(
                                      value: (_riskScore! / 100.0),
                                      strokeWidth: 10,
                                    ),
                                  ),
                                  Text('${_riskScore!.round()}%'),
                                ],
                              ),
                            ),
                          )
                        ],
                      ),

                      const SizedBox(height: 8),

                      // Short advice
                      Text(
                        _riskLabel == 'High'
                            ? 'Advice: Please consult a physician for tests (HbA1c, OGTT). Lifestyle changes recommended.'
                            : _riskLabel == 'Moderate'
                                ? 'Advice: Monitor diet, physical activity, and recheck levels regularly.'
                                : 'Advice: Low risk — maintain healthy lifestyle and periodic checkups.',
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 16),

            // Footer / quick notes
            Card(
              elevation: 1,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  'Note: This app uses a simple heuristic risk score for demonstration only. It is NOT a medical diagnosis. Replace the `predict` logic with a trained model or backend for production use.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
