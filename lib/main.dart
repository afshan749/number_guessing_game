import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const NumberGuessingApp());
}

class GameRecord {
  final int targetNumber;
  final int attempts;
  final DateTime timestamp;

  GameRecord({
    required this.targetNumber,
    required this.attempts,
    required this.timestamp,
  });
}

class AppColors {
  static const Color background = Color(0xFF100E1B);
  static const Color cardBg = Color(0xFF1B192B);
  static const Color purpleAccent = Color(0xFF8338EC);
  static const Color purpleLight = Color(0xFFA855F7);
  static const Color secondaryBtn = Color(0xFF28263A);
  static const Color textGrey = Color(0xFF9CA3AF);
  static const Color gold = Color(0xFFFBBF24);
}

class NumberGuessingApp extends StatelessWidget {
  const NumberGuessingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Number Guessing Game',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.purpleAccent,
          surface: AppColors.cardBg,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

List<GameRecord> globalGameHistory = [];

// ==========================================
// 1. HOME SCREEN
// ==========================================
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'Game History',
            icon: const Icon(Icons.history_rounded, color: Colors.white70),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (ctx) => const HistoryScreen()),
              );
              setState(() {});
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'YOUR DAILY BRAIN BOOST',
                style: TextStyle(
                  color: AppColors.textGrey,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.5,
                ),
              ),
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 170,
                    height: 170,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.purpleAccent.withValues(alpha: 0.15),
                    ),
                  ),
                  Container(
                    width: 130,
                    height: 130,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.purpleLight,
                        width: 14,
                      ),
                      color: Colors.white,
                    ),
                    child: Center(
                      child: Container(
                        width: 45,
                        height: 45,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.purpleAccent,
                        ),
                      ),
                    ),
                  ),
                  const Positioned(
                    top: 15,
                    right: 15,
                    child: Icon(
                      Icons.gps_fixed_rounded,
                      color: Colors.tealAccent,
                      size: 48,
                    ),
                  ),
                ],
              ),
              const Column(
                children: [
                  Text(
                    'Number Guessing\nGame',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.2,
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Test Your Mind & Guess the Number!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Guess the secret number between 1 and 100.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textGrey,
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.purpleAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (ctx) => const GameScreen()),
                        );
                      },
                      child: const Text(
                        'START GAME',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton.icon(
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (ctx) => const HistoryScreen()),
                      );
                      setState(() {});
                    },
                    icon: const Icon(Icons.bar_chart_rounded,
                        size: 18, color: AppColors.textGrey),
                    label: Text(
                      'VIEW HISTORY (${globalGameHistory.length})',
                      style: const TextStyle(
                        color: AppColors.textGrey,
                        fontSize: 12,
                        letterSpacing: 1.1,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'One number. How many guesses?',
                    style: TextStyle(
                      color: AppColors.textGrey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==========================================
// 2. GAME SCREEN
// ==========================================
class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => GameScreenState();
}

class GameScreenState extends State<GameScreen> {
  final TextEditingController guessController = TextEditingController();
  late int secretNumber;
  int attempts = 0;
  String resultMessage = 'Your result will appear here!';
  Color resultColor = Colors.white70;

  @override
  void initState() {
    super.initState();
    generateSecretNumber();
  }

  void generateSecretNumber() {
    secretNumber = Random().nextInt(100) + 1;
  }

  void resetGame() {
    setState(() {
      generateSecretNumber();
      attempts = 0;
      guessController.clear();
      resultMessage = 'Your result will appear here!';
      resultColor = Colors.white70;
    });
  }

  void checkGuess() {
    final input = guessController.text.trim();
    if (input.isEmpty) {
      setState(() {
        resultMessage = 'Please enter a number first!';
        resultColor = Colors.orangeAccent;
      });
      return;
    }

    final int? guess = int.tryParse(input);
    if (guess == null || guess < 1 || guess > 100) {
      setState(() {
        resultMessage = 'Enter a valid number between 1 and 100.';
        resultColor = Colors.redAccent;
      });
      return;
    }

    setState(() {
      attempts++;
      guessController.clear();
    });

    if (guess == secretNumber) {
      globalGameHistory.insert(
        0,
        GameRecord(
          targetNumber: secretNumber,
          attempts: attempts,
          timestamp: DateTime.now(),
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (ctx) => WinScreen(
            attempts: attempts,
            secretNumber: secretNumber,
          ),
        ),
      );
    } else if (guess < secretNumber) {
      setState(() {
        resultMessage = 'Too Low! Try a higher number than $guess.';
resultColor = Colors.lightBlueAccent;
});
} else {
setState(() {
resultMessage = 'Too High! Try a lower number than $guess.';
resultColor = Colors.amberAccent;
});
}
}
@override
void dispose() {
guessController.dispose();
super.dispose();
}
@override
Widget build(BuildContext context) {
return Scaffold(
appBar: AppBar(
backgroundColor: Colors.transparent,
elevation: 0,
leading: IconButton(
icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
onPressed: () => Navigator.pop(context),
),
),
body: SafeArea(
child: SingleChildScrollView(
padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
child: Column(
crossAxisAlignment: CrossAxisAlignment.center,
children: [
const Text(
"LET'S PLAY",
style: TextStyle(
color: AppColors.textGrey,
fontSize: 12,
fontWeight: FontWeight.w600,
letterSpacing: 1.5,
),
),
const SizedBox(height: 8),
const Text(
'Number Guessing Game',
style: TextStyle(
fontSize: 24,
fontWeight: FontWeight.bold,
color: Colors.white,
),
),
const SizedBox(height: 6),
const Text(
'Guess the Secret Number!',
style: TextStyle(
fontSize: 14,
color: AppColors.textGrey,
),
),
const SizedBox(height: 28),
Container(
width: double.infinity,
padding: const EdgeInsets.symmetric(vertical: 24),
decoration: BoxDecoration(
color: AppColors.cardBg,
borderRadius: BorderRadius.circular(18),
border: Border.all(color: Colors.white10),
),
child: const Column(
children: [
Text(
'SECRET NUMBER RANGE',
style: TextStyle(
color: AppColors.textGrey,
fontSize: 11,
fontWeight: FontWeight.w600,
letterSpacing: 1.3,
),
),
SizedBox(height: 10),
Text(
'1 — 100',
style: TextStyle(
fontSize: 34,
fontWeight: FontWeight.bold,
color: Colors.white,
),
),
],
),
),
const SizedBox(height: 28),
const Align(
alignment: Alignment.centerLeft,
child: Text(
'Your guess',
style: TextStyle(
color: Colors.white70,
fontSize: 14,
fontWeight: FontWeight.w500,
),
),
),
const SizedBox(height: 10),
TextField(
controller: guessController,
keyboardType: TextInputType.number,
inputFormatters: [FilteringTextInputFormatter.digitsOnly],
style: const TextStyle(
color: Colors.black87,
fontSize: 16,
fontWeight: FontWeight.w600,
),
onSubmitted: (value) => checkGuess(),
decoration: InputDecoration(
filled: true,
fillColor: Colors.white,
hintText: 'Enter your number (1-100)',
hintStyle: const TextStyle(
color: Colors.black45,
fontWeight: FontWeight.normal,
),
contentPadding: const EdgeInsets.symmetric(
horizontal: 18,
vertical: 16,
),
border: OutlineInputBorder(
borderRadius: BorderRadius.circular(14),
borderSide: BorderSide.none,
),
),
),
const SizedBox(height: 16),
Row(
children: [
Expanded(
flex: 2,
child: SizedBox(
height: 52,
child: ElevatedButton(
style: ElevatedButton.styleFrom(
backgroundColor: AppColors.purpleAccent,
shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(14),
),
),
onPressed: checkGuess,
child: const Text(
'GUESS',
style: TextStyle(
fontSize: 14,
fontWeight: FontWeight.bold,
letterSpacing: 1.2,
color: Colors.white,
),
),
),
),
),
const SizedBox(width: 12),
Expanded(
flex: 1,
child: SizedBox(
height: 52,
child: ElevatedButton(
style: ElevatedButton.styleFrom(
backgroundColor: AppColors.secondaryBtn,
shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(14),
),
),
onPressed: resetGame,
child: const Text(
'RESET',
style: TextStyle(
fontSize: 14,
fontWeight: FontWeight.bold,
letterSpacing: 1.1,
color: Colors.white70,
),
),
),
),
),
],
),
const SizedBox(height: 24),
Container(
width: double.infinity,
padding:
const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
decoration: BoxDecoration(
color: AppColors.cardBg,
borderRadius: BorderRadius.circular(18),
border: Border.all(color: Colors.white10),
),
child: Column(
children: [
const Text(
'RESULT',
style: TextStyle(
color: AppColors.textGrey,
fontSize: 11,
fontWeight: FontWeight.w600,
letterSpacing: 1.3,
),
),
const SizedBox(height: 12),
Text(
resultMessage,
textAlign: TextAlign.center,
style: TextStyle(
fontSize: 16,
fontWeight: FontWeight.w500,
color: resultColor,
),
),
],
),
),
const SizedBox(height: 24),
Container(
padding:
const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
decoration: BoxDecoration(
color: AppColors.cardBg,
borderRadius: BorderRadius.circular(12),
border: Border.all(color: Colors.white10),
),
child: Text(
'Attempts: $attempts',
style: const TextStyle(
color: Colors.white70,
fontSize: 14,
fontWeight: FontWeight.w500,
),
),
),
],
),
),
),
);
}
}
// ==========================================
// 3. WIN SCREEN
// ==========================================
class WinScreen extends StatelessWidget {
final int attempts;
final int secretNumber;
const WinScreen({
super.key,
required this.attempts,
required this.secretNumber,
});
@override
Widget build(BuildContext context) {
return Scaffold(
body: SafeArea(
child: Padding(
padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
child: Column(
mainAxisAlignment: MainAxisAlignment.spaceBetween,
children: [
const Text(
'CHALLENGE COMPLETE',
style: TextStyle(
color: AppColors.textGrey,
fontSize: 12,
fontWeight: FontWeight.w600,
letterSpacing: 1.5,
),
),
Container(
width: 170,
height: 170,
decoration: BoxDecoration(
shape: BoxShape.circle,
color: AppColors.gold.withValues(alpha: 0.12),
),
child: const Center(
child: Icon(
Icons.emoji_events_rounded,
size: 110,
color: AppColors.gold,
),
),
),
Column(
children: [
const Text(
'You Won!',
style: TextStyle(
fontSize: 16,
fontWeight: FontWeight.w600,
color: Colors.white70,
),
),
const SizedBox(height: 8),
const Text(
'Congratulations!',
style: TextStyle(
fontSize: 32,
fontWeight: FontWeight.bold,
color: Colors.white,
),
),
const SizedBox(height: 10),
Text(
'You guessed the correct number ($secretNumber)!',
textAlign: TextAlign.center,
style: const TextStyle(
fontSize: 14,
color: AppColors.textGrey,
),
),
const SizedBox(height: 24),
Container(
padding: const EdgeInsets.symmetric(
horizontal: 24, vertical: 12),
decoration: BoxDecoration(
color: AppColors.cardBg,
borderRadius: BorderRadius.circular(12),
border: Border.all(color: Colors.white10),
),
child: Text(
'Attempts: $attempts',
style: const TextStyle(
fontSize: 15,
fontWeight: FontWeight.w600,
color: Colors.white,
),
),
),
],
),
Column(
children: [
SizedBox(
width: double.infinity,
height: 54,
child: ElevatedButton(
style: ElevatedButton.styleFrom(
backgroundColor: AppColors.purpleAccent,
shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(14),
),
),
onPressed: () {
Navigator.pushReplacement(
context,
MaterialPageRoute(
builder: (ctx) => const GameScreen()),
);
},
child: const Text(
'PLAY AGAIN',
style: TextStyle(
fontSize: 14,
fontWeight: FontWeight.bold,
letterSpacing: 1.2,
color: Colors.white,
),
),
),
),
const SizedBox(height: 12),
SizedBox(
width: double.infinity,
height: 54,
child: ElevatedButton(
style: ElevatedButton.styleFrom(
backgroundColor: AppColors.secondaryBtn,
shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(14),
),
),
onPressed: () {
Navigator.popUntil(context, (route) => route.isFirst);
},
child: const Text(
'BACK TO HOME',
style: TextStyle(
fontSize: 14,
fontWeight: FontWeight.bold,
letterSpacing: 1.2,
color: Colors.white,
),
),
),
),
],
),
],
),
),
),
);
}
}
// ==========================================
// 4. HISTORY SCREEN
// ==========================================
class HistoryScreen extends StatefulWidget {
const HistoryScreen({super.key});
@override
State createState() => HistoryScreenState();
}
class HistoryScreenState extends State {
void clearHistory() {
setState(() {
globalGameHistory.clear();
});
}
String formatTime(DateTime dt) {
final hour = dt.hour.toString().padLeft(2, '0');
final minute = dt.minute.toString().padLeft(2, '0');
return '${dt.day}/${dt.month}/${dt.year} • $hour:$minute';
}
@override
Widget build(BuildContext context) {
int? bestScore;
if (globalGameHistory.isNotEmpty) {
bestScore = globalGameHistory
.map((e) => e.attempts)
.reduce((a, b) => a < b ? a : b);
}
return Scaffold(
appBar: AppBar(
backgroundColor: Colors.transparent,
elevation: 0,
title: const Text(
'GAME HISTORY',
style: TextStyle(
fontSize: 14,
fontWeight: FontWeight.bold,
letterSpacing: 1.5,
),
),
centerTitle: true,
leading: IconButton(
icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
onPressed: () => Navigator.pop(context),
),
actions: [
if (globalGameHistory.isNotEmpty)
IconButton(
tooltip: 'Clear History',
icon: const Icon(Icons.delete_outline_rounded,
color: Colors.redAccent),
onPressed: clearHistory,
),
],
),
body: SafeArea(
child: Padding(
padding: const EdgeInsets.all(24.0),
child: Column(
children: [
Container(
padding: const EdgeInsets.all(20),
decoration: BoxDecoration(
color: AppColors.cardBg,
borderRadius: BorderRadius.circular(18),
border: Border.all(color: Colors.white10),
),
child: Row(
mainAxisAlignment: MainAxisAlignment.spaceAround,
children: [
StatColumn(
label: 'GAMES WON',
value: '${globalGameHistory.length}',
),
Container(width: 1, height: 40, color: Colors.white12),
StatColumn(
label: 'BEST ATTEMPTS',
value: bestScore != null ? '$bestScore' : '-',
valueColor: AppColors.gold,
),
],
),
),
const SizedBox(height: 24),
Expanded(
child: globalGameHistory.isEmpty
? const Center(
child: Column(
mainAxisAlignment: MainAxisAlignment.center,
children: [
Icon(Icons.history_toggle_off_rounded,
size: 64, color: Colors.white24),
SizedBox(height: 16),
Text(
'No games played yet',
style: TextStyle(
fontSize: 16,
fontWeight: FontWeight.w600,
color: Colors.white70,
),
),
SizedBox(height: 6),
Text(
'Win a game to record your score here!',
style: TextStyle(
fontSize: 13,
color: AppColors.textGrey,
),
),
],
),
)
: ListView.separated(
itemCount: globalGameHistory.length,
separatorBuilder: (ctx, idx) =>
const SizedBox(height: 12),
itemBuilder: (context, index) {
final record = globalGameHistory[index];
return Container(
padding: const EdgeInsets.symmetric(
horizontal: 18, vertical: 16),
decoration: BoxDecoration(
color: AppColors.cardBg,
borderRadius: BorderRadius.circular(14),
border: Border.all(color: Colors.white10),
),
child: Row(
mainAxisAlignment: MainAxisAlignment.spaceBetween,
children: [
Row(
children: [
Container(
width: 44,
height: 44,
decoration: BoxDecoration(
color: AppColors.purpleAccent
.withValues(alpha: 0.2),
borderRadius: BorderRadius.circular(12),
),
child: Center(
child: Text(
'${record.targetNumber}',
style: const TextStyle(
color: AppColors.purpleLight,
fontWeight: FontWeight.bold,
fontSize: 16,
),
),
),
),
const SizedBox(width: 14),
Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
const Text(
'Secret Number Found',
style: TextStyle(
color: Colors.white,
fontWeight: FontWeight.w600,
fontSize: 14,
),
),
const SizedBox(height: 4),
Text(
formatTime(record.timestamp),
style: const TextStyle(
color: AppColors.textGrey,
fontSize: 12,
),
),
],
),
],
),
Container(
padding: const EdgeInsets.symmetric(
horizontal: 12, vertical: 6),
decoration: BoxDecoration(
color: AppColors.secondaryBtn,
borderRadius: BorderRadius.circular(10),
),
child: Text(
'${record.attempts} tries',
style: const TextStyle(
color: Colors.white,
fontWeight: FontWeight.bold,
fontSize: 13,
),
),
),
],
),
);
},
),
),
],
),
),
),
);
}
}
class StatColumn extends StatelessWidget {
final String label;
final String value;
final Color valueColor;
const StatColumn({
super.key,
required this.label,
required this.value,
this.valueColor = Colors.white,
});
@override
Widget build(BuildContext context) {
return Column(
children: [
Text(
label,
style: const TextStyle(
color: AppColors.textGrey,
fontSize: 11,
fontWeight: FontWeight.w600,
letterSpacing: 1.2,
),
),
const SizedBox(height: 8),
Text(
value,
style: TextStyle(
color: valueColor,
fontSize: 26,
fontWeight: FontWeight.bold,
),
),
],
);
}
}