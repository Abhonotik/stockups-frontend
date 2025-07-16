import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class PortfolioPage extends StatefulWidget {
  const PortfolioPage({Key? key}) : super(key: key);

  @override
  State<PortfolioPage> createState() => _PortfolioPageState();
}

class _PortfolioPageState extends State<PortfolioPage> {
  List<dynamic> holdings = [];
  bool isLoading = true;
  double totalValue = 0;

  @override
  void initState() {
    super.initState();
    fetchPortfolio();
  }




  Future<void> fetchPortfolio() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('authToken');

      final response = await http.get(
        Uri.parse('http://10.0.2.2:8000/api/portfolio/'),
        headers: {
          'Authorization': 'Token $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        setState(() {
          holdings = data; // or data['holdings'] if response is wrapped
          totalValue = holdings.fold(0, (sum, stock) {
            return sum + (stock['current_price'] * stock['quantity']);
          });
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load portfolio: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching portfolio: $e');
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Could not load portfolio")),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Portfolio"),
        backgroundColor: Colors.deepPurple,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    const Text("Total Portfolio Value", style: TextStyle(fontSize: 16)),
                    const SizedBox(height: 8),
                    Text("₹${totalValue.toStringAsFixed(2)}",
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: holdings.length,
                itemBuilder: (context, index) {
                  final stock = holdings[index];
                  final totalBuy = stock['quantity'] * stock['average_price'];
                  final totalCurrent = stock['quantity'] * stock['current_price'];
                  final pnl = totalCurrent - totalBuy;
                  final pnlColor = pnl >= 0 ? Colors.green : Colors.red;

                  return Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    child: ListTile(
                      title: Text(stock['symbol'], style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(
                          "Qty: ${stock['quantity']} | Buy @ ₹${stock['average_price']}"),
                      trailing: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text("Now: ₹${stock['current_price']}",
                              style: const TextStyle(fontSize: 14)),
                          Text(
                            "P&L: ₹${pnl.toStringAsFixed(2)}",
                            style: TextStyle(color: pnlColor, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
