import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String input = '';
  String result = '';
  List<String> history = [];

  @override
  void initState() {
    super.initState();
    loadHistory();
  }

  Future<void> loadHistory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      history = prefs.getStringList('history') ?? [];
    });
  }

  Future<void> saveHistory(String entry) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    history.add(entry);
    await prefs.setStringList('history', history);
  }

  Future<void> clearHistory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('history');
    setState(() {
      history = [];
    });
  }

  void buttonPressed(String value) {
    setState(() {
      if (value == 'C') {
        input = '';
        result = '';
      } else if (value == '⌫') {
        if (input.isNotEmpty) {
          input = input.substring(0, input.length - 1);
        }
      } else if (value == '=') {
        try {
          result = calculateResult(input);
          saveHistory('$input = $result');
          input = result;
        } catch (e) {
          result = 'Error';
        }
      } else {
        input += value;
      }
    });
  }

  String calculateResult(String input) {
    input = input
        .replaceAll('×', '*')
        .replaceAll('÷', '/')
        .replaceAll('%', '/100')
        .replaceAll(',', '.');

    try {
      Parser p = Parser();
      Expression exp = p.parse(input);
      ContextModel cm = ContextModel();
      double eval = exp.evaluate(EvaluationType.REAL, cm);

      if (eval == eval.toInt()) {
        return eval.toInt().toString();
      } else {
        return eval.toString();
      }
    } catch (e) {
      return 'Error';
    }
  }

  Widget buildButton(String label, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.all(6.0),
      child: ElevatedButton(
        onPressed: label.isEmpty ? null : () => buttonPressed(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: color ?? Theme.of(context).colorScheme.primary,
          minimumSize: const Size(70, 70),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 24,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Kalkulator')),
      body: Column(
        children: [
          Expanded(
            child: Container(
              alignment: Alignment.bottomRight,
              padding: const EdgeInsets.all(24),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerRight,
                child: Text(
                  input.isEmpty ? result : input,
                  style: TextStyle(
                    fontSize: 32,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
              ),
            ),
          ),
          Table(
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            children: [
              TableRow(children: [
                buildButton('7'), buildButton('8'), buildButton('9'), buildButton('÷', color: Colors.orange),
              ]),
              TableRow(children: [
                buildButton('4'), buildButton('5'), buildButton('6'), buildButton('×', color: Colors.orange),
              ]),
              TableRow(children: [
                buildButton('1'), buildButton('2'), buildButton('3'), buildButton('-', color: Colors.orange),
              ]),
              TableRow(children: [
                buildButton('0'), buildButton(','), buildButton('%'), buildButton('+', color: Colors.orange),
              ]),
              TableRow(children: [
                buildButton('C', color: Colors.red),
                buildButton('⌫', color: Colors.redAccent),
                buildButton('=', color: Colors.green),
                const SizedBox(), // Kosong satu cell
              ]),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(),
          ListTile(
            title: const Text('Riwayat'),
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: clearHistory,
            ),
          ),
          Expanded(
            child: ListView(
              children: history.map((item) => ListTile(title: Text(item))).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
