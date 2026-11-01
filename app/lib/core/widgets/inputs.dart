import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../l10n/l10n_ext.dart';
import '../theme/aman_palette.dart';
import '../theme/aman_spacing.dart';
import '../utils/phone.dart';
import '../utils/validators.dart';

/// Rounded search box used on catalog screens.
class SearchField extends StatelessWidget {
  const SearchField({
    super.key,
    required this.hint,
    required this.onChanged,
    this.controller,
    this.onFilterTap,
    this.filterBadge = 0,
    this.autofocus = false,
  });

  final String hint;
  final ValueChanged<String> onChanged;
  final TextEditingController? controller;
  final VoidCallback? onFilterTap;
  final int filterBadge;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            autofocus: autofocus,
            onChanged: onChanged,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: hint,
              prefixIcon: Icon(Icons.search_rounded, color: p.textSecondary),
              contentPadding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
        if (onFilterTap != null) ...[
          const SizedBox(width: 10),
          Tooltip(
            message: context.l10n.filtersTitle,
            child: Material(
              color: p.primary,
              borderRadius: Corners.buttonRadius,
              child: InkWell(
                borderRadius: Corners.buttonRadius,
                onTap: onFilterTap,
                child: SizedBox(
                  width: 52,
                  height: 52,
                  child: Badge(
                    isLabelVisible: filterBadge > 0,
                    label: Text('$filterBadge'),
                    child: const Icon(Icons.tune_rounded, color: Colors.white),
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// Selectable pill used for specialties, categories and filters.
class AmanFilterChip extends StatelessWidget {
  const AmanFilterChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          color: selected ? p.primary : p.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: selected ? p.primary : p.border),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(
                      icon,
                      size: 16,
                      color: selected ? Colors.white : p.primary,
                    ),
                    const SizedBox(width: 6),
                  ],
                  Flexible(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: selected ? Colors.white : p.textPrimary,
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
}

/// Labeled text field with validation using [Validators] error codes.
class AmanTextField extends StatelessWidget {
  const AmanTextField({
    super.key,
    required this.label,
    this.controller,
    this.validator,
    this.keyboardType,
    this.obscure = false,
    this.hint,
    this.maxLines = 1,
    this.textInputAction,
    this.onChanged,
    this.prefix,
    this.suffix,
    this.inputFormatters,
    this.autofillHints,
    this.onFieldSubmitted,
    this.enabled = true,
    this.maxLength,
  });

  final String label;
  final TextEditingController? controller;
  final FieldError? Function(String?)? validator;
  final TextInputType? keyboardType;
  final bool obscure;
  final String? hint;
  final int maxLines;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onChanged;
  final Widget? prefix;
  final Widget? suffix;
  final List<TextInputFormatter>? inputFormatters;
  final Iterable<String>? autofillHints;
  final ValueChanged<String>? onFieldSubmitted;
  final bool enabled;
  final int? maxLength;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final p = context.palette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelMedium
                ?.copyWith(color: p.textSecondary),
          ),
        ),
        TextFormField(
          controller: controller,
          enabled: enabled,
          obscureText: obscure,
          keyboardType: keyboardType,
          maxLines: maxLines,
          maxLength: maxLength,
          textInputAction: textInputAction,
          onChanged: onChanged,
          onFieldSubmitted: onFieldSubmitted,
          inputFormatters: inputFormatters,
          autofillHints: autofillHints,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: prefix,
            suffixIcon: suffix,
            counterText: '',
          ),
          validator: validator == null
              ? null
              : (v) => validator!(v)?.message(l),
        ),
      ],
    );
  }
}

class _KzPhoneFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final masked = KzPhone.maskNational(KzPhone.nationalDigits(newValue.text));
    return TextEditingValue(
      text: masked,
      selection: TextSelection.collapsed(offset: masked.length),
    );
  }
}

/// Phone input with a fixed +7 prefix and progressive masking.
class KzPhoneField extends StatelessWidget {
  const KzPhoneField({
    super.key,
    required this.controller,
    this.label,
    this.onSubmitted,
    this.enabled = true,
  });

  final TextEditingController controller;
  final String? label;
  final ValueChanged<String>? onSubmitted;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final p = context.palette;
    return AmanTextField(
      label: label ?? l.phoneLabel,
      controller: controller,
      enabled: enabled,
      hint: l.phoneHint,
      keyboardType: TextInputType.phone,
      textInputAction: TextInputAction.next,
      autofillHints: const [AutofillHints.telephoneNumberNational],
      inputFormatters: [_KzPhoneFormatter()],
      onFieldSubmitted: onSubmitted,
      prefix: Padding(
        padding: const EdgeInsets.only(left: 16, right: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🇰🇿', style: TextStyle(fontSize: 18)),
            const SizedBox(width: 8),
            Text(
              '+7',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: p.textPrimary,
              ),
            ),
          ],
        ),
      ),
      validator: Validators.phone,
    );
  }
}

/// Password input with visibility toggle.
class PasswordField extends StatefulWidget {
  const PasswordField({
    super.key,
    required this.controller,
    required this.label,
    this.validator = Validators.password,
    this.textInputAction = TextInputAction.done,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final String label;
  final FieldError? Function(String?) validator;
  final TextInputAction textInputAction;
  final ValueChanged<String>? onSubmitted;

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _hidden = true;

  @override
  Widget build(BuildContext context) {
    return AmanTextField(
      label: widget.label,
      controller: widget.controller,
      obscure: _hidden,
      textInputAction: widget.textInputAction,
      onFieldSubmitted: widget.onSubmitted,
      autofillHints: const [AutofillHints.password],
      validator: widget.validator,
      suffix: IconButton(
        icon: Icon(
          _hidden ? Icons.visibility_off_rounded : Icons.visibility_rounded,
        ),
        onPressed: () => setState(() => _hidden = !_hidden),
      ),
    );
  }
}
