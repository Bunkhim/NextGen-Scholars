import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:scholarship_app/services/wallpaper_service.dart';

const double fieldMinHeight = 40;
const double labelFontSize = 15;
const double asteriskFontSize = 12;
const double hintFontSize = 14;
const double textFontSize = 14; // input n dropdown item
const double errorFontSize = 10;

// Field Label Widget
class FieldLabel extends StatelessWidget {
  final String label;
  final bool isRequired;

  const FieldLabel({super.key, required this.label, this.isRequired = true});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return RichText(
      text: TextSpan(
        text: label,
        style: TextStyle(
          color: WallpaperService().themedOnSurface(colorScheme),
          fontSize: labelFontSize,
          fontWeight: FontWeight.normal,
        ),
        children: isRequired
            ? [
                TextSpan(
                  text: '*',
                  style: TextStyle(
                    color: colorScheme.error,
                    fontSize: asteriskFontSize,
                  ),
                ),
              ]
            : [],
      ),
    );
  }
}

// Validated Dropdown
class ValidatedDropdown<T> extends StatelessWidget {
  final T? value;
  final String hintText;
  final TextStyle? hintStyle;
  final List<T> items;
  final void Function(T?) onChanged;
  final String? errorText;
  final String Function(T)? itemLabel;

  const ValidatedDropdown({
    super.key,
    required this.value,
    required this.hintText,
    this.hintStyle,
    required this.items,
    required this.onChanged,
    this.errorText,
    this.itemLabel,
  });

  @override
  Widget build(BuildContext context) {
    final hasError = errorText != null && errorText!.isNotEmpty;
    final colorScheme = Theme.of(context).colorScheme;
    final ws = WallpaperService();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(minHeight: fieldMinHeight),
          child: Container(
            decoration: ws.hasTheme
                ? (hasError
                    ? ws.glassInput().copyWith(
                        border: Border.all(color: colorScheme.error, width: 1))
                    : ws.glassInput())
                : BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                    border: hasError
                        ? Border.all(color: colorScheme.error, width: 1)
                        : null,
                  ),
            child: ButtonTheme(
              alignedDropdown: true,
              child: DropdownButtonHideUnderline(
                child: DropdownButton2<T>(
                  value: value,
                  hint: Text(
                    hintText,
                    style: hintStyle ??
                        TextStyle(
                          color: ws.themedOnSurfaceVariant(colorScheme),
                          fontSize: hintFontSize,
                        ),
                  ),
                  style: TextStyle(
                    color: ws.themedOnSurface(colorScheme),
                    fontSize: textFontSize,
                  ),
                  isExpanded: true,
                  iconStyleData: IconStyleData(
                    icon: Icon(
                      Icons.keyboard_arrow_down,
                      color: ws.themedOnSurfaceVariant(colorScheme),
                    ),
                  ),
                  dropdownStyleData: DropdownStyleData(
                    maxHeight: 200,
                    offset: const Offset(0, -5),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: colorScheme.surface,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 0,
                      vertical: 0,
                    ),
                  ),
                  buttonStyleData: ButtonStyleData(
                    height: fieldMinHeight,
                    padding: const EdgeInsets.only(left: 16, right: 16),
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    overlayColor: WidgetStateProperty.all(Colors.transparent),
                  ),
                  menuItemStyleData: const MenuItemStyleData(
                    padding: EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                  ),
                  items: items.map((item) {
                    return DropdownMenuItem<T>(
                      value: item,
                      child: Container(
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.symmetric(
                          vertical: 0,
                          horizontal: 12,
                        ),
                        child: Text(
                          itemLabel != null
                              ? itemLabel!(item)
                              : item.toString(),
                          style: TextStyle(
                            color: colorScheme.onSurface,
                            fontSize: textFontSize,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                  selectedItemBuilder: (BuildContext context) {
                    return items.map((item) {
                      return Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          itemLabel != null
                              ? itemLabel!(item)
                              : item.toString(),
                          style: TextStyle(
                            color: colorScheme.onSurface,
                            fontSize: textFontSize,
                          ),
                        ),
                      );
                    }).toList();
                  },
                  onChanged: onChanged,
                ),
              ),
            ),
          ),
        ),
        if (hasError)
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 12),
            child: Text(
              errorText!,
              style: TextStyle(
                color: colorScheme.error,
                fontSize: errorFontSize,
              ),
            ),
          ),
      ],
    );
  }
}

