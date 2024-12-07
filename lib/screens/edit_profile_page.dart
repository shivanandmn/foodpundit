import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_details.dart';
import '../providers/app_auth_provider.dart';
import '../utils/ui_constants.dart';

class EditProfilePage extends StatefulWidget {
  final UserDetails userDetails;
  final String field; // The field being edited: 'name', 'email', 'phone'

  const EditProfilePage({
    Key? key,
    required this.userDetails,
    required this.field,
  }) : super(key: key);

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController _controller;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Initialize controller with current value based on field
    String initialValue = '';
    switch (widget.field) {
      case 'name':
        initialValue = widget.userDetails.displayName ?? '';
        break;
      case 'email':
        initialValue = widget.userDetails.email ?? '';
        break;
      case 'phone':
        initialValue = widget.userDetails.phoneNumber ?? '';
        break;
    }
    _controller = TextEditingController(text: initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String get _fieldTitle {
    switch (widget.field) {
      case 'name':
        return 'Name';
      case 'email':
        return 'Email';
      case 'phone':
        return 'Phone Number';
      default:
        return '';
    }
  }

  String? _validateInput(String? value) {
    if (value == null || value.isEmpty) {
      return 'This field cannot be empty';
    }
    if (widget.field == 'email') {
      final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
      if (!emailRegex.hasMatch(value)) {
        return 'Please enter a valid email address';
      }
    }
    if (widget.field == 'phone') {
      final phoneRegex = RegExp(r'^\+?[\d\s-]{10,}$');
      if (!phoneRegex.hasMatch(value)) {
        return 'Please enter a valid phone number';
      }
    }
    return null;
  }

  Future<void> _saveChanges() async {
    if (_controller.text.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      final authProvider = Provider.of<AppAuthProvider>(context, listen: false);
      UserDetails updatedDetails;

      switch (widget.field) {
        case 'name':
          updatedDetails = widget.userDetails.copyWith(
            displayName: _controller.text,
          );
          break;
        case 'email':
          updatedDetails = widget.userDetails.copyWith(
            email: _controller.text,
          );
          break;
        case 'phone':
          updatedDetails = widget.userDetails.copyWith(
            phoneNumber: _controller.text,
          );
          break;
        default:
          return;
      }

      await authProvider.updateUserDetails(updatedDetails);
      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update ${widget.field}: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit $_fieldTitle'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(UIConstants.spacingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: _fieldTitle,
                hintText: 'Enter your $_fieldTitle',
              ),
              keyboardType: widget.field == 'email'
                  ? TextInputType.emailAddress
                  : widget.field == 'phone'
                      ? TextInputType.phone
                      : TextInputType.text,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: _validateInput,
              enabled: !_isLoading,
            ),
            const SizedBox(height: UIConstants.spacingL),
            ElevatedButton(
              onPressed: _isLoading ? null : _saveChanges,
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : Text('Save $_fieldTitle'),
            ),
          ],
        ),
      ),
    );
  }
}
