import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../features/subscriptions/models/subscription_model.dart';
import '../../../features/subscriptions/providers/subscription_provider.dart';
import '../../../features/subscriptions/providers/subscription_preferences_provider.dart'; // ADD THIS
import '../../../core/widgets/common/dialog_wrapper.dart';
import '../../../core/widgets/common/dialog_header.dart';
import '../../../core/widgets/common/dialog_actions.dart';
import '../../../core/widgets/form/form_text_field.dart';
import '../../../core/widgets/form/form_dropdown.dart';
import '../../../core/widgets/form/form_date_picker.dart';
import '../../../core/widgets/form/form_switch.dart';
import '../../../core/widgets/common/app_snackbar.dart';
import '../../../features/subscriptions/widgets/subscription_form_fields.dart';

class AddSubscriptionDialog extends StatefulWidget {
  const AddSubscriptionDialog({super.key});

  @override
  State<AddSubscriptionDialog> createState() => _AddSubscriptionDialogState();
}

class _AddSubscriptionDialogState extends State<AddSubscriptionDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  final _categoryController = TextEditingController();
  final _descriptionController = TextEditingController();

  BillingCycle _selectedBillingCycle = BillingCycle.monthly;
  DateTime _nextBillingDate = DateTime.now().add(const Duration(days: 30));
  bool _isActive = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _categoryController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _nextBillingDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: Theme.of(context).colorScheme.primary,
                ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _nextBillingDate) {
      setState(() => _nextBillingDate = picked);
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final subscription = Subscription(
        id: '',
        name: _nameController.text.trim(),
        amount: double.parse(_amountController.text.trim()),
        billingCycle: _selectedBillingCycle,
        nextBillingDate: _nextBillingDate,
        category: _categoryController.text.trim().isEmpty
            ? null
            : _categoryController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        isActive: _isActive,
      );

      await context.read<SubscriptionProvider>().addSubscription(subscription);

      final provider = context.read<SubscriptionProvider>();
      if (provider.error != null) {
        throw Exception(provider.error);
      }

      if (mounted) {
        Navigator.of(context).pop();
        AppSnackBar.showSuccess(context, 'Subscription added successfully!');
      }
    } catch (e) {
      if (mounted) {
        AppSnackBar.showError(
          context,
          'Failed to add subscription: ${e.toString()}',
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
    final textTheme = Theme.of(context).textTheme;
    final prefs = context.watch<SubscriptionPreferencesProvider>(); // ADD THIS

    return DialogWrapper(
      header: const DialogHeader(
        icon: Icons.add_circle_outline,
        title: 'Add Subscription',
        subtitle: 'Track your recurring payments',
      ),
      content: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FormTextField(
              controller: _nameController,
              label: 'Subscription Name',
              hint: 'e.g., Netflix, Spotify',
              icon: Icons.business_outlined,
              validator: SubscriptionFormFields.validateName,
            ),
            const SizedBox(height: 20),
            FormTextField(
              controller: _amountController,
              label: 'Amount (${prefs.currency})', // UPDATED - Show currency
              hint: prefs.showCents ? '0.00' : '0', // UPDATED - Adjust hint
              icon: Icons.attach_money,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: SubscriptionFormFields.amountFormatters,
              validator: SubscriptionFormFields.validateAmount,
            ),
            const SizedBox(height: 20),
            FormDropdown<BillingCycle>(
              value: _selectedBillingCycle,
              label: 'Billing Cycle',
              icon: Icons.calendar_today_outlined,
              items: SubscriptionFormFields.buildBillingCycleItems(textTheme),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedBillingCycle = value);
                }
              },
            ),
            const SizedBox(height: 20),
            FormDatePicker(
              label: 'Next Billing Date',
              icon: Icons.event_outlined,
              date: _nextBillingDate,
              onTap: () => _selectDate(context),
            ),
            const SizedBox(height: 20),
            FormTextField(
              controller: _categoryController,
              label: 'Category (Optional)',
              hint: 'e.g., Entertainment, Software',
              icon: Icons.category_outlined,
            ),
            const SizedBox(height: 20),
            FormTextField(
              controller: _descriptionController,
              label: 'Description (Optional)',
              hint: 'Add any notes...',
              icon: Icons.notes_outlined,
              maxLines: 3,
            ),
            const SizedBox(height: 20),
            FormSwitch(
              value: _isActive,
              onChanged: (value) => setState(() => _isActive = value),
              title: 'Active Subscription',
              activeSubtitle: 'This subscription is currently active',
              inactiveSubtitle: 'This subscription is paused/inactive',
            ),
          ],
        ),
      ),
      actions: DialogActions(
        onCancel: () => Navigator.of(context).pop(),
        onSubmit: _submitForm,
        submitText: 'Add',
        isLoading: _isLoading,
      ),
    );
  }
}