part of 'shared_widgets.dart';

class SelectWidget extends StatefulWidget {
  final String title;
  final List<S2Choice<String>> options;
  final Function(S2Choice<String?>?) optionSelected;
  final S2Choice<String?>? selectedChoice;
  final String textShow;
  final String value;
  final S2ModalType? modalType;
  final bool? modalFilterAuto;
  final bool? modalFilter;
  final bool? useConfirm;
  final bool? disabled;
  final bool? isAlreadySelected;
  const SelectWidget(
      {super.key,
      required this.title,
      required this.options,
      required this.optionSelected,
      this.selectedChoice,
      required this.textShow,
      required this.value,
      this.modalType = S2ModalType.popupDialog,
      this.modalFilterAuto = true,
      this.modalFilter = false,
      this.useConfirm = false,
      this.disabled = false,
      this.isAlreadySelected = false});

  @override
  State<SelectWidget> createState() => _SelectWidgetState();
}

class _SelectWidgetState extends State<SelectWidget> {
  Color containerColor = Colors.grey;
  Color textSelected = AppConfig.appThemeConfig.secondaryColor;
  late Color textInitial;
  String originalText = '';
  @override
  void initState() {
    originalText = widget.textShow;
    textInitial = (!widget.disabled!)
        ? AppConfig.appThemeConfig.primaryColor
        : Colors.grey;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return _rowSm();
  }

  Widget _rowSm() {
    return SmartSelect<String?>.single(
      title: widget.title,
      modalFilter: widget.modalFilter,
      modalFilterAuto: widget.modalFilterAuto,
      modalFilterHint: "Buscar...",
      choiceItems: widget.options,
      modalType: widget.modalType,
      onChange: (v) {
        widget.optionSelected(v.choice);
        FocusScope.of(context).unfocus();
      },
      selectedValue: widget.value,
      selectedChoice: widget.selectedChoice,
      modalConfig: _modalConfig(),
      tileBuilder: _builderContainerSelect,
    );
  }

  S2ModalConfig? _modalConfig() {
    return S2ModalConfig(
      useConfirm: widget.useConfirm!,
      // useFilter: true,
      barrierColor: Colors.black.withOpacity(  0.7),
      style: S2ModalStyle(
        backgroundColor: Colors.white.withOpacity(  0.8),
        clipBehavior: Clip.antiAlias,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(15.0),
          ),
        ),
      ),
      headerStyle: const S2ModalHeaderStyle(
        centerTitle: true,
      ),
    );
  }

  Widget _builderContainerSelect(
      BuildContext context, S2SingleState<String?> state) {
    return GestureDetector(
      onTap: (widget.disabled!)
          ? null
          : () {
              state.showModal();
              //containerColor = ThemeColors.primaryColor;
              setState(() {});
            },
      child: Container(
        padding: const EdgeInsets.all(10),
        height: 45,
        decoration: BoxDecoration(
          //color: Colors.white,
          borderRadius: const BorderRadius.all(Radius.circular(20)),
          border: Border.all(width: 1.0, color: containerColor),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
                child: Text(
              widget.textShow,
              style: TextStyle(
                  color: (widget.isAlreadySelected!)
                      ? textSelected
                      : (originalText == widget.textShow)
                          ? textInitial
                          : textSelected),
            )),
            const Icon(Icons.arrow_drop_down)
          ],
        ),
      ),
    );
  }
}
