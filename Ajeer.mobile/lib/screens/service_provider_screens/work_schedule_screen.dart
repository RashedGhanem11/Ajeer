import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../themes/theme_notifier.dart';
import '../../models/provider_data.dart';
import '../../notifiers/user_notifier.dart';
import '../shared_screens/profile_screen.dart';

const Color kLightBlue = Color(0xFF8CCBFF);
const Color kPrimaryBlue = Color(0xFF1976D2);
const Color kDeleteRed = Color(0xFFF44336);
const Color kSelectedGreen = Colors.green;
const double kBorderRadius = 50.0;
const double kWhiteContainerTopRatio = 0.15;
const double kSaveButtonHeight = 45.0;
const double kContentHorizontalPadding = 5.0;
const double kBoxRadius = 15.0;

const List<String> kWeekDays = [
  'Sunday',
  'Monday',
  'Tuesday',
  'Wednesday',
  'Thursday',
  'Friday',
  'Saturday',
];

class WorkScheduleScreen extends StatefulWidget {
  final ThemeNotifier themeNotifier;
  final Map<String, Set<String>> selectedServices;
  final List<LocationSelection> selectedLocations;

  const WorkScheduleScreen({
    super.key,
    required this.themeNotifier,
    required this.selectedServices,
    required this.selectedLocations,
  });

  @override
  State<WorkScheduleScreen> createState() => _WorkScheduleScreenState();
}

