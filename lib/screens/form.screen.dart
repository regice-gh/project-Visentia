import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class SentimentScreen extends StatefulWidget {
  const SentimentScreen({super.key});

  @override
  State<SentimentScreen> createState() => _SentimentScreenState();
}

class _SentimentScreenState extends State<SentimentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _messageController = TextEditingController();
  bool _showSuccess = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _submit() {
    setState(() {
      _showSuccess = false;
    });

    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    setState(() {
      _showSuccess = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Form submitted successfully!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Form'),
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.screenPadding,
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Enter your details below. Validation ensures every field is completed correctly before submission.',
                style: theme.textTheme.bodyLarge,
              ),
              const SizedBox(height: AppSpacing.section),
              TextFormField(
                controller: _nameController,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Full name',
                  hintText: 'e.g. John Doe',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your full name';
                  }
                  if (value.trim().length < 3) {
                    return 'Name must be at least 3 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.item),
              TextFormField(
                controller: _emailController,
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email address',
                  hintText: 'name@example.com',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Email is required';
                  }
                  final emailRegex = RegExp(
                    r'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$',
                  );
                  if (!emailRegex.hasMatch(value.trim())) {
                    return 'Enter a valid email address';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.item),
              TextFormField(
                controller: _messageController,
                textInputAction: TextInputAction.done,
                minLines: 3,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Message',
                  hintText: 'Describe your project idea or feedback',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please provide a message';
                  }
                  if (value.trim().length < 10) {
                    return 'Message should be at least 10 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.section),
              ElevatedButton(
                onPressed: _submit,
                child: const Text('Submit form'),
              ),
              if (_showSuccess) ...[
                const SizedBox(height: AppSpacing.section),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.section),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Submission preview',
                          style: theme.textTheme.titleMedium,
                        ),
                        const SizedBox(height: AppSpacing.item),
                        Text('Name: ${_nameController.text.trim()}'),
                        Text('Email: ${_emailController.text.trim()}'),
                        const SizedBox(height: AppSpacing.small),
                        Text('Message:'),
                        const SizedBox(height: AppSpacing.small),
                        Text(
                          _messageController.text.trim(),
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
