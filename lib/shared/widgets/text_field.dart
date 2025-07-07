part of 'shared_widgets.dart';

// ignore: must_be_immutable
class TextFieldWidget extends StatefulWidget {
  Function(String value) onChanged;
  String? label;
  bool? enabled;
  TextEditingController? controller;
  TextInputType? textInputType = TextInputType.text;
  List<TextInputFormatter>? inputFormatter;
  String? hinText;
  String? errorText;
  bool? obscureText = false;
  bool? isValid = true;
  int? maxLines;
  bool? multiline = false;
  int? maxLength;
  Color? fontColor;
  Color? focusColor;
  Widget? suffixIcon = const Icon(Icons.add);
  String? prefixText = '';
  TextCapitalization? textCapitalization;
  void Function()? ontap;
  void Function()? onEditingComplete;
  FocusNode? focusNode;

  TextFieldWidget(
      {super.key,
      required this.onChanged,
      this.label,
      this.enabled,
      this.hinText,
      this.errorText,
      this.suffixIcon,
      this.prefixText,
      this.obscureText,
      this.isValid,
      this.textInputType,
      this.inputFormatter,
      this.maxLines,
      this.maxLength,
      this.fontColor,
      this.focusColor,
      this.controller,
      this.textCapitalization,
      this.ontap,
      this.multiline,
      this.focusNode,
      this.onEditingComplete});

  @override
  State<TextFieldWidget> createState() => _TextFieldWidgetState();
}

class _TextFieldWidgetState extends State<TextFieldWidget> {
  @override
  Widget build(BuildContext context) {
    widget.multiline = widget.multiline ?? true;
    widget.isValid = widget.isValid ?? true;
    widget.textCapitalization =
        widget.textCapitalization ??= TextCapitalization.none;
    return TextField(
      focusNode: widget.focusNode,
      onEditingComplete: widget.onEditingComplete,
      onTap: widget.ontap,
      enabled: widget.enabled,
      textCapitalization: widget.textCapitalization!,
      controller: widget.controller,
      onChanged: widget.onChanged,
      maxLines: widget.obscureText == true ? 1 : widget.maxLines,
      maxLength: widget.maxLength,
      keyboardType: widget.textInputType,
      obscureText: widget.obscureText ?? false,
      inputFormatters: widget.inputFormatter,
      style: TextStyle(
        height: widget.multiline! ? 1.8 : 1,
        color: widget.fontColor ?? AppConfig.appThemeConfig.secondaryColor,
      ),
      cursorColor: widget.focusColor ?? AppConfig.appThemeConfig.primaryColor,
      decoration: InputDecoration(
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
                color: (widget.isValid!)
                    ? widget.focusColor ?? AppConfig.appThemeConfig.primaryColor
                    : Colors.red,
                width: 2.0),
            borderRadius: BorderRadius.circular(25.0),
          ),
          contentPadding: EdgeInsets.only(
              right: 5, top: widget.multiline! ? 20 : 6, bottom: 5, left: 10),
          border: OutlineInputBorder(
            gapPadding: 1,
            borderRadius: BorderRadius.circular(
                AppConfig.appThemeConfig.circularBorderTextField),
          ),
          label: Text(
            widget.label ?? "",
            style: TextStyle(
                color: (widget.isValid!)
                    ? widget.focusColor ?? AppConfig.appThemeConfig.primaryColor
                    : Colors.red),
          ),
          hintText: widget.hinText,
          errorText: widget.errorText,
          suffixIcon: widget.suffixIcon,
          prefixText: widget.prefixText),
    );
  }
}