class _WorkScheduleScreenState extends State<WorkScheduleScreen> {
  String? _selectedDay;
  TimeOfDay _startTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 17, minute: 0);
  List<WorkSchedule> _finalSchedule = [];
  List<WorkTime> _currentDayTimeSlots = [];

  List<String> get _availableDays => kWeekDays
      .where((day) => !_finalSchedule.any((schedule) => schedule.day == day))
      .toList();

  @override
  void initState() {
    super.initState();
    _selectedDay = _availableDays.isNotEmpty ? _availableDays.first : null;
  }

  int _timeToMinutes(TimeOfDay time) {
    return time.hour * 60 + time.minute;
  }

  bool _isOverlapping(WorkTime newSlot) {
    final newStart = _timeToMinutes(newSlot.startTimeOfDay);
    final newEnd = _timeToMinutes(newSlot.endTimeOfDay);

    for (var existingSlot in _currentDayTimeSlots) {
      final existingStart = _timeToMinutes(existingSlot.startTimeOfDay);
      final existingEnd = _timeToMinutes(existingSlot.endTimeOfDay);

      if (newStart == existingStart && newEnd == existingEnd) {
        return true;
      }

      if (newStart < existingEnd && newEnd > existingStart) {
        return true;
      }
    }
    return false;
  }

  void _onBackTap() => Navigator.pop(context);

  bool get _isNextEnabled => _finalSchedule.isNotEmpty;

  void _onNextTap() {
    if (_isNextEnabled) {
      _showConfirmationDialog();
    }
  }

  void _showConfirmationDialog() {
    final bool isDarkMode = widget.themeNotifier.isDarkMode;
    final Color textColor = isDarkMode ? Colors.white : Colors.black87;
    final Color bodyTextColor = isDarkMode
        ? Colors.grey.shade400
        : Colors.black54;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0),
          ),
          backgroundColor: isDarkMode
              ? Theme.of(context).cardColor
              : Colors.white,
          contentPadding: const EdgeInsets.all(25.0),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.check_circle_outline,
                color: kSelectedGreen,
                size: 60,
              ),
              const SizedBox(height: 15.0),
              Text(
                'You have become an Ajeer!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 10.0),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: TextStyle(
                    fontSize: 15,
                    color: bodyTextColor,
                    height: 1.5,
                  ),
                  children: [
                    const TextSpan(
                      text: 'Start providing your services to customers and ',
                    ),
                    const TextSpan(
                      text: 'using the Ajeer App for free for 30 days',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const TextSpan(
                      text:
                          '. After this period, you will need to subscribe to the Ajeer App to continue using it. You can check subscription information on your profile page, which you will be directed to shortly.',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 25.0),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: kPrimaryBlue,
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        final providerData = ProviderData(
                          selectedServices: widget.selectedServices,
                          selectedLocations: widget.selectedLocations,
                          finalSchedule: _finalSchedule,
                        );

                        Provider.of<UserNotifier>(
                          context,
                          listen: false,
                        ).completeProviderSetup(providerData);

                        Navigator.of(context).pop();

                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                            builder: (context) => ProfileScreen(
                              themeNotifier: widget.themeNotifier,
                            ),
                          ),
                          (Route<dynamic> route) => false,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimaryBlue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        elevation: 5,
                      ),
                      child: const Text(
                        'Confirm',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _onDaySelected(String day) {
    setState(() {
      _selectedDay = day;
      _currentDayTimeSlots = [];
    });
  }

  Future<void> _pickTime(BuildContext context, bool isStart) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStart ? _startTime : _endTime,
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  void _addTimeSlot() {
    if (_selectedDay == null) return;

    final newSlot = WorkTime(
      startTimeOfDay: _startTime,
      endTimeOfDay: _endTime,
    );
    final startMinutes = _timeToMinutes(_startTime);
    final endMinutes = _timeToMinutes(_endTime);

    if (startMinutes >= endMinutes) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Start time must be before end time.'),
          backgroundColor: kDeleteRed,
        ),
      );
      return;
    }

    if (_isOverlapping(newSlot)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'The selected time slot overlaps with an existing one or is a duplicate.',
          ),
          backgroundColor: kDeleteRed,
        ),
      );
      return;
    }

    setState(() {
      _currentDayTimeSlots.add(newSlot);
      _currentDayTimeSlots.sort(
        (a, b) => _timeToMinutes(
          a.startTimeOfDay,
        ).compareTo(_timeToMinutes(b.startTimeOfDay)),
      );
    });
  }

  void _removeTimeSlot(WorkTime timeSlot) {
    setState(() {
      _currentDayTimeSlots.remove(timeSlot);
    });
  }

  void _saveWorkSchedule() {
    if (_selectedDay != null && _currentDayTimeSlots.isNotEmpty) {
      setState(() {
        _finalSchedule.add(
          WorkSchedule(
            day: _selectedDay!,
            timeSlots: List.from(_currentDayTimeSlots),
          ),
        );
      });

      _currentDayTimeSlots = [];
      _selectedDay = _availableDays.isNotEmpty ? _availableDays.first : null;
    }
  }

  void _onEditSchedule(WorkSchedule schedule) {
    setState(() {
      _finalSchedule.removeWhere((s) => s.day == schedule.day);

      _selectedDay = schedule.day;
      _currentDayTimeSlots = List.from(schedule.timeSlots);
    });
  }

  void _onDeleteSchedule(String day) {
    setState(() {
      _finalSchedule.removeWhere((s) => s.day == day);
      if (_selectedDay == null && _availableDays.isNotEmpty) {
        _selectedDay = _availableDays.first;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = widget.themeNotifier.isDarkMode;

    SystemChrome.setSystemUIOverlayStyle(
      isDarkMode
          ? SystemUiOverlayStyle.light.copyWith(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness: Brightness.light,
            )
          : SystemUiOverlayStyle.dark.copyWith(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness: Brightness.dark,
            ),
    );

    final screenHeight = MediaQuery.of(context).size.height;
    final double whiteContainerTop = screenHeight * kWhiteContainerTopRatio;

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          _buildBackgroundGradient(),
          _buildWhiteContainer(
            containerTop: whiteContainerTop,
            isDarkMode: isDarkMode,
          ),
          _ProviderNavigationHeader(
            onBackTap: _onBackTap,
            onNextTap: _onNextTap,
            isNextEnabled: _isNextEnabled,
          ),
        ],
      ),
    );
  }

  Widget _buildBackgroundGradient() {
    return SizedBox(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: const DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [kLightBlue, kPrimaryBlue],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
      ),
    );
  }

  Widget _buildWhiteContainer({
    required double containerTop,
    required bool isDarkMode,
  }) {
    return Positioned(
      top: containerTop,
      left: 20,
      right: 20,
      bottom: 20,
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: isDarkMode ? Theme.of(context).cardColor : Colors.white,
          borderRadius: const BorderRadius.all(Radius.circular(kBorderRadius)),
          boxShadow: [
            BoxShadow(
              color: isDarkMode ? Colors.black45 : Colors.black26,
              spreadRadius: 1,
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 25.0),
              Padding(
                padding: const EdgeInsets.only(
                  left: 20.0,
                  right: 20.0,
                  bottom: 5.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Work Schedule',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: isDarkMode ? Colors.white : Colors.black87,
                          ),
                    ),
                    const SizedBox(height: 15.0),
                    SizedBox(
                      width: double.infinity,
                      child: Text(
                        'Schedule your work days and hours.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: isDarkMode
                              ? Colors.grey[400]
                              : Colors.grey[600],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10.0),
              _ScheduleContent(
                availableDays: _availableDays,
                selectedDay: _selectedDay,
                startTime: _startTime,
                endTime: _endTime,
                currentDayTimeSlots: _currentDayTimeSlots,
                finalSchedule: _finalSchedule,
                onDaySelected: _onDaySelected,
                onPickTime: _pickTime,
                onAddTimeSlot: _addTimeSlot,
                onRemoveTimeSlot: _removeTimeSlot,
                onSaveSchedule: _saveWorkSchedule,
                onEditSchedule: _onEditSchedule,
                onDeleteSchedule: _onDeleteSchedule,
                isDarkMode: isDarkMode,
              ),
              const SizedBox(height: 15.0),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProviderNavigationHeader extends StatelessWidget {
  final VoidCallback onBackTap;
  final VoidCallback onNextTap;
  final bool isNextEnabled;

  const _ProviderNavigationHeader({
    required this.onBackTap,
    required this.onNextTap,
    this.isNextEnabled = false,
  });

  Widget _buildAjeerTitle() {
    return const Text(
      'Ajeer',
      style: TextStyle(
        color: Colors.white,
        fontSize: 34,
        fontWeight: FontWeight.w900,
        shadows: [
          Shadow(
            blurRadius: 2.0,
            color: Colors.black26,
            offset: Offset(1.0, 1.0),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color checkColor = isNextEnabled ? kSelectedGreen : kPrimaryBlue;

    return Positioned(
      top: MediaQuery.of(context).padding.top + 5,
      left: 10,
      right: 10,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            iconSize: 28.0,
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
            onPressed: onBackTap,
          ),
          _buildAjeerTitle(),
          InkWell(
            onTap: isNextEnabled ? onNextTap : null,
            customBorder: const CircleBorder(),
            child: Container(
              width: 45.0,
              height: 45.0,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.2),
              ),
              child: Center(
                child: Icon(Icons.check_circle, size: 45.0, color: checkColor),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScheduleContent extends StatelessWidget {
  final List<String> availableDays;
  final String? selectedDay;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final List<WorkTime> currentDayTimeSlots;
  final List<WorkSchedule> finalSchedule;
  final ValueChanged<String> onDaySelected;
  final Function(BuildContext context, bool isStart) onPickTime;
  final VoidCallback onAddTimeSlot;
  final ValueChanged<WorkTime> onRemoveTimeSlot;
  final VoidCallback onSaveSchedule;
  final ValueChanged<WorkSchedule> onEditSchedule;
  final ValueChanged<String> onDeleteSchedule;
  final bool isDarkMode;

  const _ScheduleContent({
    required this.availableDays,
    required this.selectedDay,
    required this.startTime,
    required this.endTime,
    required this.currentDayTimeSlots,
    required this.finalSchedule,
    required this.onDaySelected,
    required this.onPickTime,
    required this.onAddTimeSlot,
    required this.onRemoveTimeSlot,
    required this.onSaveSchedule,
    required this.onEditSchedule,
    required this.onDeleteSchedule,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: kContentHorizontalPadding,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 10.0),
          _DaySelector(
            availableDays: availableDays,
            selectedDay: selectedDay,
            onDaySelected: onDaySelected,
            isDarkMode: isDarkMode,
          ),
          const SizedBox(height: 25.0),
          _TimeSlotCreator(
            selectedDay: selectedDay,
            startTime: startTime,
            endTime: endTime,
            currentDayTimeSlots: currentDayTimeSlots,
            onPickTime: onPickTime,
            onAddTimeSlot: onAddTimeSlot,
            onRemoveTimeSlot: onRemoveTimeSlot,
            onSaveSchedule: onSaveSchedule,
            isDarkMode: isDarkMode,
          ),
          if (finalSchedule.isNotEmpty) ...[
            const SizedBox(height: 20.0),
            _WorkScheduleList(
              finalSchedule: finalSchedule,
              onEditSchedule: onEditSchedule,
              onDeleteSchedule: onDeleteSchedule,
              isDarkMode: isDarkMode,
            ),
          ],
        ],
      ),
    );
  }
}

class _DaySelector extends StatelessWidget {
  final List<String> availableDays;
  final String? selectedDay;
  final ValueChanged<String> onDaySelected;
  final bool isDarkMode;

  const _DaySelector({
    required this.availableDays,
    required this.selectedDay,
    required this.onDaySelected,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    if (availableDays.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text(
            'All days have been scheduled!',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? kSelectedGreen : kPrimaryBlue,
            ),
          ),
        ),
      );
    }

    return SizedBox(
      height: 70,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: availableDays.length,
        itemBuilder: (context, index) {
          final day = availableDays[index];
          final bool isSelected = day == selectedDay;

          return Padding(
            padding: EdgeInsets.only(
              left: index == 0 ? kContentHorizontalPadding : 5.0,
              right: index == availableDays.length - 1
                  ? kContentHorizontalPadding
                  : 5.0,
            ),
            child: InkWell(
              onTap: () => onDaySelected(day),
              borderRadius: BorderRadius.circular(kBoxRadius),
              child: Container(
                width: 65,
                decoration: BoxDecoration(
                  color: isSelected
                      ? kPrimaryBlue
                      : (isDarkMode ? Colors.grey.shade800 : Colors.white),
                  borderRadius: BorderRadius.circular(kBoxRadius),
                  border: Border.all(
                    color: isSelected
                        ? kPrimaryBlue
                        : (isDarkMode
                              ? Colors.grey.shade700
                              : Colors.grey.shade300),
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    day.substring(0, 3),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: isSelected
                          ? Colors.white
                          : (isDarkMode ? Colors.white : Colors.black87),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _TimePickerButton extends StatelessWidget {
  final String label;
  final TimeOfDay time;
  final VoidCallback? onTap;
  final bool isDarkMode;
  final bool isEnabled;

  const _TimePickerButton({
    required this.label,
    required this.time,
    required this.onTap,
    required this.isDarkMode,
    required this.isEnabled,
  });

  @override
  Widget build(BuildContext context) {
    final Color textColor = isEnabled
        ? (isDarkMode ? Colors.white70 : Colors.black87)
        : (isDarkMode ? Colors.grey.shade600 : Colors.grey.shade500);
    final Color iconColor = isEnabled ? kPrimaryBlue : textColor;
    final Color borderColor = isEnabled
        ? kPrimaryBlue
        : (isDarkMode ? Colors.grey.shade700 : Colors.grey.shade400);
    final Color bgColor = isDarkMode ? Colors.grey.shade900 : Colors.white;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(kBoxRadius),
      child: Container(
        height: kSaveButtonHeight,
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(kBoxRadius),
          border: Border.all(color: borderColor, width: 1.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              time.format(context),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            Icon(Icons.access_time, color: iconColor, size: 20),
          ],
        ),
      ),
    );
  }
}

class _TimeSlotCreator extends StatelessWidget {
  final String? selectedDay;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final List<WorkTime> currentDayTimeSlots;
  final Function(BuildContext context, bool isStart) onPickTime;
  final VoidCallback onAddTimeSlot;
  final VoidCallback onSaveSchedule;
  final ValueChanged<WorkTime> onRemoveTimeSlot;
  final bool isDarkMode;

  const _TimeSlotCreator({
    required this.selectedDay,
    required this.startTime,
    required this.endTime,
    required this.currentDayTimeSlots,
    required this.onPickTime,
    required this.onAddTimeSlot,
    required this.onSaveSchedule,
    required this.onRemoveTimeSlot,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    final bool isEnabled = selectedDay != null;
    final Color disabledColor = isDarkMode
        ? Colors.grey.shade700
        : Colors.grey.shade300;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: kContentHorizontalPadding,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            selectedDay != null
                ? 'Time Slots for ${selectedDay!}:'
                : 'Select a Day to Schedule Time',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 17,
              color: isEnabled
                  ? (isDarkMode ? Colors.white : Colors.black87)
                  : disabledColor,
            ),
          ),
          const SizedBox(height: 10.0),
          Row(
            children: [
              Expanded(
                child: _TimePickerButton(
                  label: 'Start Time',
                  time: startTime,
                  onTap: isEnabled ? () => onPickTime(context, true) : null,
                  isDarkMode: isDarkMode,
                  isEnabled: isEnabled,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _TimePickerButton(
                  label: 'End Time',
                  time: endTime,
                  onTap: isEnabled ? () => onPickTime(context, false) : null,
                  isDarkMode: isDarkMode,
                  isEnabled: isEnabled,
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                height: kSaveButtonHeight,
                child: ElevatedButton(
                  onPressed: isEnabled ? onAddTimeSlot : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kSelectedGreen,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(kBoxRadius),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                  ),
                  child: const Icon(Icons.add, color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20.0),
          if (currentDayTimeSlots.isNotEmpty) ...[
            Wrap(
              spacing: 8.0,
              runSpacing: 4.0,
              children: currentDayTimeSlots.map((timeSlot) {
                return Chip(
                  backgroundColor: kPrimaryBlue.withOpacity(0.1),
                  label: Text(
                    timeSlot.toString(),
                    style: TextStyle(
                      color: kPrimaryBlue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  deleteIcon: const Icon(
                    Icons.close,
                    size: 18,
                    color: kDeleteRed,
                  ),
                  onDeleted: isEnabled
                      ? () => onRemoveTimeSlot(timeSlot)
                      : null,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    side: const BorderSide(color: kPrimaryBlue),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20.0),
          ],
          Center(
            child: SizedBox(
              height: kSaveButtonHeight,
              child: ElevatedButton(
                onPressed: currentDayTimeSlots.isNotEmpty && isEnabled
                    ? onSaveSchedule
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimaryBlue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(kBoxRadius),
                  ),
                  elevation: 5,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Text(
                    currentDayTimeSlots.isNotEmpty
                        ? 'Save Schedule for ${selectedDay!}'
                        : 'Add Time Slots to Save',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WorkScheduleList extends StatelessWidget {
  final List<WorkSchedule> finalSchedule;
  final ValueChanged<WorkSchedule> onEditSchedule;
  final ValueChanged<String> onDeleteSchedule;
  final bool isDarkMode;

  const _WorkScheduleList({
    required this.finalSchedule,
    required this.onEditSchedule,
    required this.onDeleteSchedule,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    final Color titleColor = isDarkMode ? Colors.white : Colors.black87;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: kContentHorizontalPadding,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 5.0, bottom: 5.0),
            child: Text(
              'Work Days & Hours (${finalSchedule.length})',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: titleColor,
              ),
            ),
          ),
          ListView.builder(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: finalSchedule.length,
            itemBuilder: (context, index) {
              final schedule = finalSchedule[index];
              final times = schedule.timeSlots
                  .map((t) => t.toString())
                  .join(', ');

              final Color itemBgColor = isDarkMode
                  ? Colors.black
                  : Colors.grey.shade100;
              final Color itemBorderColor = isDarkMode
                  ? Colors.grey.shade600
                  : Colors.grey.shade400;
              final Color timeTextColor = isDarkMode
                  ? Colors.grey.shade400
                  : Colors.grey.shade600;
              final Color dayTextColor = isDarkMode
                  ? Colors.white
                  : Colors.black87;

              return Container(
                margin: const EdgeInsets.only(bottom: 8.0),
                padding: const EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                  color: itemBgColor,
                  borderRadius: BorderRadius.circular(20.0),
                  border: Border.all(color: itemBorderColor, width: 2.0),
                  boxShadow: isDarkMode
                      ? null
                      : [
                          BoxShadow(
                            color: Colors.grey.shade200,
                            spreadRadius: 1,
                            blurRadius: 3,
                          ),
                        ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            schedule.day,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: dayTextColor,
                            ),
                          ),
                          const SizedBox(height: 2.0),
                          Text(
                            times,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13,
                              color: timeTextColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        InkWell(
                          onTap: () => onEditSchedule(schedule),
                          customBorder: const CircleBorder(),
                          child: Container(
                            width: 35,
                            height: 35,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: kPrimaryBlue,
                            ),
                            child: const Icon(
                              Icons.edit,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        InkWell(
                          onTap: () => onDeleteSchedule(schedule.day),
                          customBorder: const CircleBorder(),
                          child: Container(
                            width: 35,
                            height: 35,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: kDeleteRed,
                            ),
                            child: const Icon(
                              Icons.delete_forever,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
