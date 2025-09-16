import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  double fontScale = 1.0;
  bool isDark = true;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(brightness: isDark ? Brightness.dark : Brightness.light),
      home: LaunchDecider(
        onThemeToggle: () => setState(() => isDark = !isDark),
        isDark: isDark,
        fontScale: fontScale,
        onFontScaleChanged: (v) => setState(() => fontScale = v),
      ),
    );
  }
}

// ======================= Launch Decider =======================

class LaunchDecider extends StatefulWidget {
  final VoidCallback onThemeToggle;
  final bool isDark;
  final double fontScale;
  final ValueChanged<double> onFontScaleChanged;

  const LaunchDecider({
    super.key,
    required this.onThemeToggle,
    required this.isDark,
    required this.fontScale,
    required this.onFontScaleChanged,
  });

  @override
  State<LaunchDecider> createState() => _LaunchDeciderState();
}

class _LaunchDeciderState extends State<LaunchDecider> {
  bool? firstLaunch;

  @override
  void initState() {
    super.initState();
    _checkFirstLaunch();
  }

  Future<void> _checkFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    final launched = prefs.getBool("launched") ?? false;

    if (!launched) {
      await prefs.setBool("launched", true);
      setState(() => firstLaunch = true);
    } else {
      setState(() => firstLaunch = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (firstLaunch == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return TitlePage(
      onThemeToggle: widget.onThemeToggle,
      isDark: widget.isDark,
      fontScale: widget.fontScale,
      onFontScaleChanged: widget.onFontScaleChanged,
    );
  }
}

// ======================= Title Page =======================

class TitlePage extends StatelessWidget {
  final VoidCallback onThemeToggle;
  final bool isDark;
  final double fontScale;
  final ValueChanged<double> onFontScaleChanged;

  const TitlePage({
    super.key,
    required this.onThemeToggle,
    required this.isDark,
    required this.fontScale,
    required this.onFontScaleChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "TimeSync",
              style: TextStyle(
                fontSize: 40 * fontScale,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => HomeScreen(
                      onThemeToggle: onThemeToggle,
                      isDark: isDark,
                      fontScale: fontScale,
                      onFontScaleChanged: onFontScaleChanged,
                    ),
                  ),
                );
              },
              child: const Text("始める"),
            ),
            const SizedBox(height: 15),
            OutlinedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SettingsPage(
                      onThemeToggle: onThemeToggle,
                      isDark: isDark,
                      fontScale: fontScale,
                      onFontScaleChanged: onFontScaleChanged,
                    ),
                  ),
                );
              },
              child: const Text("設定"),
            ),
          ],
        ),
      ),
    );
  }
}

// ======================= Home Screen =======================

class HomeScreen extends StatefulWidget {
  final VoidCallback onThemeToggle;
  final bool isDark;
  final double fontScale;
  final ValueChanged<double> onFontScaleChanged;

  const HomeScreen({
    super.key,
    required this.onThemeToggle,
    required this.isDark,
    required this.fontScale,
    required this.onFontScaleChanged,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.isDark ? Colors.black : Colors.white,
      appBar: AppBar(
        backgroundColor: widget.isDark ? Colors.grey[900] : Colors.grey[200],
        title: Text(
          "ホーム",
          style: TextStyle(
            color: widget.isDark ? Colors.white : Colors.black,
            fontSize: 20 * widget.fontScale,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SettingsPage(
                    onThemeToggle: widget.onThemeToggle,
                    isDark: widget.isDark,
                    fontScale: widget.fontScale,
                    onFontScaleChanged: widget.onFontScaleChanged,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            // カレンダー
            TableCalendar(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: (selected, focused) {
                setState(() {
                  _selectedDay = selected;
                  _focusedDay = focused;
                });
              },
              calendarStyle: CalendarStyle(
                todayDecoration: BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
                selectedDecoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                defaultTextStyle: TextStyle(
                  color: widget.isDark ? Colors.white : Colors.black,
                  fontSize: 14 * widget.fontScale,
                ),
              ),
              headerStyle: HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                titleTextStyle: TextStyle(
                  fontSize: 16 * widget.fontScale,
                  fontWeight: FontWeight.bold,
                  color: widget.isDark ? Colors.white : Colors.black,
                ),
              ),
            ),
            const SizedBox(height: 12),
            // 管理用の4つの正方形
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                children: [
                  _buildSquare("睡眠管理", "睡眠の細かな設定の管理", widget.isDark),
                  _buildSquare("勉強時間管理", "勉強時間の設定の管理", widget.isDark),
                  _buildSquare("スケジュール管理", "スケジュールの設定の管理", widget.isDark),
                  _buildSquare("食事管理", "３食で摂取した五大栄養素の管理を", widget.isDark),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSquare(String title, String desc, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18 * widget.fontScale,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            desc,
            style: TextStyle(
              fontSize: 14 * widget.fontScale,
              color: isDark ? Colors.white70 : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}

// ======================= Settings Page =======================

class SettingsPage extends StatelessWidget {
  final VoidCallback onThemeToggle;
  final bool isDark;
  final double fontScale;
  final ValueChanged<double> onFontScaleChanged;

  const SettingsPage({
    super.key,
    required this.onThemeToggle,
    required this.isDark,
    required this.fontScale,
    required this.onFontScaleChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("設定")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ListTile(
              title: const Text("背景色を切り替える"),
              trailing: Switch(
                value: isDark,
                onChanged: (_) => onThemeToggle(),
              ),
            ),
            const SizedBox(height: 20),
            const Text("フォントサイズ調整"),
            Slider(
              value: fontScale,
              min: 0.5,
              max: 1.5,
              divisions: 10,
              label: "${(fontScale * 100).toInt()}%",
              onChanged: onFontScaleChanged,
            ),
          ],
        ),
      ),
    );
  }
}
