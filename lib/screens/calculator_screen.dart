import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CalculatorScreen extends StatefulWidget {
  @override
  _CalculatorScreenState createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  TextEditingController _controller = TextEditingController();
  String _input = '';
  String _result = '';
  bool _isScientificMode = false;
  List<String> _history = [];
  bool _showHistory = false;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _saveHistory(String entry) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _history.add(entry);
    await prefs.setStringList('history', _history);
  }

  Future<void> _loadHistory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _history = prefs.getStringList('history') ?? [];
    });
  }

  Future<void> _clearHistory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('history');
    setState(() {
      _history.clear();
    });
  }

  void addInput(String value) {
    setState(() {
      _input += value;
      _controller.text = _input;
      _controller.selection = TextSelection.fromPosition(
        TextPosition(offset: _controller.text.length),
      );
    });
  }

  void calculate() {
    try {
      String parsedInput = _input
          .replaceAll('×', '*')
          .replaceAll('÷', '/')
          .replaceAll('√(', 'sqrt(')
          .replaceAll(',', '.')
          .replaceAll('π', '3.1416')
          .replaceAll('e', '2.718')
          .replaceAll('^', '**')
          .replaceAll('sin(', 'sin(')
          .replaceAll('cos(', 'cos(')
          .replaceAll('tan(', 'tan(')
          .replaceAll('log(', 'log10(')
          .replaceAll('ln(', 'ln(');

      // ✅ Konversi persen (misalnya 20% -> (20/100))
      parsedInput = parsedInput.replaceAllMapped(
        RegExp(r'(\d+(\.\d+)?)%'),
            (match) => '(${match.group(1)}/100)',
      );

      Parser p = Parser();
      ContextModel cm = ContextModel();
      Expression exp = p.parse(parsedInput);
      double eval = exp.evaluate(EvaluationType.REAL, cm);

      if (eval.isNaN || eval.isInfinite) {
        setState(() {
          _result = 'Tidak Valid';
        });
        return;
      }

      setState(() {
        if (eval == eval.toInt()) {
          _result = eval.toInt().toString();
        } else {
          _result = eval.toStringAsFixed(8).replaceAll(RegExp(r'\.?0+$'), '');
        }
        _saveHistory('$_input = $_result');
      });
    } catch (e) {
      setState(() {
        _result = 'Error';
      });
    }
  }

  void clear() {
    setState(() {
      _input = '';
      _result = '';
      _controller.clear();
    });
  }

  void delete() {
    setState(() {
      if (_input.isNotEmpty) {
        _input = _input.substring(0, _input.length - 1);
        _controller.text = _input;
        _controller.selection = TextSelection.fromPosition(
          TextPosition(offset: _controller.text.length),
        );
      }
    });
  }

  Widget buildButton(String text, {VoidCallback? onPressed}) {
    Color buttonColor;
    if (text == 'C' || text == '⌫') {
      buttonColor = Colors.red;
    } else if (text == '=' || text == '+' || text == '-' || text == '×' || text == '÷') {
      buttonColor = Colors.orange;
    } else {
      buttonColor = Colors.blue;
    }

    return ElevatedButton(
      onPressed: onPressed ?? () => addInput(text),
      style: ElevatedButton.styleFrom(
        backgroundColor: buttonColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        padding: EdgeInsets.all(20),
      ),
      child: Text(text, style: TextStyle(fontSize: 20)),
    );
  }

  void addFunctionWithParentheses(String function) {
    if (_input.isEmpty || _input.endsWith('(')) {
      addInput(function + '()');
      _controller.text = _input.substring(0, _input.length - 1) + ')';
      _controller.selection = TextSelection.fromPosition(TextPosition(offset: _controller.text.length));
    } else {
      addInput(function + '(');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('Kalkulator'),
        actions: [
          Switch(
            value: _isScientificMode,
            onChanged: (value) {
              setState(() {
                _isScientificMode = value;
              });
            },
          ),
          IconButton(
            icon: Icon(Icons.history),
            onPressed: () {
              setState(() {
                _showHistory = !_showHistory;
              });
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (!_showHistory) ...[
              TextField(
                controller: _controller,
                readOnly: true,
                style: TextStyle(fontSize: 24, color: isDarkMode ? Colors.white : Colors.black),
                textAlign: TextAlign.right,
                decoration: InputDecoration(border: InputBorder.none),
              ),
              SizedBox(height: 10),
              Text(
                _result,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white : Colors.black),
                textAlign: TextAlign.right,
              ),
              SizedBox(height: 20),
              Expanded(
                child: _isScientificMode ? scientificButtons() : standardButtons(),
              ),
            ] else ...[
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: _history.map((item) => ListTile(title: Text(item))).toList(),
                  ),
                ),
              ),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _showHistory = false;
                      });
                    },
                    child: Text('Kembali ke Kalkulator'),
                  ),
                  IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: _clearHistory,
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget standardButtons() {
    return GridView.count(
      crossAxisCount: 4,
      children: [
        for (var text in ['7', '8', '9', '÷',
          '4', '5', '6', '×',
          '1', '2', '3', '-',
          '0', ',', '%', '+'])
          buildButton(text),
        buildButton('C', onPressed: clear),
        buildButton('⌫', onPressed: delete),
        buildButton('=', onPressed: calculate),
      ],
    );
  }

  Widget scientificButtons() {
    return GridView.count(
      crossAxisCount: 4,
      children: [
        buildButton('sin', onPressed: () { addFunctionWithParentheses('sin'); }),
        buildButton('cos', onPressed: () { addFunctionWithParentheses('cos'); }),
        buildButton('tan', onPressed: () { addFunctionWithParentheses('tan'); }),
        buildButton('log', onPressed: () { addFunctionWithParentheses('log'); }),
        buildButton('ln', onPressed: () { addFunctionWithParentheses('ln'); }),
        buildButton('√', onPressed: () { addFunctionWithParentheses('√'); }),
        buildButton('^', onPressed: () { addInput('^'); }),
        buildButton('(', onPressed: () { addInput('('); }),
        buildButton(')', onPressed: () { addInput(')'); }),
        buildButton('π', onPressed: () { addInput('π'); }),
        buildButton('e', onPressed: () { addInput('e'); }),
      ],
    );
  }
}
