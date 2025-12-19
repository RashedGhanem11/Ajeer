import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../themes/theme_notifier.dart';
import '../../models/provider_data.dart';
import '../../notifiers/user_notifier.dart';
import '../../notifiers/language_notifier.dart';
import '../shared_screens/profile_screen.dart';
import 'dart:ui';

const Color kPrimaryBlue = Color(0xFF2f6cfa);
const Color kLightBlue = Color(0xFFa2bdfc);
const Color kDeleteRed = Color(0xFFF44336);
const Color kSelectedGreen = Color(0xFF3ab542);
const double kBorderRadius = 50.0;
const double kWhiteContainerTopRatio = 0.15;
const double kSaveButtonHeight = 50.0;
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
  final List<int> serviceIds;
  final List<int> areaIds;
  final bool isEdit;
  final ProviderData? initialData;

  const WorkScheduleScreen({
    super.key,
    required this.themeNotifier,
    required this.selectedServices,
    required this.selectedLocations,
    required this.serviceIds,
    required this.areaIds,
    this.isEdit = false,
    this.initialData,
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

  late LanguageNotifier _languageNotifier;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _languageNotifier = Provider.of<LanguageNotifier>(context);
  }

  List<String> get _availableDays => kWeekDays
      .where((day) => !_finalSchedule.any((schedule) => schedule.day == day))
      .toList();

  @override
  void initState() {
    super.initState();
    if (widget.isEdit && widget.initialData != null) {
      _finalSchedule = List<WorkSchedule>.from(
        widget.initialData!.finalSchedule,
      );
    }
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
    // This is the color used for the title "Save Changes" or "Become Ajeer"
    final Color titleTextColor = isDarkMode ? Colors.white : Colors.black87;
    final Color bodyTextColor = isDarkMode
        ? Colors.grey.shade400
        : Colors.black54;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return BackdropFilter(
          // 1. Added the same blur effect as the clock and services dialogs
          filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
          child: AlertDialog(
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
                  widget.isEdit
                      ? _languageNotifier.translate('saveChanges')
                      : _languageNotifier.translate('becomeAjeer'),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                    color: titleTextColor,
                  ),
                ),
                const SizedBox(height: 10.0),
                if (!widget.isEdit) ...[
                  Text(
                    _languageNotifier.translate('freeTrialMsg'),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      color: bodyTextColor,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 25.0),
                ],
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: TextButton.styleFrom(
                          // 2. Cancel button color matches the Title Text color
                          foregroundColor: titleTextColor,
                          padding: const EdgeInsets.symmetric(vertical: 12.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        child: Text(
                          _languageNotifier.translate('cancel'),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (c) => const Center(
                              child: CircularProgressIndicator(),
                            ),
                          );

                          final providerData = ProviderData(
                            selectedServices: widget.selectedServices,
                            selectedLocations: widget.selectedLocations,
                            finalSchedule: _finalSchedule,
                            serviceIds: widget.serviceIds,
                            areaIds: widget.areaIds,
                          );

                          final userNotifier = Provider.of<UserNotifier>(
                            context,
                            listen: false,
                          );

                          try {
                            if (widget.isEdit) {
                              await userNotifier.updateProviderData(
                                providerData,
                              );
                            } else {
                              await userNotifier.completeProviderSetup(
                                providerData,
                              );
                            }

                            if (mounted) {
                              Navigator.of(context).pop();
                              Navigator.of(context).pop();

                              Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(
                                  builder: (context) => ProfileScreen(
                                    themeNotifier: widget.themeNotifier,
                                  ),
                                ),
                                (Route<dynamic> route) => false,
                              );
                            }
                          } catch (e) {
                            if (mounted) {
                              Navigator.of(context).pop();
                              String errorMsg = e
                                  .toString()
                                  .replaceAll("Exception:", "")
                                  .trim();
                              if (errorMsg.startsWith('{')) {
                                errorMsg = extractErrorMessage(
                                  e,
                                  _languageNotifier,
                                );
                              }
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    '${_languageNotifier.translate('error')}$errorMsg',
                                  ),
                                  backgroundColor: kDeleteRed,
                                  duration: const Duration(seconds: 5),
                                ),
                              );
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          // 3. Confirm button color changed to green to match the checkmark
                          backgroundColor: kSelectedGreen,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          elevation: 5,
                        ),
                        child: Text(
                          _languageNotifier.translate('confirm'),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
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
    final bool isDarkMode = widget.themeNotifier.isDarkMode;

    const Color subtleDark = Color(0xFF1E1E1E);
    const Color subtleLighterDark = Color(0xFF2C2C2C);

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStart ? _startTime : _endTime,
      builder: (context, child) {
        final ColorScheme colorScheme = isDarkMode
            ? const ColorScheme.dark(
                primary: kPrimaryBlue,
                onPrimary: Colors.white,
                surface: subtleDark,
                onSurface: Colors.white,
                secondaryContainer: kPrimaryBlue,
                onSecondaryContainer: Colors.white,
              )
            : const ColorScheme.light(
                primary: kPrimaryBlue,
                onPrimary: Colors.white,
                surface: Colors.white,
                onSurface: Colors.black87,
                secondaryContainer: kLightBlue,
              );

        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: colorScheme,
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: kPrimaryBlue,
                textStyle: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            timePickerTheme: TimePickerThemeData(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(40.0),
              ),
              backgroundColor: isDarkMode ? subtleDark : Colors.white,
              dialBackgroundColor: isDarkMode
                  ? subtleLighterDark
                  : Colors.grey.shade200,
              dialHandColor: kPrimaryBlue,
              dialTextColor: WidgetStateColor.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return Colors.white;
                }
                return isDarkMode ? Colors.white70 : Colors.black87;
              }),
              entryModeIconColor: kPrimaryBlue,
              dayPeriodTextColor: WidgetStateColor.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return Colors.white;
                }
                return isDarkMode ? Colors.white70 : Colors.black87;
              }),
              dayPeriodColor: WidgetStateColor.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return kPrimaryBlue;
                }
                return Colors.transparent;
              }),
              dayPeriodBorderSide: const BorderSide(color: kPrimaryBlue),
              hourMinuteTextColor: isDarkMode ? Colors.white : Colors.black87,
              hourMinuteColor: isDarkMode
                  ? subtleLighterDark
                  : Colors.grey.shade200,
            ),
          ),
          // Adding the Blur Filter here
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
            child: child!,
          ),
        );
      },
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
        SnackBar(
          content: Text(_languageNotifier.translate('startTimeError')),
          backgroundColor: kDeleteRed,
        ),
      );
      return;
    }

    if (_isOverlapping(newSlot)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_languageNotifier.translate('overlapError')),
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
                      _languageNotifier.translate('workDaysHours'),
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
                        _languageNotifier.translate('scheduleDesc'),
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
                languageNotifier: _languageNotifier,
              ),
              const SizedBox(height: 15.0),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProviderNavigationHeader extends StatefulWidget {
  final VoidCallback onBackTap;
  final VoidCallback onNextTap;
  final bool isNextEnabled;

  const _ProviderNavigationHeader({
    required this.onBackTap,
    required this.onNextTap,
    this.isNextEnabled = false,
  });

  @override
  State<_ProviderNavigationHeader> createState() =>
      _ProviderNavigationHeaderState();
}

