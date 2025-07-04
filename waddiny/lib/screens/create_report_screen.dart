import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/report_model.dart';
import '../l10n/app_localizations.dart';
import '../main.dart';

class CreateReportScreen extends StatefulWidget {
  const CreateReportScreen({Key? key}) : super(key: key);

  @override
  _CreateReportScreenState createState() => _CreateReportScreenState();
}

class _CreateReportScreenState extends State<CreateReportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _categoryController = TextEditingController();

  final _apiService = ApiService();
  bool _isLoading = false;

  String _selectedType = 'BUG_REPORT';
  String _selectedPriority = 'MEDIUM';

  final List<Map<String, String>> _reportTypes = [
    {'value': 'BUG_REPORT', 'label': 'bugReport'},
    {'value': 'FEATURE_REQUEST', 'label': 'featureRequest'},
    {'value': 'COMPLAINT', 'label': 'complaint'},
    {'value': 'SUGGESTION', 'label': 'suggestion'},
    {'value': 'TECHNICAL_ISSUE', 'label': 'technicalIssue'},
    {'value': 'OTHER', 'label': 'other'},
  ];

  final List<Map<String, String>> _priorities = [
    {'value': 'LOW', 'label': 'low'},
    {'value': 'MEDIUM', 'label': 'medium'},
    {'value': 'HIGH', 'label': 'high'},
    {'value': 'URGENT', 'label': 'urgent'},
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  String _getLocalizedString(BuildContext context, String key) {
    switch (key) {
      case 'bugReport':
        return getLocalizations(context).bugReport;
      case 'featureRequest':
        return getLocalizations(context).featureRequest;
      case 'complaint':
        return getLocalizations(context).complaint;
      case 'suggestion':
        return getLocalizations(context).suggestion;
      case 'technicalIssue':
        return getLocalizations(context).technicalIssue;
      case 'other':
        return getLocalizations(context).other;
      case 'low':
        return getLocalizations(context).low;
      case 'medium':
        return getLocalizations(context).medium;
      case 'high':
        return getLocalizations(context).high;
      case 'urgent':
        return getLocalizations(context).urgent;
      default:
        return key;
    }
  }

  Future<void> _submitReport() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _apiService.createReport(
        type: _selectedType,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        priority: _selectedPriority,
        category: _categoryController.text.trim().isEmpty
            ? null
            : _categoryController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(getLocalizations(context).reportSubmitted),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(getLocalizations(context).errorSubmittingReport),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(getLocalizations(context).createReport),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Report Type
              Text(
                getLocalizations(context).reportType,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedType,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
                items: _reportTypes.map((type) {
                  return DropdownMenuItem<String>(
                    value: type['value'],
                    child: Text(_getLocalizedString(context, type['label']!)),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedType = value!;
                  });
                },
              ),
              const SizedBox(height: 24),

              // Priority
              Text(
                getLocalizations(context).reportPriority,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedPriority,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
                items: _priorities.map((priority) {
                  return DropdownMenuItem<String>(
                    value: priority['value'],
                    child:
                        Text(_getLocalizedString(context, priority['label']!)),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedPriority = value!;
                  });
                },
              ),
              const SizedBox(height: 24),

              // Title
              Text(
                getLocalizations(context).reportTitle,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  hintText: getLocalizations(context).reportTitle,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Title is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Category (optional)
              Text(
                getLocalizations(context).reportCategory,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _categoryController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  hintText: getLocalizations(context).reportCategory,
                ),
              ),
              const SizedBox(height: 24),

              // Description
              Text(
                getLocalizations(context).reportDescription,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descriptionController,
                maxLines: 5,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  hintText: getLocalizations(context).reportDescription,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Description is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitReport,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          getLocalizations(context).submitReport,
                          style: const TextStyle(fontSize: 16),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
