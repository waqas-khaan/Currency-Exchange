import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() => runApp(CurrencyConverterApp());

class CurrencyConverterApp extends StatefulWidget {
  @override
  _CurrencyConverterAppState createState() => _CurrencyConverterAppState();
}

class _CurrencyConverterAppState extends State<CurrencyConverterApp> {
  bool _isDarkTheme = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: _isDarkTheme ? ThemeData.dark() : ThemeData.light(),
      home: CurrencyConverterScreen(
        onThemeToggle: () {
          setState(() {
            _isDarkTheme = !_isDarkTheme;
          });
        },
        isDarkTheme: _isDarkTheme,
      ),
    );
  }
}

class CurrencyConverterScreen extends StatefulWidget {
  final VoidCallback onThemeToggle;
  final bool isDarkTheme;

  CurrencyConverterScreen(
      {required this.onThemeToggle, required this.isDarkTheme});

  @override
  _CurrencyConverterScreenState createState() =>
      _CurrencyConverterScreenState();
}

class _CurrencyConverterScreenState extends State<CurrencyConverterScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _fromCountryController = TextEditingController();
  final TextEditingController _toCountryController = TextEditingController();

  final Map<String, String> _countryToCurrency = {
    'United States': 'USD',
    'Pakistan': 'PKR',
    'United Kingdom': 'GBP',
    'India': 'INR',
    'Australia': 'AUD',
    'Canada': 'CAD',
    'Japan': 'JPY',
    'China': 'CNY',
    'Germany': 'EUR',
    'France': 'EUR',
    'Italy': 'EUR',
  };

  String? _sourceCurrency;
  String? _targetCurrency;
  String _result = '';
  bool _isLoading = false;
  String? _errorMessage;
  List<String> _conversionHistory = [];
  String? _userName;

  void _detectCurrencyFromCountry(String country, bool isSource) {
    if (_countryToCurrency.containsKey(country)) {
      setState(() {
        if (isSource) {
          _sourceCurrency = _countryToCurrency[country];
        } else {
          _targetCurrency = _countryToCurrency[country];
        }
      });
    } else {
      setState(() {
        if (isSource) {
          _sourceCurrency = null;
        } else {
          _targetCurrency = null;
        }
      });
    }
  }

  Future<void> _convertCurrency() async {
    if (_sourceCurrency == null || _targetCurrency == null) {
      setState(() {
        _errorMessage = 'Please select valid currencies for conversion.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final double amount = double.parse(_amountController.text);

      final response = await http.get(
        Uri.parse(
            'https://api.exchangerate-api.com/v4/latest/$_sourceCurrency'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final rate = data['rates'][_targetCurrency];
        final convertedAmount = amount * rate;

        setState(() {
          _result =
              '$amount $_sourceCurrency = ${convertedAmount.toStringAsFixed(2)} $_targetCurrency';
          _conversionHistory.add('$_userName: $_result');
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to fetch exchange rate.';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Invalid input or network error.';
        _isLoading = false;
      });
    }
  }

  void _submitName() {
    if (_nameController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Name is required.';
      });
      return;
    }
    setState(() {
      _userName = _nameController.text;
      _errorMessage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(
            Icons.replay_circle_filled_rounded,
            color: Colors.white,
          ),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: widget.isDarkTheme
                  ? [Colors.grey.shade800, Colors.black]
                  : [Colors.blue, Colors.purple],
            ),
          ),
        ),
        title: Text(
          'Currency Converter',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(widget.isDarkTheme ? Icons.light_mode : Icons.dark_mode),
            color: Colors.white,
            onPressed: widget.onThemeToggle,
          ),
        ],
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _userName == null
            ? Column(
                children: [
                  Text(
                    'Welcome!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 20),
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Enter Your Name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _submitName,
                    child: Text(
                      'Submit',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      padding: EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  if (_errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Hello, $_userName!',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent,
                    ),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: _amountController,
                    decoration: InputDecoration(
                      labelText: 'Enter Amount',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: _fromCountryController,
                    decoration: InputDecoration(
                      labelText: 'Enter From Country',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onChanged: (value) =>
                        _detectCurrencyFromCountry(value, true),
                  ),
                  SizedBox(height: 16),
                  DropdownButton<String>(
                    value: _sourceCurrency,
                    isExpanded: true,
                    items: _countryToCurrency.values.map((currency) {
                      return DropdownMenuItem<String>(
                        value: currency,
                        child: Text(currency),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _sourceCurrency = value;
                      });
                    },
                    hint: Text('Source Currency'),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: _toCountryController,
                    decoration: InputDecoration(
                      labelText: 'Enter To Country',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onChanged: (value) =>
                        _detectCurrencyFromCountry(value, false),
                  ),
                  SizedBox(height: 16),
                  DropdownButton<String>(
                    value: _targetCurrency,
                    isExpanded: true,
                    items: _countryToCurrency.values.map((currency) {
                      return DropdownMenuItem<String>(
                        value: currency,
                        child: Text(currency),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _targetCurrency = value;
                      });
                    },
                    hint: Text('Target Currency'),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _convertCurrency,
                    child: Text(
                      'Convert',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      padding: EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  if (_result.isNotEmpty)
                    Text(
                      _result,
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  Divider(),
                  Text(
                    'Conversion History:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _conversionHistory.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(_conversionHistory[index]),
                        );
                      },
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _gradientButton(String label, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        backgroundColor: null,
        padding: EdgeInsets.symmetric(vertical: 14),
        // backgroundColor: Colors.transparent,
      ),
      child: Ink(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue, Colors.purple],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Container(
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
