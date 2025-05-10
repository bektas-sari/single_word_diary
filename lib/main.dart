import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:collection/collection.dart';

void main() {
  runApp(const SingleWordDiaryApp());
}

class SingleWordDiaryApp extends StatelessWidget {
  const SingleWordDiaryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Single Word Diary',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.deepPurple,
        useMaterial3: true,
      ),
      home: const DiaryHomePage(),
    );
  }
}

class DiaryHomePage extends StatefulWidget {
  const DiaryHomePage({super.key});

  @override
  State<DiaryHomePage> createState() => _DiaryHomePageState();
}

class _DiaryHomePageState extends State<DiaryHomePage> {
  final TextEditingController _controller = TextEditingController();
  final Map<String, String> _dailyWords = {};
  String? _error;

  void _saveWord() {
    final word = _controller.text.trim();
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    if (word.isEmpty) {
      setState(() => _error = "Please enter a word.");
      return;
    }
    if (_dailyWords.containsKey(today)) {
      setState(() => _error = "You've already added a word for today.");
      return;
    }

    setState(() {
      _dailyWords[today] = word;
      _controller.clear();
      _error = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final sortedDates = _dailyWords.keys.toList()
      ..sort((a, b) => b.compareTo(a)); // descending

    final mostFrequent = _dailyWords.values
        .groupListsBy((word) => word)
        .entries
        .sorted((a, b) => b.value.length.compareTo(a.value.length))
        .take(5)
        .map((e) => "${e.key} (${e.value.length}×)")
        .join(", ");

    return Scaffold(
      appBar: AppBar(
        title: const Text('Single Word Diary'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: "Today's Word",
                hintText: 'e.g. Happy',
                border: OutlineInputBorder(),
                errorText: _error,
              ),
              textCapitalization: TextCapitalization.words,
              onSubmitted: (_) => _saveWord(),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _saveWord,
              icon: const Icon(Icons.save),
              label: const Text('Save Word'),
            ),
            const SizedBox(height: 20),
            if (_dailyWords.isNotEmpty) ...[
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '🧠 Most Frequent Words: $mostFrequent',
                  style: const TextStyle(fontSize: 14),
                ),
              ),
              const Divider(height: 30),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '📅 Word History',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  itemCount: sortedDates.length,
                  itemBuilder: (context, index) {
                    final date = sortedDates[index];
                    final word = _dailyWords[date];
                    return Card(
                      child: ListTile(
                        leading: const Icon(Icons.calendar_today),
                        title: Text(word ?? ''),
                        subtitle: Text(date),
                      ),
                    );
                  },
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}