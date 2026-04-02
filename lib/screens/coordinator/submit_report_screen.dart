import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/property_model.dart';
import '../../services/property_service.dart';
import '../../services/notification_service.dart';
import '../../theme/app_theme.dart';

class SubmitReportScreen extends StatefulWidget {
  final Property? preselectedProperty;
  
  const SubmitReportScreen({super.key, this.preselectedProperty});

  @override
  State<SubmitReportScreen> createState() => _SubmitReportScreenState();
}

class _SubmitReportScreenState extends State<SubmitReportScreen> {
  List<Property> _assignedProperties = [];
  Property? _selectedProperty;
  bool _isLoading = true;
  final TextEditingController _reportController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedProperty = widget.preselectedProperty;
    _loadProperties();
  }

  Future<void> _loadProperties() async {
    final user = Provider.of<AuthProvider>(context, listen: false).currentUser;
    if (user != null) {
      final properties = await PropertyService().getAssignedProperties(user.id);
      if (mounted) {
        setState(() {
          _assignedProperties = properties;
          _isLoading = false;
        });
      }
    }
  }

  void _submitReport() async {
    if (_selectedProperty == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a property.')));
      return;
    }
    if (_reportController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter inspection details.')));
      return;
    }

    // Mock submission duration
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;
    Navigator.pop(context); // close dialog

    // Send mock notification
    NotificationService().addNotification(
      'Inspection Completed',
      'The coordinator has submitted an inspection report for ${_selectedProperty!.propertyName}',
      forUserId: _selectedProperty!.ownerId,
    );

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Inspection report submitted successfully.')));
    context.pop(); // Go back
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Submit Inspection Report'),
        ),
        body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('Select Assigned Property', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<Property>(
                    isExpanded: true,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    value: _selectedProperty,
                    hint: const Text('Choose a property to report on...'),
                    items: _assignedProperties.map((p) => DropdownMenuItem(
                      value: p,
                      child: Text('${p.propertyName} - ${p.propertyAddress}'),
                    )).toList(),
                    onChanged: (val) => setState(() => _selectedProperty = val),
                  ),
                  const SizedBox(height: 24),
                  const Text('Inspection Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _reportController,
                    maxLines: 6,
                    decoration: InputDecoration(
                      hintText: 'Enter observation details, issues found, or routine checkups here...',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text('Upload Attachments', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('File picker opened.')));
                    },
                    child: Container(
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300, style: BorderStyle.none),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.cloud_upload_outlined, size: 48, color: AppColors.primary.withOpacity(0.5)),
                            const SizedBox(height: 8),
                            const Text('Tap to upload photos or PDFs', style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  ElevatedButton(
                    onPressed: _submitReport,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Submit Final Report', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
      ),
    );
  }
}
