import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/address_model.dart';
import '../../providers/address_providers.dart';

class AddAddressScreen extends ConsumerStatefulWidget {
  const AddAddressScreen({super.key});

  @override
  ConsumerState<AddAddressScreen> createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends ConsumerState<AddAddressScreen> {
  final _formKey = GlobalKey<FormState>();
  String _label = 'Home';
  final _streetCtrl = TextEditingController();
  final _apartmentCtrl = TextEditingController();
  final _cityCtrl = TextEditingController(text: 'Addis Ababa');
  final _stateCtrl = TextEditingController();
  final _zipCtrl = TextEditingController();
  bool _isDefault = false;

  @override
  void dispose() {
    _streetCtrl.dispose();
    _apartmentCtrl.dispose();
    _cityCtrl.dispose();
    _stateCtrl.dispose();
    _zipCtrl.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final address = AddressModel(
      label: _label,
      street: _streetCtrl.text.trim(),
      apartment:
          _apartmentCtrl.text.trim().isNotEmpty ? _apartmentCtrl.text.trim() : null,
      city: _cityCtrl.text.trim(),
      state: _stateCtrl.text.trim().isNotEmpty ? _stateCtrl.text.trim() : null,
      zipCode: _zipCtrl.text.trim().isNotEmpty ? _zipCtrl.text.trim() : null,
      isDefault: _isDefault,
    );

    ref.read(addressProvider.notifier).addAddress(address);
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Address')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Label ──
              Text('Label',
                  style: AppTextStyles.body2
                      .copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _label,
                items: const [
                  DropdownMenuItem(value: 'Home', child: Text('🏠 Home')),
                  DropdownMenuItem(value: 'Work', child: Text('🏢 Work')),
                  DropdownMenuItem(value: 'Other', child: Text('📍 Other')),
                ],
                onChanged: (v) => setState(() => _label = v ?? 'Home'),
                decoration: const InputDecoration(),
              ),
              const SizedBox(height: 16),

              // ── Street ──
              TextFormField(
                controller: _streetCtrl,
                decoration: const InputDecoration(
                  labelText: 'Street Address',
                  hintText: 'e.g., Bole Road, near Edna Mall',
                  prefixIcon: Icon(Icons.location_on_outlined),
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Street is required' : null,
              ),
              const SizedBox(height: 14),

              // ── Apartment ──
              TextFormField(
                controller: _apartmentCtrl,
                decoration: const InputDecoration(
                  labelText: 'Apartment / Suite (Optional)',
                  hintText: 'Floor 3, Apt 12',
                  prefixIcon: Icon(Icons.apartment_outlined),
                ),
              ),
              const SizedBox(height: 14),

              // ── City ──
              TextFormField(
                controller: _cityCtrl,
                decoration: const InputDecoration(
                  labelText: 'City',
                  prefixIcon: Icon(Icons.location_city_outlined),
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'City is required' : null,
              ),
              const SizedBox(height: 14),

              // ── State + Zip ──
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _stateCtrl,
                      decoration: const InputDecoration(
                        labelText: 'State / Region',
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _zipCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Zip Code',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // ── Map Placeholder ──
              Container(
                height: 160,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.grey100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.map_outlined,
                        size: 36, color: AppColors.grey400),
                    const SizedBox(height: 8),
                    Text(
                      'Pin location on map',
                      style: AppTextStyles.body2
                          .copyWith(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Coming soon',
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ── Default Switch ──
              SwitchListTile(
                value: _isDefault,
                onChanged: (v) => setState(() => _isDefault = v),
                title: const Text('Set as Default Address'),
                subtitle:
                    const Text('Use this for all future orders'),
                activeColor: AppColors.primary,
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: 24),

              // ── Save Button ──
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Save Address'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