class _ProviderNavigationHeaderState extends State<_ProviderNavigationHeader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.15,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    if (widget.isNextEnabled) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(_ProviderNavigationHeader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isNextEnabled != oldWidget.isNextEnabled) {
      if (widget.isNextEnabled) {
        _controller.repeat(reverse: true);
      } else {
        _controller.stop();
        _controller.reset();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final languageNotifier = Provider.of<LanguageNotifier>(context);
    final Color buttonBackgroundColor = widget.isNextEnabled
        ? kSelectedGreen
        : Colors.white.withOpacity(0.2);

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
            onPressed: widget.onBackTap,
          ),
          Text(
            languageNotifier.translate('appName'),
            style: const TextStyle(
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
          ),
          ScaleTransition(
            scale: widget.isNextEnabled
                ? _scaleAnimation
                : const AlwaysStoppedAnimation(1.0),
            child: InkWell(
              onTap: widget.isNextEnabled ? widget.onNextTap : null,
              customBorder: const CircleBorder(),
              child: Container(
                width: 45.0,
                height: 45.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: buttonBackgroundColor,
                  border: Border.all(color: Colors.white, width: 2.0),
                ),
                child: const Center(
                  child: Icon(Icons.check, size: 28.0, color: Colors.white),
                ),
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
  final LanguageNotifier languageNotifier;

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
    required this.languageNotifier,
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
            languageNotifier: languageNotifier,
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
            languageNotifier: languageNotifier,
          ),
          if (finalSchedule.isNotEmpty) ...[
            const SizedBox(height: 20.0),
            _WorkScheduleList(
              finalSchedule: finalSchedule,
              onEditSchedule: onEditSchedule,
              onDeleteSchedule: onDeleteSchedule,
              isDarkMode: isDarkMode,
              languageNotifier: languageNotifier,
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
  final LanguageNotifier languageNotifier;

  const _DaySelector({
    required this.availableDays,
    required this.selectedDay,
    required this.onDaySelected,
    required this.isDarkMode,
    required this.languageNotifier,
  });

  @override
  Widget build(BuildContext context) {
    if (availableDays.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text(
            languageNotifier.translate('allDaysScheduled'),
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
            child: _DayItem(
              day: day,
              isSelected: isSelected,
              isDarkMode: isDarkMode,
              onTap: () => onDaySelected(day),
              languageNotifier: languageNotifier,
            ),
          );
        },
      ),
    );
  }
}

class _DayItem extends StatefulWidget {
  final String day;
  final bool isSelected;
  final bool isDarkMode;
  final VoidCallback onTap;
  final LanguageNotifier languageNotifier;

  const _DayItem({
    required this.day,
    required this.isSelected,
    required this.isDarkMode,
    required this.onTap,
    required this.languageNotifier,
  });

  @override
  State<_DayItem> createState() => _DayItemState();
}

class _DayItemState extends State<_DayItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.9,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    _controller.forward().then((_) => _controller.reverse());
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    // Translate the day name
    final translatedDay = widget.languageNotifier.translateDay(widget.day);
    // Determine display text: substring if not Arabic (e.g. Mon), full if Arabic (e.g. الاثنين)
    final displayText = widget.languageNotifier.isArabic
        ? translatedDay
        : (translatedDay.length > 3
              ? translatedDay.substring(0, 3)
              : translatedDay);

    return ScaleTransition(
      scale: _scaleAnimation,
      child: InkWell(
        onTap: _handleTap,
        borderRadius: BorderRadius.circular(kBoxRadius),
        child: Container(
          width: 65,
          decoration: BoxDecoration(
            color: widget.isSelected
                ? kPrimaryBlue
                : (widget.isDarkMode ? Colors.grey.shade800 : Colors.white),
            borderRadius: BorderRadius.circular(kBoxRadius),
            border: Border.all(
              color: widget.isSelected
                  ? kPrimaryBlue
                  : (widget.isDarkMode
                        ? Colors.grey.shade700
                        : Colors.grey.shade300),
              width: 2,
            ),
          ),
          child: Center(
            child: Text(
              displayText,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: widget.isSelected
                    ? Colors.white
                    : (widget.isDarkMode ? Colors.white : Colors.black87),
              ),
            ),
          ),
        ),
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
  final LanguageNotifier languageNotifier;

  const _TimePickerButton({
    required this.label,
    required this.time,
    required this.onTap,
    required this.isDarkMode,
    required this.isEnabled,
    required this.languageNotifier,
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

    // Use translateTimeRange logic to format single TimeOfDay
    final timeString = languageNotifier.translateTimeRange(
      time.format(context),
    );

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
              timeString,
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
  final LanguageNotifier languageNotifier;

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
    required this.languageNotifier,
  });

  @override
  Widget build(BuildContext context) {
    final bool isEnabled = selectedDay != null;
    final Color disabledColor = isDarkMode
        ? Colors.grey.shade700
        : Colors.grey.shade300;

    final translatedDay = selectedDay != null
        ? languageNotifier.translateDay(selectedDay!)
        : '';
    final titleText = selectedDay != null
        ? '${languageNotifier.translate('timeSlotsFor')} $translatedDay:'
        : languageNotifier.translate('selectDayToSchedule');

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: kContentHorizontalPadding,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titleText,
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
                  label: languageNotifier.translate('startTime'),
                  time: startTime,
                  onTap: isEnabled ? () => onPickTime(context, true) : null,
                  isDarkMode: isDarkMode,
                  isEnabled: isEnabled,
                  languageNotifier: languageNotifier,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _TimePickerButton(
                  label: languageNotifier.translate('endTime'),
                  time: endTime,
                  onTap: isEnabled ? () => onPickTime(context, false) : null,
                  isDarkMode: isDarkMode,
                  isEnabled: isEnabled,
                  languageNotifier: languageNotifier,
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                height: kSaveButtonHeight,
                width: kSaveButtonHeight,
                child: ElevatedButton(
                  onPressed: isEnabled ? onAddTimeSlot : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimaryBlue,
                    side: const BorderSide(color: Colors.white, width: 2.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(kBoxRadius),
                    ),
                    padding: EdgeInsets.zero,
                    elevation: 0,
                  ),
                  child: const Icon(Icons.add, color: Colors.white, size: 26),
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
                    languageNotifier.translateTimeRange(timeSlot.toString()),
                    style: const TextStyle(
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
                        ? '${languageNotifier.translate('saveScheduleFor')} $translatedDay'
                        : languageNotifier.translate('addTimeSlotsToSave'),
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
  final LanguageNotifier languageNotifier;

  const _WorkScheduleList({
    required this.finalSchedule,
    required this.onEditSchedule,
    required this.onDeleteSchedule,
    required this.isDarkMode,
    required this.languageNotifier,
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
              '${languageNotifier.translate('workDaysHours')} (${languageNotifier.convertNumbers(finalSchedule.length.toString())})',
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
                  .map((t) => languageNotifier.translateTimeRange(t.toString()))
                  .join(languageNotifier.isArabic ? '، ' : ', ');

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
                            languageNotifier.translateDay(schedule.day),
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

String extractErrorMessage(dynamic error, LanguageNotifier lang) {
  String errorString = error.toString();
  try {
    int jsonStartIndex = errorString.indexOf('{');
    if (jsonStartIndex != -1) {
      String jsonString = errorString.substring(jsonStartIndex);
      Map<String, dynamic> decoded = jsonDecode(jsonString);
      if (decoded.containsKey('errors') && decoded['errors'] != null) {
        Map<String, dynamic> errors = decoded['errors'];
        if (errors.isNotEmpty) {
          String firstKey = errors.keys.first;
          var messages = errors[firstKey];
          if (messages is List && messages.isNotEmpty) {
            return messages.first.toString();
          }
        }
      }
      if (decoded.containsKey('title')) {
        return decoded['title'];
      }
    }
  } catch (e) {}
  return lang.translate('unexpectedError');
}
