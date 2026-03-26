import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hairsaloon/src/features/business_profile/domain/entities/business_profile.dart';
import 'package:hairsaloon/src/features/business_profile/presentation/state/business_profile_scope.dart';
import 'package:hairsaloon/src/features/router/app_routes.dart';

class BusinessRegistrationScreen extends StatefulWidget {
  const BusinessRegistrationScreen({super.key});

  @override
  State<BusinessRegistrationScreen> createState() =>
      _BusinessRegistrationScreenState();
}

class _BusinessRegistrationScreenState
    extends State<BusinessRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();

  String _businessName = '';
  String _phoneNumber = '';
  late final TextEditingController _phoneController;
  String _address = '';

  String? _businessType;
  String? _city;
  String _area = '';

  // These can be expanded later; for now keep minimal defaults.
  final List<String> _businessTypes = const ['Hair Salon'];
  final List<String> _cities = const ['Islamabad'];

  @override
  void initState() {
    super.initState();
    _phoneController = TextEditingController(text: '+92 ');
    _phoneNumber = _phoneController.text.trim();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final borderRadius = BorderRadius.circular(12);

    InputBorder buildBorder(Color color) {
      return OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: BorderSide(color: color),
      );
    }

    final focused = theme.colorScheme.primary;
    final outline = theme.colorScheme.outlineVariant;

    InputDecoration buildDecoration({
      required String hintText,
      Widget? suffixIcon,
    }) {
      return InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.blueGrey.shade300, fontSize: 13),
        isDense: true,
        constraints: const BoxConstraints(minHeight: 56),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        enabledBorder: buildBorder(outline),
        focusedBorder: buildBorder(focused),
        border: buildBorder(outline),
        suffixIcon: suffixIcon,
      );
    }

    final hintStyle = TextStyle(color: Colors.blueGrey.shade300, fontSize: 13);

    return Scaffold(
      backgroundColor: Colors.white,
      body: WillPopScope(
        onWillPop: _onWillPop,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                // IconButton(
                //   onPressed: () => Navigator.of(context).maybePop(),
                //   icon: const Icon(Icons.arrow_back_ios_new_rounded),
                // ),
                const SizedBox(height: 20),
                const Text(
                  'Business Information',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 18),
                TextFormField(
                  textAlignVertical: TextAlignVertical.center,
                  decoration: buildDecoration(hintText: 'Enter Business Name'),
                  onChanged: (value) => _businessName = value.trim(),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter business name.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _phoneController,
                  textAlignVertical: TextAlignVertical.center,
                  decoration: buildDecoration(
                    hintText: 'Enter Phone +92 3xx xxx xxxx',
                  ),
                  keyboardType: TextInputType.phone,
                  onChanged: (value) => _phoneNumber = value.trim(),
                  validator: (value) {
                    final v = value?.trim() ?? '';
                    if (v.isEmpty || v == '+92') {
                      return 'Please enter phone number.';
                    }
                    if (!v.startsWith('+92')) {
                      return 'Phone number must start with +92.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                SizedBox(
                  height: 56,
                  child: DropdownButtonFormField<String>(
                    value: _businessType,
                    icon: const Icon(CupertinoIcons.chevron_down),
                    decoration: buildDecoration(hintText: ''),
                    hint: Text('Select Business Type', style: hintStyle),
                    items: _businessTypes
                        .map(
                          (type) => DropdownMenuItem<String>(
                            value: type,
                            child: Text(type),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      setState(() => _businessType = value);
                    },
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  height: 56,
                  child: DropdownButtonFormField<String>(
                    value: _city,
                    icon: const Icon(CupertinoIcons.chevron_down),
                    decoration: buildDecoration(hintText: ''),
                    hint: Text('Select City', style: hintStyle),
                    items: _cities
                        .map(
                          (city) => DropdownMenuItem<String>(
                            value: city,
                            child: Text(city),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      setState(() => _city = value);
                    },
                  ),
                ),
                const SizedBox(height: 14),
                TextFormField(
                  textAlignVertical: TextAlignVertical.center,
                  decoration: buildDecoration(hintText: 'Enter Area'),
                  onChanged: (value) => _area = value.trim(),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter area.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                SizedBox(
                  height: 56,
                  child: TextFormField(
                    textAlignVertical: TextAlignVertical.center,
                    decoration: buildDecoration(hintText: 'Enter Address'),
                    onChanged: (value) => _address = value.trim(),
                  ),
                ),
                const SizedBox(height: 44),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(borderRadius: borderRadius),
                    ),
                    onPressed: () {
                      final formState = _formKey.currentState;
                      if (formState == null) return;
                      if (!formState.validate()) return;

                      final businessName = _businessName;
                      final phoneNumber = _phoneNumber;
                      if (businessName.isEmpty || phoneNumber.isEmpty) return;

                      if (_businessType == null ||
                          _city == null ||
                          _area.trim().isEmpty) {
                        return;
                      }

                      final profile = BusinessProfile(
                        businessName: _businessName,
                        phoneNumber: _phoneNumber,
                        businessType: _businessType ?? '',
                        city: _city ?? '',
                        area: _area,
                        address: _address.isEmpty
                            ? '$_area, ${_city ?? ''}'
                            : _address,
                      );
                      BusinessProfileScope.of(context).save(profile);

                      Navigator.of(
                        context,
                      ).pushReplacementNamed(AppRoutes.homeShell);
                    },
                    child: const Text(
                      'Register',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<bool> _onWillPop() async {
    final shouldExit = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Exit App'),
        content: const Text('Are you sure you want to exit the app?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Exit'),
          ),
        ],
      ),
    );
    return shouldExit == true;
  }
}
