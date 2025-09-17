import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

// main
void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // グローバルに共有する Notifier（これでどこからでも即時反映）
  final ValueNotifier<bool> isDarkNotifier = ValueNotifier<bool>(true);
  final ValueNotifier<double> fontScaleNotifier = ValueNotifier<double>(1.0);

  @override
  void dispose() {
    isDarkNotifier.dispose();
    fontScaleNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: isDarkNotifier,
      builder: (context, isDark, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            brightness: isDark ? Brightness.dark : Brightness.light,
            // 基本フォントスケールは各Textで掛け合わせるのでここでは変更しない
          ),
          // これがあると TableCalendar の locale:'ja_JP' が安全に動く
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('ja', 'JP')],
          home: TitleScreen(
            isDarkNotifier: isDarkNotifier,
            fontScaleNotifier: fontScaleNotifier,
          ),
        );
      },
    );
  }
}

/* =========================
   Title Screen (TimeSync)
   ========================= */
class TitleScreen extends StatelessWidget {
  final ValueNotifier<bool> isDarkNotifier;
  final ValueNotifier<double> fontScaleNotifier;

  const TitleScreen({
    super.key,
    required this.isDarkNotifier,
    required this.fontScaleNotifier,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder2<bool, double>(
      first: isDarkNotifier,
      second: fontScaleNotifier,
      builder: (context, isDark, fontScale, _) {
        return Scaffold(
          backgroundColor: isDark ? Colors.black : Colors.white,
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'TimeSync',
                  style: TextStyle(
                    fontSize: 40 * fontScale,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Created by Kasuxx',
                  style: TextStyle(
                    fontSize: 12 * fontScale,
                    color: (isDark ? Colors.white70 : Colors.black54),
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 28),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => HomeScreen(
                          isDarkNotifier: isDarkNotifier,
                          fontScaleNotifier: fontScaleNotifier,
                        ),
                      ),
                    );
                  },
                  child: Text(
                    '始める',
                    style: TextStyle(fontSize: 16 * fontScale),
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SettingsPage(
                          isDarkNotifier: isDarkNotifier,
                          fontScaleNotifier: fontScaleNotifier,
                        ),
                      ),
                    );
                  },
                  child: Text('設定', style: TextStyle(fontSize: 14 * fontScale)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/* =========================
   Home Screen (calendar + 4 squares)
   ========================= */
class HomeScreen extends StatefulWidget {
  final ValueNotifier<bool> isDarkNotifier;
  final ValueNotifier<double> fontScaleNotifier;

  const HomeScreen({
    super.key,
    required this.isDarkNotifier,
    required this.fontScaleNotifier,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder2<bool, double>(
      first: widget.isDarkNotifier,
      second: widget.fontScaleNotifier,
      builder: (context, isDark, fontScale, _) {
        final bgColor = isDark ? Colors.black : Colors.white;
        final topBarColor = isDark ? Colors.grey[900] : Colors.grey[200];

        final cardData = [
          {"title": "睡眠管理", "desc": "睡眠の細かな管理", "emoji": "🛏️"},
          {"title": "勉強時間管理", "desc": "勉強時間の管理", "emoji": "✏️"},
          {"title": "スケジュール管理", "desc": "スケジュールの管理", "emoji": "📅"},
          {"title": "食事管理", "desc": "食事内容の管理", "emoji": "🍽️"},
        ];

        return Scaffold(
          backgroundColor: bgColor,
          appBar: AppBar(
            backgroundColor: topBarColor,
            title: Text(
              'ホーム',
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black,
                fontSize: 20 * fontScale,
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  Icons.settings,
                  color: isDark ? Colors.grey[300] : Colors.grey[700],
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SettingsPage(
                        isDarkNotifier: widget.isDarkNotifier,
                        fontScaleNotifier: widget.fontScaleNotifier,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          body: Column(
            children: [
              // カレンダー（日本語）
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12.0,
                  vertical: 8.0,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey[850] : Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: TableCalendar(
                    locale: 'ja_JP',
                    firstDay: DateTime.utc(2020, 1, 1),
                    lastDay: DateTime.utc(2030, 12, 31),
                    focusedDay: _focusedDay,
                    calendarFormat: CalendarFormat.month,
                    selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                    onDaySelected: (selected, focused) {
                      setState(() {
                        _selectedDay = selected;
                        _focusedDay = focused;
                      });
                    },
                    headerStyle: HeaderStyle(
                      formatButtonVisible: false,
                      titleCentered: true,
                      titleTextStyle: TextStyle(
                        fontSize: 16 * fontScale,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
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
                        color: isDark ? Colors.white : Colors.black,
                        fontSize: 14 * fontScale,
                      ),
                      weekendTextStyle: TextStyle(
                        color: isDark ? Colors.white70 : Colors.black87,
                        fontSize: 14 * fontScale,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // 4つの正方形カード（半透明の絵文字背景）
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: GridView.count(
                    crossAxisCount: 2,
                    childAspectRatio: 1,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    children: List.generate(cardData.length, (index) {
                      final item = cardData[index];
                      return ManagementCard(
                        title: item['title']!,
                        description: item['desc']!,
                        emoji: item['emoji']!,
                        isDark: isDark,
                        fontScale: fontScale,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => EmptyDetailPage(
                                title: item['title']!,
                                isDark: isDark,
                                fontScale: fontScale,
                              ),
                            ),
                          );
                        },
                      );
                    }),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/* Management Card widget */
class ManagementCard extends StatelessWidget {
  final String title;
  final String description;
  final String emoji;
  final bool isDark;
  final double fontScale;
  final VoidCallback onTap;

  const ManagementCard({
    super.key,
    required this.title,
    required this.description,
    required this.emoji,
    required this.isDark,
    required this.fontScale,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cardBg = isDark ? Colors.grey[850] : Colors.grey[200];
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Stack(
          children: [
            // 半透明の大きな絵文字を背景にして中央に表示
            Positioned.fill(
              child: Opacity(
                opacity: 0.12,
                child: Center(
                  child: Text(
                    emoji,
                    style: TextStyle(fontSize: 120 * fontScale),
                  ),
                ),
              ),
            ),
            // テキスト類
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18 * fontScale,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 13 * fontScale,
                      color: isDark ? Colors.white70 : Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/* 空の詳細ページ（背景はホームと同じモードに合わせた空白ページ） */
class EmptyDetailPage extends StatelessWidget {
  final String title;
  final bool isDark;
  final double fontScale;
  const EmptyDetailPage({
    super.key,
    required this.title,
    required this.isDark,
    required this.fontScale,
  });

  @override
  Widget build(BuildContext context) {
    final bg = isDark ? Colors.black : Colors.white;
    final top = isDark ? Colors.grey[900] : Colors.grey[200];

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(title: Text(title), backgroundColor: top),
      body: Center(
        child: Text(
          'ここに$title の詳細ページを作る',
          style: TextStyle(
            fontSize: 16 * fontScale,
            color: isDark ? Colors.white : Colors.black,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

/* =========================
   Settings Page
   ========================= */
class SettingsPage extends StatelessWidget {
  final ValueNotifier<bool> isDarkNotifier;
  final ValueNotifier<double> fontScaleNotifier;

  const SettingsPage({
    super.key,
    required this.isDarkNotifier,
    required this.fontScaleNotifier,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder2<bool, double>(
      first: isDarkNotifier,
      second: fontScaleNotifier,
      builder: (context, isDark, fontScale, _) {
        return Scaffold(
          appBar: AppBar(title: const Text('設定')),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                ListTile(
                  title: const Text('背景を黒/白で切り替える'),
                  trailing: Switch(
                    value: isDark,
                    onChanged: (v) => isDarkNotifier.value = v,
                  ),
                ),
                const SizedBox(height: 20),
                Text('フォントサイズ: ${(fontScale * 100).round()}%'),
                Slider(
                  value: fontScale,
                  min: 0.5,
                  max: 1.5,
                  divisions: 10,
                  label: '${(fontScale * 100).round()}%',
                  onChanged: (v) => fontScaleNotifier.value = v,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/* ======= helper: ValueListenableBuilder2 （2つの Notifier を一緒に扱うための小ヘルパー） ======= */
typedef V2WidgetBuilder<T1, T2> =
    Widget Function(BuildContext, T1, T2, Widget?);

class ValueListenableBuilder2<T1, T2> extends StatefulWidget {
  final ValueNotifier<T1> first;
  final ValueNotifier<T2> second;
  final V2WidgetBuilder<T1, T2> builder;

  const ValueListenableBuilder2({
    super.key,
    required this.first,
    required this.second,
    required this.builder,
  });

  @override
  State<ValueListenableBuilder2<T1, T2>> createState() =>
      _ValueListenableBuilder2State<T1, T2>();
}

class _ValueListenableBuilder2State<T1, T2>
    extends State<ValueListenableBuilder2<T1, T2>> {
  @override
  void initState() {
    super.initState();
    widget.first.addListener(_rebuild);
    widget.second.addListener(_rebuild);
  }

  @override
  void didUpdateWidget(covariant ValueListenableBuilder2<T1, T2> oldWidget) {
    if (oldWidget.first != widget.first) {
      oldWidget.first.removeListener(_rebuild);
      widget.first.addListener(_rebuild);
    }
    if (oldWidget.second != widget.second) {
      oldWidget.second.removeListener(_rebuild);
      widget.second.addListener(_rebuild);
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    widget.first.removeListener(_rebuild);
    widget.second.removeListener(_rebuild);
    super.dispose();
  }

  void _rebuild() => setState(() {});

  @override
  Widget build(BuildContext context) {
    return widget.builder(
      context,
      widget.first.value,
      widget.second.value,
      null,
    );
  }
}
