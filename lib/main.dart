import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Note {
  final String title;
  final String content;
  Note({required this.title, required this.content});
}

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.light;

  String paraphrasedText = '';

  Future<void> paraphraseText(String content) async {
    final response = await http.post(
      Uri.parse('YOUR_PUBLIC_URL_HERE/paraphrase'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'text': content}),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      setState(() {
        paraphrasedText = data['paraphrased_text'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Note App',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: _themeMode,
      home: EditScreen(
        note: Note(
          title: 'Title',
          content: '',
        ),
        toggleTheme: () {
          setState(() {
            _themeMode = _themeMode == ThemeMode.light
                ? ThemeMode.dark
                : ThemeMode.light;
          });
        },
        paraphraseContent: paraphraseText,
        paraphrasedText: paraphrasedText,
      ),
    );
  }
}

class EditScreen extends StatefulWidget {
  final Note? note;
  final VoidCallback? toggleTheme;
  final Function(String) paraphraseContent;
  final String paraphrasedText;

  const EditScreen({
    super.key,
    this.note,
    this.toggleTheme,
    required this.paraphraseContent,
    required this.paraphrasedText,
  });

  @override
  State<EditScreen> createState() => _EditScreenState();
}

class _EditScreenState extends State<EditScreen> {
  TextEditingController _titleController = TextEditingController();
  TextEditingController _contentController = TextEditingController();

  @override
  void initState() {
    if (widget.note != null) {
      _titleController = TextEditingController(text: widget.note!.title);
      _contentController = TextEditingController(text: widget.note!.content);
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 40, 16, 0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ThemeToggle(
                  onTap: widget.toggleTheme,
                  isDarkModeEnabled: Theme.of(context).brightness == Brightness.dark,
                ),
              ],
            ),
            Expanded(
              child: ListView(
                children: [
                  MyEditableText(
                    controller: _titleController,
                    hint: 'Title',
                    fontSize: 30,
                    paraphrasedText: '', // Pass the paraphrased text
                  ),
                  MyEditableText(
                    controller: _contentController,
                    hint: 'Type something here',
                    paraphrasedText: widget.paraphrasedText, // Pass the paraphrased text
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await widget.paraphraseContent(_contentController.text);
          setState(() {});
        },
        elevation: 10,
        backgroundColor: Color.fromARGB(255, 134, 115, 6),
        child: const Icon(Icons.book),
      ),
    );
  }
}

class MyEditableText extends StatefulWidget {
  final TextEditingController controller;
  final String hint;
  final double? fontSize;
  final String paraphrasedText;

  const MyEditableText({
    required this.controller,
    required this.hint,
    this.fontSize,
    required this.paraphrasedText,
  });

  @override
  State<MyEditableText> createState() => _MyEditableTextState();
}

class _MyEditableTextState extends State<MyEditableText> {
  bool _isPlaceholderVisible = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: widget.controller,
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyText1!.color,
            fontSize: 25,
          ),
          maxLines: null,
          onTap: () {
            setState(() {
              _isPlaceholderVisible = false;
            });
          },
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: _isPlaceholderVisible ? widget.hint : '',
            hintStyle: TextStyle(
              color: Theme.of(context).textTheme.caption!.color,
              fontSize: 19,
            ),
          ),
        ),
        SizedBox(height: 26),
        if (widget.paraphrasedText.isNotEmpty)
          Text(
            '\n Paraphrased text :  \n \n ${widget.paraphrasedText}',
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyText1!.color,
              fontSize: 25,
            ),
          ),
      ],
    );
  }
}

class ThemeToggle extends StatelessWidget {
  final VoidCallback? onTap;
  final bool isDarkModeEnabled;

  const ThemeToggle({
    this.onTap,
    required this.isDarkModeEnabled,
  });

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 30,
      backgroundColor: isDarkModeEnabled ? Colors.white : Colors.grey,
      child: IconButton(
        onPressed: onTap,
        icon: Icon(
          isDarkModeEnabled ? Icons.dark_mode : Icons.light_mode,
          color: isDarkModeEnabled ? Colors.grey : Colors.white,
        ),
      ),
    );
  }
}
