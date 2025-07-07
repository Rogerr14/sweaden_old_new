part of 'shared_widgets.dart';

class DatePickerWidget extends StatefulWidget {
  final String label;
  final TextEditingController calendarController;
  final DateTime? firstDate;
  final bool? isDateOut;
  final void Function()? validator;
  // final bool isLastDate;
  const DatePickerWidget({
    super.key,
    required this.label,
    required this.calendarController,
    this.firstDate,
    this.isDateOut =false,
    this.validator
    // this.isLastDate = false,
  });

  @override
  State<DatePickerWidget> createState() => _DatePickerWidgetState();
}

class _DatePickerWidgetState extends State<DatePickerWidget> {
  // DateTime? currentTime = DateTime.now();

  @override
  Widget build(BuildContext context) {
    DateTime? currentTime2;
    DateTime? firstDate = widget.firstDate;
    // final noveltyProvider = Provider.of<NoveltyProvider>(context);
    DateTime now = DateTime.now();
    return TextField(
        controller: widget.calendarController,
        readOnly: true,
        onTap: () async {
          currentTime2 = await showDatePicker(
              context: context,
              locale: const Locale('es'),
              initialDatePickerMode: DatePickerMode.day,
              initialDate: (widget.isDateOut!)?DateTime(now.year, (now.month+1), now.day):DateTime.now(),
              firstDate: firstDate ?? DateTime.now(),
              lastDate: DateTime(2043),
              currentDate: (widget.isDateOut!)?DateTime(now.year, (now.month+1), now.day):DateTime.now(),
              builder: (context, child) {
                return Theme(
                  data: ThemeData.light().copyWith(
                    colorScheme: ColorScheme.light(
                      primary: AppConfig.appThemeConfig
                          .secondaryColor, // header background color
                      onPrimary: AppConfig
                          .appThemeConfig.primaryColor, // header text color
                      onSurface: AppConfig.appThemeConfig.tertiaryColor,
                    ),
                    buttonTheme: const ButtonThemeData(
                        textTheme: ButtonTextTheme.primary),
                  ),
                  child: child!,
                );
              });
          if (currentTime2 != null) {
            widget.calendarController.text = _getDate(currentTime2!);
            if(widget.calendarController.text.trim().isNotEmpty){
              widget.validator != null ? widget.validator!() : null;
            }
            // print(widget.calendarController.text);
            // setState(() {});
          }
        },
        decoration: InputDecoration(
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
                color: AppConfig.appThemeConfig.primaryColor, width: 2.0),
            borderRadius: BorderRadius.circular(25.0),
          ),
          contentPadding:
              const EdgeInsets.only(right: 5, top: 6, bottom: 5, left: 10),
          border: OutlineInputBorder(
            gapPadding: 1,
            borderRadius: BorderRadius.circular(25.0),
          ),
          label: Text(widget.label,
              style: TextStyle(color: AppConfig.appThemeConfig.primaryColor)),
          suffixIcon: Icon(
            Icons.calendar_today,
            color: AppConfig.appThemeConfig.secondaryColor,
          ),
        ));
  }

  String _getDate(DateTime dateSelected) {
    return dateSelected.toString().split(" ")[0];
  }
}

class TimePickerWidget extends StatefulWidget {
  final TextEditingController timePickerController;
  // final DateTime choosenDate;
  final String label;
  final void Function()? validator;
  const TimePickerWidget({
    super.key,
    required this.timePickerController,
    required this.label,
    this.validator,
  });

  @override
  State<TimePickerWidget> createState() => _TimePickerWidgetState();
}

class _TimePickerWidgetState extends State<TimePickerWidget> {
  @override
  Widget build(BuildContext context) {
    return TextField(
        controller: widget.timePickerController,
        readOnly: true,
        onTap: () async {
          // print(widget.choosenDate);
          final choseTime = await showTimePicker(
              context: context,
              initialTime: TimeOfDay.now(),
              builder: (context, child) {
                return Theme(
                  data: ThemeData.light().copyWith(
                    colorScheme: ColorScheme.light(
                      primary: AppConfig.appThemeConfig
                          .secondaryColor, // header background color
                      onPrimary: AppConfig
                          .appThemeConfig.primaryColor, // header text color
                      onSurface: AppConfig.appThemeConfig.tertiaryColor,
                    ),
                    buttonTheme: const ButtonThemeData(
                        textTheme: ButtonTextTheme.primary),
                  ),
                  child: child!,
                );
              });
          if (choseTime != null) {
            final amPm = (choseTime.hour < 12) ? 'AM' : 'PM';
            var hour = choseTime.hour.toString();
            hour = (int.parse(hour) > 9) ? hour : '0$hour';
            var minute = choseTime.minute.toString();
            minute = (int.parse(minute) > 9) ? minute : '0$minute';
            widget.timePickerController.text = '$hour:$minute $amPm';
            if(widget.timePickerController.text.trim().isNotEmpty){
              widget.validator != null ? widget.validator!() : null;
              //widget.timePickerController.text = '00:00 AM';
            }
            //Helper.logger.w('Time: ${widget.timePickerController.text}');
          }
        },
        decoration: InputDecoration(
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                  color: AppConfig.appThemeConfig.primaryColor, width: 2.0),
              borderRadius: BorderRadius.circular(25.0),
            ),
            contentPadding:
                const EdgeInsets.only(right: 5, top: 6, bottom: 5, left: 10),
            border: OutlineInputBorder(
              gapPadding: 1,
              borderRadius: BorderRadius.circular(25.0),
            ),
            label: Text(widget.label,
                style: TextStyle(color: AppConfig.appThemeConfig.primaryColor)),
            suffixIcon: Icon(
              Icons.watch_later_outlined,
              color: AppConfig.appThemeConfig.secondaryColor,
            )));
  }
}