/// Validated Date Picker Field
class ValidatedDatePickerField extends StatelessWidget {
  final DateTime? selectedDate;
  final VoidCallback onTap;
  final String hintText;
  final String? errorText;

  const ValidatedDatePickerField({
    super.key,
    required this.selectedDate,
    required this.onTap,
    this.hintText = 'dd/mm/yyyy',
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    final hasError = errorText != null && errorText!.isNotEmpty;
    final colorScheme = Theme.of(context).colorScheme;
    final ws = WallpaperService();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(minHeight: fieldMinHeight),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              decoration: ws.hasTheme
                  ? (hasError
                      ? ws.glassInput().copyWith(
                          border:
                              Border.all(color: colorScheme.error, width: 1))
                      : ws.glassInput())
                  : BoxDecoration(
                      color: colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                      border: hasError
                          ? Border.all(color: colorScheme.error, width: 1)
                          : null,
                    ),
              child: Align(
                alignment: Alignment.center,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          selectedDate == null
                              ? hintText
                              : '${selectedDate!.day.toString().padLeft(2, '0')}/${selectedDate!.month.toString().padLeft(2, '0')}/${selectedDate!.year}',
                          style: TextStyle(
                            color: selectedDate == null
                                ? ws.themedOnSurfaceVariant(colorScheme)
                                : ws.themedOnSurface(colorScheme),
                            fontSize: hintFontSize,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(Icons.date_range_outlined,
                          color: ws.themedOnSurfaceVariant(colorScheme)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        if (hasError)
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 12),
            child: Text(
              errorText!,
              style: TextStyle(
                color: colorScheme.error,
                fontSize: errorFontSize,
              ),
            ),
          ),
      ],
    );
  }
}

// Validated Image Picker Button
class ValidatedImagePickerButton extends StatelessWidget {
  final VoidCallback onTap;
  final String text;
  final bool hasImage;
  final String? errorText;

