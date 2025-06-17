import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:hrm_dump_flutter/models/attendances_records_model.dart';
import 'package:hrm_dump_flutter/screens/dailyGoals/daily_goals.dart';
import 'package:hrm_dump_flutter/screens/dashbord/job_openings.dart';
import 'package:hrm_dump_flutter/screens/dashbord/leave_records.dart';
import 'package:hrm_dump_flutter/screens/dashbord/attendances_form.dart';
import 'package:hrm_dump_flutter/screens/dashbord/attendances_records.dart';
import 'package:hrm_dump_flutter/screens/dashbord/leave_screen.dart';
import 'package:hrm_dump_flutter/screens/dashbord/upload_resume.dart';
import 'package:hrm_dump_flutter/screens/login/login.dart';
import 'package:hrm_dump_flutter/screens/profile/profile_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';

// Custom cache manager for web
class NonStoringCacheManager extends CacheManager {
  static const key = 'nonStoringCache';
  static final NonStoringCacheManager _instance = NonStoringCacheManager._();

  factory NonStoringCacheManager() => _instance;

  NonStoringCacheManager._()
      : super(Config(key, fileService: HttpFileService()));
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with WidgetsBindingObserver {
  String employeeFullName = '';
  String profileImage = '';
  String email = '';
  int subadminId = 0;
  String role = '';
  String jobRole = '';
  String empimg = '';
  String registercompanyname = '';
  bool _isJobsExpanded = false;
  int _selectedIndex = 0;

  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<AttendanceRecord>> _attendanceEvents = {};
  bool _isLoading = true;

  // Base URL for images
  final String _imageBaseUrl = 'https://api.managifyhr.com/images/profile/';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _selectedDay = _focusedDay;
    _loadUserData();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadUserData();
    }
  }

  Future<void> _fetchAttendanceData() async {
    try {
      if (employeeFullName.isEmpty || subadminId == 0) {
        setState(() {
          _isLoading = false;
        });
        return;
      }
      final encodedName = Uri.encodeComponent(employeeFullName);
      final url = Uri.parse(
        'https://api.managifyhr.com/api/employee/$subadminId/$encodedName/attendance/all',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final Map<DateTime, List<AttendanceRecord>> events = {};

        for (var item in data) {
          final attendance = AttendanceRecord.fromJson(item);
          final date = DateTime.parse(attendance.date);
          final normalizedDate = DateTime(date.year, date.month, date.day);
          events.update(
            normalizedDate,
                (existing) => [...existing, attendance],
            ifAbsent: () => [attendance],
          );
        }

        setState(() {
          _attendanceEvents = events;
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load attendance data');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  List<AttendanceRecord> _getEventsForDay(DateTime day) {
    return _attendanceEvents[DateTime(day.year, day.month, day.day)] ?? [];
  }

  Color _getStatusColor(String status) {
    // Normalize status by converting to lowercase and removing hyphens
    final normalizedStatus = status.toLowerCase().replaceAll('-', ' ');
    switch (normalizedStatus) {
      case 'present':
        return Colors.green;
      case 'absent':
        return Colors.red;
      case 'holiday':
        return Colors.red;
      case 'week off':
        return Colors.purple;
      case 'paid leave':
        return Colors.blue;
      case 'half day':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      employeeFullName = prefs.getString('fullName') ?? '';
      email = prefs.getString('email') ?? '';
      subadminId = prefs.getInt('subadminId') ?? 0;
      role = prefs.getString('role') ?? '';
      jobRole = prefs.getString('jobRole') ?? '';
      empimg = prefs.getString('empimg') ?? '';
      registercompanyname = prefs.getString('registercompanyname') ?? '';
      profileImage = prefs.getString('profileImage') ?? '';
    });
    if (employeeFullName.isNotEmpty && subadminId != 0) {
      _fetchAttendanceData();
    }
  }

  bool _isValidUrl(String url) {
    if (url.isEmpty) return false;
    final uri = Uri.tryParse(url);
    return uri != null && (uri.isScheme('http') || uri.isScheme('https'));
  }

  String _getImageUrl(String imagePath) {
    if (imagePath.isEmpty) return '';
    if (_isValidUrl(imagePath)) return imagePath;
    return '$_imageBaseUrl$imagePath';
  }

  Future<CacheManager> _getCacheManager() async {
    if (kIsWeb) {
      return NonStoringCacheManager();
    }
    return DefaultCacheManager();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => DailyGoalsScreen()),
        ).then((_) => _loadUserData());
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ProfileScreen()),
        ).then((_) => _loadUserData());
        break;
    }
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    bool isSelected = _selectedIndex == index;

    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(isSelected ? 8 : 6),
            decoration: BoxDecoration(
              color:
              isSelected
                  ? Colors.white.withOpacity(0.25)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
              boxShadow:
              isSelected
                  ? [
                BoxShadow(
                  color: Colors.white.withOpacity(0.2),
                  blurRadius: 8.0,
                  offset: const Offset(0, 2),
                  spreadRadius: 0,
                ),
              ]
                  : null,
            ),
            child: AnimatedScale(
              duration: const Duration(milliseconds: 300),
              curve: Curves.elasticOut,
              scale: isSelected ? 1.1 : 1.0,
              child: Icon(
                icon,
                color:
                isSelected ? Colors.white : Colors.white.withOpacity(0.7),
                size: isSelected ? 24 : 22,
              ),
            ),
          ),
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 300),
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.white.withOpacity(0.7),
              fontSize: isSelected ? 11 : 10,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            ),
            child: Text(label),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: _buildDrawer(),
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Dashboard', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF667eea), Color(0xFF764ba2)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 4,
      ),
      body:
      _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Column(
          children: [
            _buildDashboardContent(),
            Padding(
              padding: const EdgeInsets.only(
                left: 16,
                bottom: 16,
                right: 16,
              ),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      TableCalendar<AttendanceRecord>(
                        firstDay: DateTime.utc(2020, 1, 1),
                        lastDay: DateTime.utc(2030, 12, 31),
                        focusedDay: _focusedDay,
                        calendarFormat: _calendarFormat,
                        availableCalendarFormats: const {
                          CalendarFormat.month: 'Month'
                        },
                        selectedDayPredicate: (day) {
                          return isSameDay(_selectedDay, day);
                        },
                        onDaySelected: (selectedDay, focusedDay) {
                          setState(() {
                            _selectedDay = selectedDay;
                            _focusedDay = focusedDay;
                          });
                        },
                        onPageChanged: (focusedDay) {
                          _focusedDay = focusedDay;
                        },
                        eventLoader: _getEventsForDay,
                        daysOfWeekHeight: 30,
                        rowHeight: 40,
                        calendarStyle: CalendarStyle(
                          outsideDaysVisible: false,
                          cellMargin: EdgeInsets.all(4),
                          cellPadding: EdgeInsets.zero,
                          cellAlignment: Alignment.center,
                          todayDecoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.3),
                            shape: BoxShape.circle,
                          ),
                          selectedDecoration: BoxDecoration(
                            color: Colors.blue,
                            shape: BoxShape.circle,
                          ),
                          defaultTextStyle: TextStyle(fontSize: 14),
                          weekendTextStyle: TextStyle(fontSize: 14),
                          outsideTextStyle: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.withOpacity(0.3),
                          ),
                        ),
                        headerStyle: HeaderStyle(
                          formatButtonVisible: false,
                          titleCentered: true,
                          titleTextStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                          leftChevronMargin: const EdgeInsets.only(left: 10),
                          rightChevronMargin: const EdgeInsets.only(right: 10),
                          leftChevronIcon: const Icon(Icons.chevron_left, size: 24),
                          rightChevronIcon: const Icon(Icons.chevron_right, size: 24),
                        ),
                        calendarBuilders: CalendarBuilders(
                          markerBuilder: (context, day, events) {
                            return const SizedBox.shrink();
                          },
                          defaultBuilder: (context, day, focusedDay) {
                            final events = _getEventsForDay(day);
                            Color bgColor = Colors.transparent;
                            if (events.isNotEmpty) {
                              bgColor = _getStatusColor(events[0].status).withOpacity(0.3);
                            }
                            return Center(
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: bgColor,
                                ),
                                padding: const EdgeInsets.all(6.0),
                                child: Text(
                                  '${day.day}',
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            );
                          },
                          todayBuilder: (context, day, focusedDay) {
                            final events = _getEventsForDay(day);
                            Color bgColor = Colors.blue.withOpacity(0.3);
                            if (events.isNotEmpty) {
                              bgColor = _getStatusColor(events[0].status).withOpacity(0.3);
                            }
                            return Center(
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: bgColor,
                                ),
                                padding: const EdgeInsets.all(6.0),
                                child: Text(
                                  '${day.day}',
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            );
                          },
                          selectedBuilder: (context, day, focusedDay) {
                            final events = _getEventsForDay(day);
                            Color bgColor = Colors.blue;
                            if (events.isNotEmpty) {
                              bgColor = _getStatusColor(events[0].status);
                            }
                            return Center(
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: bgColor,
                                ),
                                padding: const EdgeInsets.all(6.0),
                                child: Text(
                                  '${day.day}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      if (_selectedDay != null)
                        ListView(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          children:
                          _getEventsForDay(_selectedDay!).map((
                              event,
                              ) {
                            final date = DateTime.parse(event.date);
                            return ListTile(
                              leading: Icon(
                                Icons.circle,
                                color: _getStatusColor(
                                  event.status,
                                ),
                                size: 12,
                              ),
                              title: Text(
                                event.status,
                                style: TextStyle(fontSize: 14),
                              ),
                              subtitle: Text(
                                '${date.day}/${date.month}/${date.year}',
                                style: TextStyle(fontSize: 12),
                              ),
                            );
                          }).toList(),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        height: 63,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF667eea), Color(0xFF764ba2)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
          boxShadow: [
            BoxShadow(
              color: Color(0xFF667eea).withOpacity(0.3),
              blurRadius: 25,
              offset: Offset(0, -10),
              spreadRadius: 5,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(35),
            topRight: Radius.circular(35),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(0, Icons.home_filled, 'Home'),
                _buildNavItem(1, Icons.track_changes, 'Goals'),
                _buildNavItem(2, Icons.person, 'Profile'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDrawer() {
    final bool hasValidNetworkImage = _isValidUrl(_getImageUrl(empimg));
    final bool hasLocalImage =
        profileImage.isNotEmpty && !kIsWeb && File(profileImage).existsSync();

    final mediaQuery = MediaQuery.of(context);
    final appBarHeight = AppBar().preferredSize.height;
    final statusBarHeight = mediaQuery.padding.top;
    final bottomNavHeight = 63.0;
    final bottomSafeArea = mediaQuery.padding.bottom;

    final availableHeight =
        mediaQuery.size.height -
            appBarHeight -
            statusBarHeight -
            bottomNavHeight -
            bottomSafeArea;

    return Drawer(
      child: Container(
        height: availableHeight,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade50, Colors.white, Colors.grey.shade50],
          ),
        ),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            _buildUserHeader(hasValidNetworkImage, hasLocalImage),
            const SizedBox(height: 8),
            _buildAnimatedTile(
              icon: Icons.home_rounded,
              title: 'Home',
              color: Colors.indigo,
              onTap: () => Navigator.pop(context),
            ),
            _buildAnimatedTile(
              icon: Icons.event_available_rounded,
              title: 'Attendance Form',
              color: Colors.blue,
              onTap: () => _navigateToScreen(AttendanceFormPage()),
            ),
            _buildAnimatedTile(
              icon: Icons.list_alt_rounded,
              title: 'Attendance Records',
              color: Colors.cyan,
              onTap: () => _navigateToScreen(const AttendancesRecordsScreen()),
            ),
            _buildAnimatedTile(
              icon: Icons.event_busy_rounded,
              title: 'Leave',
              color: Colors.orange,
              onTap: () => _navigateToScreen(const LeaveScreen()),
            ),
            _buildAnimatedTile(
              icon: Icons.assignment_turned_in_rounded,
              title: 'Leave Records',
              color: Colors.amber,
              onTap:
                  () => _navigateToScreen(
                LeaveRecordsTable(
                  subadminId: subadminId,
                  name: employeeFullName,
                ),
              ),
            ),
            _buildJobsExpansionTile(),
            const Divider(height: 32, thickness: 1, color: Colors.grey),
            _buildAnimatedTile(
              icon: Icons.logout_rounded,
              title: 'Logout',
              color: Colors.red,
              isDestructive: true,
              onTap: _handleLogout,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _navigateToScreen(Widget screen) {
    Navigator.pop(context);
    Navigator.push(
      context,
      _createSlidePageRoute(screen),
    ).then((_) => _loadUserData());
  }

  Widget _buildUserHeader(bool hasValidNetworkImage, bool hasLocalImage) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue.shade700,
            Colors.blue.shade800,
            Colors.indigo.shade800,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: UserAccountsDrawerHeader(
        decoration: const BoxDecoration(color: Colors.transparent),
        accountName: Text(
          employeeFullName,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        accountEmail: Text(
          jobRole,
          style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.9)),
        ),
        currentAccountPicture: Hero(
          tag: 'profile_avatar',
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: CircleAvatar(
              radius: 50,
              backgroundColor: Colors.grey.shade300,
              child:
              hasValidNetworkImage && !hasLocalImage
                  ? FutureBuilder<CacheManager>(
                future: _getCacheManager(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return CachedNetworkImage(
                      imageUrl: _getImageUrl(empimg),
                      cacheManager: snapshot.data,
                      imageBuilder:
                          (context, imageProvider) => Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            image: imageProvider,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      placeholder:
                          (context, url) =>
                      const CircularProgressIndicator(),
                      errorWidget:
                          (context, url, error) => const Icon(
                        Icons.person_rounded,
                        size: 50,
                        color: Colors.white,
                      ),
                    );
                  }
                  return const CircularProgressIndicator();
                },
              )
                  : (hasLocalImage
                  ? ClipOval(
                child: Image.file(
                  File(profileImage),
                  fit: BoxFit.cover,
                  width: 100,
                  height: 100,
                  errorBuilder:
                      (context, error, stackTrace) => const Icon(
                    Icons.person_rounded,
                    size: 50,
                    color: Colors.white,
                  ),
                ),
              )
                  : const Icon(
                Icons.person_rounded,
                size: 50,
                color: Colors.white,
              )),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedTile({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          splashColor: color.withOpacity(0.2),
          highlightColor: color.withOpacity(0.1),
          onTap: () {
            HapticFeedback.lightImpact();
            onTap();
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.transparent,
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 22),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color:
                      isDestructive
                          ? Colors.red.shade700
                          : Colors.grey.shade800,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: Colors.grey.shade400,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildJobsExpansionTile() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color:
        _isJobsExpanded
            ? Colors.purple.withOpacity(0.05)
            : Colors.transparent,
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.purple.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.work_outline_rounded,
              color: Colors.purple,
              size: 22,
            ),
          ),
          title: Text(
            'Jobs',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade800,
            ),
          ),
          trailing: AnimatedRotation(
            turns: _isJobsExpanded ? 0.5 : 0,
            duration: const Duration(milliseconds: 200),
            child: Icon(Icons.expand_more_rounded, color: Colors.grey.shade400),
          ),
          initiallyExpanded: _isJobsExpanded,
          onExpansionChanged: (bool expanded) {
            setState(() {
              _isJobsExpanded = expanded;
            });
            HapticFeedback.selectionClick();
          },
          children: [
            _buildSubTile(
              'Job Openings',
              Icons.work_rounded,
              Colors.purple.shade300,
                  () => _navigateToScreen(const JobOpeningGridScreen()),
            ),
            _buildSubTile(
              'Upload Resume',
              Icons.upload_file_rounded,
              Colors.purple.shade400,
                  () => _navigateToScreen(const UploadResumeScreen()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubTile(
      String title,
      IconData icon,
      Color color,
      VoidCallback onTap,
      ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        child: Container(
          margin: const EdgeInsets.only(left: 16, right: 8, bottom: 4),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    color: Colors.grey.shade700,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: Colors.grey.shade300,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }

  PageRouteBuilder _createSlidePageRoute(Widget page) {
    return PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOutCubic;

        final tween = Tween(
          begin: begin,
          end: end,
        ).chain(CurveTween(curve: curve));
        final offsetAnimation = animation.drive(tween);
        final fadeAnimation = Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(CurvedAnimation(parent: animation, curve: Curves.easeInOut));

        return SlideTransition(
          position: offsetAnimation,
          child: FadeTransition(opacity: fadeAnimation, child: child),
        );
      },
    );
  }

  Future<void> _handleLogout() async {
    HapticFeedback.mediumImpact();

    final shouldLogout = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(Icons.logout_rounded, color: Colors.red.shade600),
            const SizedBox(width: 8),
            const Text(
              "Logout",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        content: const Text(
          "Are you sure you want to logout?",
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 12,
              ),
            ),
            child: Text(
              "Cancel",
              style: TextStyle(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              "Logout",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );

    if (shouldLogout ?? false) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      if (!context.mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 800),
          pageBuilder: (_, __, ___) => const LoginScreen(),
          transitionsBuilder: (_, animation, __, child) {
            final slideTween = Tween<Offset>(
              begin: const Offset(0.0, -1.0),
              end: Offset.zero,
            ).chain(CurveTween(curve: Curves.easeInOut));
            final fadeTween = Tween<double>(begin: 0.0, end: 1.0);

            return SlideTransition(
              position: animation.drive(slideTween),
              child: FadeTransition(
                opacity: animation.drive(fadeTween),
                child: child,
              ),
            );
          },
        ),
            (route) => false,
      );
    }
  }

  Widget _buildDashboardContent() {
    final bool hasValidNetworkImage = _isValidUrl(_getImageUrl(empimg));
    final bool hasLocalImage =
        profileImage.isNotEmpty && !kIsWeb && File(profileImage).existsSync();

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: CircleAvatar(
              radius: 50,
              backgroundColor: Colors.grey.shade300,
              child:
              hasLocalImage
                  ? ClipOval(
                child: Image.file(
                  File(profileImage),
                  fit: BoxFit.cover,
                  width: 100,
                  height: 100,
                  errorBuilder:
                      (context, error, stackTrace) => const Icon(
                    Icons.person,
                    size: 80,
                    color: Colors.white,
                  ),
                ),
              )
                  : (hasValidNetworkImage
                  ? FutureBuilder<CacheManager>(
                future: _getCacheManager(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return CachedNetworkImage(
                      imageUrl: _getImageUrl(empimg),
                      cacheManager: snapshot.data,
                      imageBuilder:
                          (context, imageProvider) => Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            image: imageProvider,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      placeholder:
                          (context, url) =>
                      const CircularProgressIndicator(),
                      errorWidget:
                          (context, url, error) => const Icon(
                        Icons.person,
                        size: 80,
                        color: Colors.white,
                      ),
                    );
                  }
                  return const CircularProgressIndicator();
                },
              )
                  : const Icon(
                Icons.person,
                size: 80,
                color: Colors.white,
              )),
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: Text(
              employeeFullName,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: const Icon(Icons.business),
              title: Text(
                'Company: $registercompanyname',
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}