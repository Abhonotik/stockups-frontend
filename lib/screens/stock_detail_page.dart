import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class StockDetailPage extends StatefulWidget {
  final String symbol;

  const StockDetailPage({Key? key, required this.symbol}) : super(key: key);

  @override
  State<StockDetailPage> createState() => _StockDetailPageState();
}

class _StockDetailPageState extends State<StockDetailPage> {
  Map<String, dynamic>? stockDetail;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchStockDetail();
  }

  Future<void> fetchStockDetail() async {
    try {
      final response = await http.get(Uri.parse(
          'http://your-backend-url/api/stocks/${widget.symbol}'));
      if (response.statusCode == 200) {
        setState(() {
          stockDetail = json.decode(response.body);
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load stock detail');
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.symbol} Details"),
        backgroundColor: Colors.deepPurple,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                Text(widget.symbol, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                _buildRow("Quantity", stockDetail!['quantity'].toString()),
                _buildRow("Avg Buy Price", "₹${stockDetail!['average_price']}"),
                _buildRow("Current Price", "₹${stockDetail!['current_price']}"),
                _buildRow("Invested", "₹${stockDetail!['total_invested']}"),
                _buildRow("Current Value", "₹${stockDetail!['current_value']}"),
                _buildRow("P&L", "₹${stockDetail!['pnl']}", color: stockDetail!['pnl'] >= 0 ? Colors.green : Colors.red),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(value, style: TextStyle(color: color ?? Colors.black)),
        ],
      ),
    );
  }
}
