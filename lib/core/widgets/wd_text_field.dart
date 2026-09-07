import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../constants/app_icons.dart';
import '../constants/app_strings.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_theme.dart';
import 'wd_icon.dart';

/// Ilovaning yagona input maydoni.
///
/// Dizayn: qora fon ustida bir oz ochiqroq to'ldirilgan quti, chegara faqat
/// fokus va xatolik holatida ko'rinadi.
class WdTextField extends StatefulWidget {
  const WdTextField({
    required this.controller,
    required this.label,
    this.hint,
    this.icon,
    this.keyboardType,
    this.textInputAction,
    this.obscure = false,
    this.autofillHints,
    this.validator,
    this.errorText,
    this.enabled = true,
    this.onSubmitted,
    this.maxLength,
    super.key,
  });

  final TextEditingController controller;
  final String label;
  final String? hint;
  final AppIconData? icon;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;

  /// Parol maydoni: matn yashiriladi va ko'z tugmasi qo'shiladi.
  final bool obscure;

  final Iterable<String>? autofillHints;
  final String? Function(String?)? validator;

  /// Serverdan kelgan xatolik (`fieldErrors`). Lokal validatordan ustun turadi.
  final String? errorText;

  final bool enabled;
  final VoidCallback? onSubmitted;
  final int? maxLength;

  @override
  State<WdTextField> createState() => _WdTextFieldState();
}

class _WdTextFieldState extends State<WdTextField> {
  late bool _obscured = widget.obscure;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasError = widget.errorText != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(widget.label, style: AppTextStyles.sectionLabel),
        ),
        TextFormField(
          controller: widget.controller,
          focusNode: _focusNode,
          enabled: widget.enabled,
          obscureText: _obscured,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          autofillHints: widget.autofillHints,
          validator: widget.validator,
          maxLength: widget.maxLength,
          style: AppTextStyles.body,
          cursorColor: AppColors.primary,
          onFieldSubmitted: (_) => widget.onSubmitted?.call(),
          // Email/parol maydonlarida avtomatik bosh harf keraksiz.
          textCapitalization:
              widget.obscure ||
                  widget.keyboardType == TextInputType.emailAddress
              ? TextCapitalization.none
              : TextCapitalization.words,
          inputFormatters: widget.keyboardType == TextInputType.emailAddress
              ? [FilteringTextInputFormatter.deny(RegExp(r'\s'))]
              : null,
          decoration: InputDecoration(
            counterText: '',
            hintText: widget.hint,
            hintStyle: AppTextStyles.bodyMuted.copyWith(
              color: AppColors.textTertiary,
            ),
            errorText: widget.errorText,
            errorStyle: AppTextStyles.caption.copyWith(color: AppColors.danger),
            filled: true,
            fillColor: AppColors.surfaceInput,
            prefixIcon: widget.icon == null
                ? null
                : WdIcon(
                    widget.icon!,
                    size: 20,
                    color: _focusNode.hasFocus
                        ? AppColors.primary
                        : AppColors.textTertiary,
                  ),
            suffixIcon: widget.obscure
                ? IconButton(
                    onPressed: () => setState(() => _obscured = !_obscured),
                    tooltip: _obscured
                        ? AppStrings.showPassword
                        : AppStrings.hidePassword,
                    icon: WdIcon(
                      _obscured ? AppIcons.eyeOff : AppIcons.eye,
                      size: 20,
                      color: AppColors.textTertiary,
                    ),
                  )
                : null,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 18,
            ),
            border: _border(AppColors.divider),
            enabledBorder: _border(
              hasError ? AppColors.danger : Colors.transparent,
            ),
            focusedBorder: _border(
              hasError ? AppColors.danger : AppColors.primary,
              width: 1.5,
            ),
            errorBorder: _border(AppColors.danger),
            focusedErrorBorder: _border(AppColors.danger, width: 1.5),
            disabledBorder: _border(Colors.transparent),
          ),
        ),
      ],
    );
  }

  OutlineInputBorder _border(Color color, {double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppTheme.radius),
      borderSide: BorderSide(color: color, width: width),
    );
  }
}
