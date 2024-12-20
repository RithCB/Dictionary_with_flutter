import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() {
  runApp(DictionaryApp());
}

class DictionaryApp extends StatelessWidget {
  const DictionaryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'វចនានុក្រម អង់គ្លេស-ខ្មែរ',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        scaffoldBackgroundColor: Colors.grey[50],
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _controller = TextEditingController();
  String? _word;
  String? _translation;
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _translateWord(String word) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await http.get(
        Uri.parse(
            'https://api.mymemory.translated.net/get?q=$word&langpair=en|km'),
      );

      print('Response body: ${response.body}'); // Debug statement

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        if (data['responseData'] != null &&
            data['responseData']['translatedText'] != null) {
          setState(() {
            _word = word;
            _translation = data['responseData']['translatedText'];
          });
        } else {
          setState(() {
            _errorMessage = 'បញ្ហាបកប្រែ ពាក្យនេះអាចមិនមាននៅក្នុងវចនានុក្រម។';
          });
        }
      } else {
        setState(() {
          _errorMessage = 'មិនអាចបកប្រែពាក្យនេះទេ សូមព្យាយាមវាឡើងវិញ។';
        });
      }
    } catch (error) {
      print('Error occurred: $error'); // Debug statement
      setState(() {
        _errorMessage = 'មានបញ្ហាកើតឡើង សូមពិនិត្យការតភ្ជាប់អ៊ីនធឺណិត។';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('វចនានុក្រម អង់គ្លេស-ខ្មែរ',
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 2,
                    blurRadius: 7,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: TextField(
                controller: _controller,
                decoration: InputDecoration(
                  hintText: 'បញ្ចូលពាក្យអង់គ្លេស',
                  border: InputBorder.none,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.clear, color: Colors.teal),
                    onPressed: () => _controller.clear(),
                  ),
                ),
                onSubmitted: _translateWord,
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () => _translateWord(_controller.text),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                child: Text('បកប្រែ',
                    style: TextStyle(fontSize: 18, color: Colors.white)),
              ),
            ),
            SizedBox(height: 20),
            if (_isLoading) CircularProgressIndicator(),
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  _errorMessage!,
                  style: TextStyle(color: Colors.red, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ),
            if (_word != null && _translation != null) ...[
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 2,
                      blurRadius: 7,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ពាក្យ: $_word',
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'ការបកប្រែជាភាសាខ្មែរ:',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                    ),
                    SizedBox(height: 5),
                    Text(
                      _translation!,
                      style: TextStyle(fontSize: 18),
                      textAlign: TextAlign.justify,
                    ),
                  ],
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}
