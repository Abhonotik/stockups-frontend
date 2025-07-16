import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AddTransactionPage extends StatefulWidget {
  const AddTransactionPage({Key? key}) : super(key: key);

  @override
  State<AddTransactionPage> createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends State<AddTransactionPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _symbolController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  String _transactionType = 'buy';
  DateTime _selectedDate = DateTime.now();

  bool _isSubmitting = false;

  Future<void> submitTransaction() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final url = Uri.parse('http://your-backend-url/api/transactions/add');

    final body = json.encode({
      "symbol": _symbolController.text.trim().toUpperCase(),
      "type": _transactionType,
      "quantity": int.parse(_quantityController.text),
      "price": double.parse(_priceController.text),
      "date": _selectedDate.toIso8601String().substring(0, 10),
    });

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: body,
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Transaction added successfully")),
        );
        Navigator.pop(context); // Go back
      } else {
        throw Exception("Failed to add transaction");
      }
    } catch (e) {
      print("Submit error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Something went wrong")),
      );
    }

    setState(() => _isSubmitting = false);
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Transaction"),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _symbolController,
                decoration: const InputDecoration(labelText: "Stock Symbol (e.g., TCS)"),
                validator: (value) => value!.isEmpty ? "Enter stock symbol" : null,
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _transactionType,
                items: const [
                  DropdownMenuItem(value: 'buy', child: Text("Buy")),
                  DropdownMenuItem(value: 'sell', child: Text("Sell")),
                  DropdownMenuItem(value: 'sip', child: Text("SIP")),
                ],
                onChanged: (value) {
                  setState(() => _transactionType = value!);
                },
                decoration: const InputDecoration(labelText: "Transaction Type"),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _quantityController,
                decoration: const InputDecoration(labelText: "Quantity"),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? "Enter quantity" : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: "Price per Unit"),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? "Enter price" : null,
              ),
              const SizedBox(height: 10),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text("Date: ${_selectedDate.toLocal().toString().split(' ')[0]}"),
                trailing: IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: _pickDate,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isSubmitting ? null : submitTransaction,
                child: _isSubmitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Submit Transaction"),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
              )
            ],
          ),
        ),
      ),
    );
  }
}
