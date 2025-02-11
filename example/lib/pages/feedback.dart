import 'package:flutter/material.dart';

class FeedbackPage extends StatefulWidget {
  const FeedbackPage({super.key});
  @override
  _FeedbackPageState createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  int _selectedStars = 0;
  bool _feltSafe = true;
  final TextEditingController _reasonController = TextEditingController();

  void _submitFeedback() {
    String feedback = '''
    Stars: $_selectedStars
    Felt Safe: $_feltSafe
    Reason (if unsafe): ${_feltSafe ? "N/A" : _reasonController.text}
    ''';

    // You can handle submission logic here (e.g., send to a backend or save locally)
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Feedback Submitted"),
        content: Text(feedback),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Feedback"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "How would you rate your journey?",
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            Row(
              children: List.generate(5, (index) {
                return IconButton(
                  onPressed: () {
                    setState(() {
                      _selectedStars = index + 1;
                    });
                  },
                  icon: Icon(
                    Icons.star,
                    color: _selectedStars > index ? Colors.amber : Colors.grey,
                  ),
                );
              }),
            ),
            const SizedBox(height: 16),
            const Text(
              "Did you feel safe during your journey?",
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            Row(
              children: [
                Radio<bool>(
                  value: true,
                  groupValue: _feltSafe,
                  onChanged: (value) {
                    setState(() {
                      _feltSafe = value!;
                    });
                  },
                ),
                const Text("Yes"),
                const SizedBox(width: 20),
                Radio<bool>(
                  value: false,
                  groupValue: _feltSafe,
                  onChanged: (value) {
                    setState(() {
                      _feltSafe = value!;
                    });
                  },
                ),
                const Text("No"),
              ],
            ),
            if (!_feltSafe) ...[
              const SizedBox(height: 16),
              const Text(
                "Please provide a reason:",
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
              TextField(
                controller: _reasonController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Describe why you felt unsafe...",
                ),
              ),
            ],
            const SizedBox(height: 24),
            Center(
              child: ElevatedButton(
                onPressed: _submitFeedback,
                child: const Text("Submit Feedback"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
