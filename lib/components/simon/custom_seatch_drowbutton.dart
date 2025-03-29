import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:simon_final/main.dart';
import 'package:simon_final/screens_export.dart';
import 'package:simon_final/utils/colors.dart';
import 'package:simon_final/utils/common.dart';


class CustomDropdownSearch<T> extends StatelessWidget {
  final String hintText;
  final T? value;
  final List<DropdownMenuItem<T>>? items;
  final void Function(T?)? onChanged;
  final String? Function(T?)? validator;
  final bool enabled;
  final FocusNode? focusNode;
  final TextEditingController searchController;
  final void Function(String)? onSearchChanged;
  final String? disabledHint;
  final bool showSearch;

  const CustomDropdownSearch({
    super.key,
    required this.hintText,
    required this.value,
    required this.items,
    required this.onChanged,
    this.validator,
    this.enabled = true,
    this.focusNode,
    required this.searchController,
    this.onSearchChanged,
    this.disabledHint,
    this.showSearch = true,
  });

  @override
  Widget build(BuildContext context) {
    return AbsorbPointer(
      absorbing: !enabled,
      child: DropdownButtonFormField2<T>(
        isExpanded: true,
        isDense: true,
        disabledHint: Text(
          disabledHint ?? hintText,
          style: TextStyle(
            fontSize: 14,
            color: enabled ? Colors.black : Colors.grey,
          ),
        ),
        hint: Text(
          hintText,
          style: TextStyle(
            fontSize: 14,
            color: Theme.of(context).hintColor,
          ),
        ),
        items: items,
        value: value,
        onChanged: onChanged,
        validator: validator,
        focusNode: focusNode,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          fillColor: appStore.isDarkMode ? scaffoldSecondaryDark : Colors.white,
          filled: true,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(DEFAULT_RADIUS),
            borderSide: const BorderSide(color: borderColor, width: 1),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(DEFAULT_RADIUS),
            borderSide: const BorderSide(color: simonNaranja, width: 1),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(DEFAULT_RADIUS),
            borderSide: const BorderSide(color: simon_finalPrimaryColor, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(DEFAULT_RADIUS),
            borderSide: const BorderSide(color: simon_finalPrimaryColor, width: 1),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(DEFAULT_RADIUS),
            borderSide: const BorderSide(color: resendColor, width: 1),
          ),
        ),
        buttonStyleData: ButtonStyleData(
          padding: const EdgeInsets.only(right: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(DEFAULT_RADIUS),
          ),
        ),
        iconStyleData: IconStyleData(
          icon: Icon(
            Icons.arrow_drop_down,
            color: enabled ? Colors.black45 : Colors.grey,
          ),
          iconSize: 24,
        ),
        dropdownStyleData: DropdownStyleData(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(DEFAULT_RADIUS),
            color: appStore.isDarkMode ? scaffoldDarkColor : Colors.white,
          ),
        ),
        menuItemStyleData: const MenuItemStyleData(
          padding: EdgeInsets.symmetric(horizontal: 16),
        ),
        dropdownSearchData: showSearch && enabled
            ? DropdownSearchData(
                searchController: searchController,
                searchInnerWidgetHeight: 50,
                searchInnerWidget: Container(
                  height: 50,
                  padding: const EdgeInsets.only(
                    top: 8,
                    bottom: 4,
                    right: 8,
                    left: 8,
                  ),
                  child: TextFormField(
                    controller: searchController,
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      hintText: 'Buscar...',
                      hintStyle: const TextStyle(fontSize: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(DEFAULT_RADIUS),
                      ),
                    ),
                    onChanged: onSearchChanged,
                  ),
                ),
                searchMatchFn: (item, searchValue) {
                  return item.value.toString().toLowerCase().contains(
                        searchValue.toLowerCase(),
                      );
                },
              )
            : null,
        onMenuStateChange: (isOpen) {
          if (!isOpen && enabled) {
            searchController.clear();
            onSearchChanged?.call('');
          }
        },
      ),
    );
  }
}