  const ValidatedImagePickerButton({
    super.key,
    required this.onTap,
    required this.text,
    this.hasImage = false,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    final hasError = errorText != null && errorText!.isNotEmpty;
    final colorScheme = Theme.of(context).colorScheme;
    final ws = WallpaperService();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(minHeight: fieldMinHeight),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              decoration: ws.hasTheme
                  ? (hasError
                      ? ws.glassInput().copyWith(
                          border:
                              Border.all(color: colorScheme.error, width: 1))
                      : ws.glassInput())
                  : BoxDecoration(
                      color: colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                      border: hasError
                          ? Border.all(color: colorScheme.error, width: 1)
                          : null,
                    ),
              child: Align(
                alignment: Alignment.center,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Icon(
                        Icons.camera_alt_outlined,
                        color: ws.themedOnSurfaceVariant(colorScheme),
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Flexible(
                        child: Text(
                          text,
                          style: TextStyle(
                            fontSize: hintFontSize,
                            color: ws.themedOnSurfaceVariant(colorScheme),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        if (hasError)
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 12),
            child: Text(
              errorText!,
              style: TextStyle(
                color: colorScheme.error,
                fontSize: errorFontSize,
              ),
            ),
          ),
      ],
    );
  }
}

// Custom Text Input
class CustomTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final TextStyle? hintStyle;
  final String? Function(String?)? validator;
  final String? errorText;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final Widget? suffixIcon;
  final int? maxLines;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.hintStyle,
    this.validator,
    this.errorText,
    this.keyboardType,
    this.inputFormatters,
    this.suffixIcon,
    this.maxLines = 1,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

// Custom Text Input State
class _CustomTextFieldState extends State<CustomTextField> {
  late String? _internalError;

  @override
  void initState() {
    super.initState();
    _internalError = widget.errorText;
  }

  @override
  void didUpdateWidget(CustomTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.errorText != oldWidget.errorText) {
      setState(() {
        _internalError = widget.errorText;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasError = _internalError != null && _internalError!.isNotEmpty;
    final colorScheme = Theme.of(context).colorScheme;
    final ws = WallpaperService();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(minHeight: fieldMinHeight),
          child: Container(
            decoration: ws.hasTheme
                ? (hasError
                    ? ws.glassInput().copyWith(
                        border: Border.all(color: colorScheme.error, width: 1))
                    : ws.glassInput())
                : BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                    border: hasError
                        ? Border.all(color: colorScheme.error, width: 1)
                        : null,
                  ),
            child: Center(
              child: TextFormField(
                controller: widget.controller,
                keyboardType: widget.keyboardType,
                inputFormatters: widget.inputFormatters,
                maxLines: widget.maxLines,
                style: TextStyle(
                  fontSize: textFontSize,
                  color: ws.themedOnSurface(colorScheme),
                ),
                textAlignVertical: TextAlignVertical.center,
                decoration: InputDecoration(
                  hintText: widget.hintText,
                  hintStyle: widget.hintStyle ??
                      TextStyle(
                        color: ws.themedOnSurfaceVariant(colorScheme),
                        fontSize: hintFontSize,
                      ),
                  filled: true,
                  fillColor: Colors.transparent,
                  suffixIcon: widget.suffixIcon,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 0,
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  focusedErrorBorder: InputBorder.none,
                  errorStyle: const TextStyle(
                    height: 0,
                    fontSize: 0, //text field inline error font size (hidden)
                  ),
                ),
                validator: (value) {
                  final error = widget.validator?.call(value);
                  setState(() {
                    _internalError = error;
                  });
                  return null;
                },
              ),
            ),
          ),
        ),
        if (_internalError != null && _internalError!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 12),
            child: Text(
              _internalError!,
              style: TextStyle(
                color: colorScheme.error,
                fontSize: errorFontSize,
              ),
            ),
          ),
      ],
    );
  }
}

// Custom Dropdown
class CustomDropdown<T> extends StatelessWidget {
  final T? value;
  final String hintText;
  final TextStyle? hintStyle;
  final List<T> items;
  final void Function(T?) onChanged;
  final Widget? suffixIcon;
  final String Function(T)? itemLabel;

  const CustomDropdown({
    super.key,
    required this.value,
    required this.hintText,
    this.hintStyle,
    required this.items,
    required this.onChanged,
    this.suffixIcon,
    this.itemLabel,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: fieldMinHeight),
      child: Center(
        child: DropdownButtonFormField<T>(
          initialValue: value,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: hintStyle ??
                TextStyle(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: hintFontSize,
                ),
            filled: true,
            fillColor: colorScheme.surfaceContainerHighest,
            suffixIcon: suffixIcon,
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 0,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: colorScheme.primary, width: 2),
            ),
          ),
          isExpanded: true,
          icon: Icon(Icons.keyboard_arrow_down,
              color: colorScheme.onSurfaceVariant),
          items: items.map((item) {
            return DropdownMenuItem<T>(
              value: item,
              child: Text(
                itemLabel != null ? itemLabel!(item) : item.toString(),
                style: TextStyle(
                  fontSize: textFontSize,
                  color: colorScheme.onSurface,
                ),
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

// Form Field Container
class FormFieldContainer extends StatelessWidget {
  final Widget child;
  final double bottomPadding;

  const FormFieldContainer({
    super.key,
    required this.child,
    this.bottomPadding = 15,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: bottomPadding),
      child: child,
    );
  }
}
