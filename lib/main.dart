import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "22BCS12351",
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _controller = TextEditingController();
  final List<String> options = ["Alphabets", "Numbers", "Highest Alphabet"];
  List<String> selectedOptions = [];
  Map<String, dynamic>? responseData;
  String? errorMessage;

  Future<void> sendRequest() async {
    try {
      final input = _controller.text.trim();
      print("User Input JSON: $input");
      final decodedJson = jsonDecode(input);
      print("Decoded JSON: $decodedJson");

      if (!decodedJson.containsKey("data") || decodedJson["data"] is! List) {
        setState(() => errorMessage = "Invalid JSON format");
        return;
      }

      final response = await http.post(
        Uri.parse("http://127.0.0.1:5000/bfhl"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(decodedJson),
      );

      print("API Response Status: ${response.statusCode}");
      print("API Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final decodedResponse = jsonDecode(response.body);
        setState(() {
          responseData = decodedResponse;
          // Only select options that have non-empty data
          selectedOptions = options.where((option) {
            if (option == "Alphabets")
              return decodedResponse["alphabets"]?.isNotEmpty == true;
            if (option == "Numbers")
              return decodedResponse["numbers"]?.isNotEmpty == true;
            if (option == "Highest Alphabet")
              return decodedResponse["highest_alphabet"]?.isNotEmpty == true;
            return false;
          }).toList();
          errorMessage = null;
        });
        print("Stored Response Data: $responseData");
      } else {
        setState(() => errorMessage = "Error: ${response.body}");
      }
    } catch (e) {
      print("Error: $e");
      setState(() => errorMessage = "Invalid JSON input");
    }
  }

  Widget buildResponse() {
    if (responseData == null || selectedOptions.isEmpty) return Container();

    List<Widget> displayData = [];

    if (selectedOptions.contains("Alphabets") &&
        responseData!.containsKey("alphabets")) {
      displayData.add(Text(
          "Alphabets: ${responseData!["alphabets"].join(", ")}",
          style: TextStyle(fontSize: 16)));
    }
    if (selectedOptions.contains("Numbers") &&
        responseData!.containsKey("numbers")) {
      displayData.add(Text("Numbers: ${responseData!["numbers"].join(", ")}",
          style: TextStyle(fontSize: 16)));
    }
    if (selectedOptions.contains("Highest Alphabet") &&
        responseData!.containsKey("highest_alphabet")) {
      displayData.add(Text(
          "Highest Alphabet: ${responseData!["highest_alphabet"].join(", ")}",
          style: TextStyle(fontSize: 16)));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: displayData.isNotEmpty
          ? displayData
          : [Text("No data available", style: TextStyle(color: Colors.grey))],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("22BCS12351", style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white)),
        backgroundColor: Colors.blue.shade700,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "API Input",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade700,
                ),
              ),
              SizedBox(height: 8),
              TextField(
                controller: _controller,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.blue.shade700, width: 2),
                  ),
                  hintText: 'Enter JSON data...',
                  fillColor: Colors.grey.shade50,
                  filled: true,
                ),
                maxLines: 3,
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: sendRequest,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade700,
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  "Submit",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
              if (errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Text(
                      errorMessage!,
                      style: TextStyle(color: Colors.red.shade700),
                    ),
                  ),
                ),
              if (responseData != null) ...[
                SizedBox(height: 24),
                Text(
                  "Multi Filter",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade700,
                  ),
                ),
                SizedBox(height: 8),
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: options.map((option) {
                    return ChoiceChip(
                      label: Text(option),
                      selected: selectedOptions.contains(option),
                      selectedColor: Colors.blue.shade100,
                      onSelected: (selected) {
                        setState(() {
                          selected
                              ? selectedOptions.add(option)
                              : selectedOptions.remove(option);
                        });
                      },
                    );
                  }).toList(),
                ),
                SizedBox(height: 24),
                Text(
                  "Filtered Response",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade700,
                  ),
                ),
                SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: buildResponse(),
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }
}
