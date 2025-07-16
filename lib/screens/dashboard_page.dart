import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class DashboardPage extends StatefulWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  Map<String, dynamic>? dashboardData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchDashboardData();
  }

  Future<void> fetchDashboardData() async {
    try {
      final response = await http.get(Uri.parse('http://your-backend-url/api/dashboard/summary'));
      if (response.statusCode == 200) {
        setState(() {
          dashboardData = json.decode(response.body);
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load dashboard data');
      }
    } catch (e) {
      print('Error: $e');
      // You can handle errors or show an error UI here
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard"),
        backgroundColor: Colors.deepPurple,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Welcome, ${dashboardData!['username']} 👋", style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            _buildNetWorthCard(dashboardData!['net_worth']),
            const SizedBox(height: 20),
            Text("Portfolio Overview", style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildOverviewCard("Equity", dashboardData!['equity'], Colors.blue),
                _buildOverviewCard("SIP", dashboardData!['sip'], Colors.green),
                _buildOverviewCard("MTF", dashboardData!['mtf'], Colors.orange),
              ],
            ),
            const SizedBox(height: 20),
            _buildTodayPerformance(dashboardData!['todays_pnl']),
            const SizedBox(height: 20),
            Text("Market Alerts 🔔", style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            ...List.generate(
              dashboardData!['alerts'].length,
                  (index) => _buildAlertCard(dashboardData!['alerts'][index]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNetWorthCard(int netWorth) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text("Total Net Worth", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            const SizedBox(height: 10),
            Text("₹${netWorth.toString()}", style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewCard(String title, int amount, Color color) {
    return Expanded(
      child: Card(
        color: color.withOpacity(0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            children: [
              Text(title, style: TextStyle(color: color, fontWeight: FontWeight.w600)),
              const SizedBox(height: 5),
              Text("₹$amount", style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTodayPerformance(int pnl) {
    final isProfit = pnl >= 0;
    final color = isProfit ? Colors.green : Colors.red;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: ListTile(
        leading: Icon(isProfit ? Icons.trending_up : Icons.trending_down, color: color),
        title: const Text("Today's Profit/Loss"),
        subtitle: Text(
          "₹$pnl",
          style: TextStyle(color: color, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildAlertCard(String message) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.yellow.shade100,
      child: ListTile(
        leading: const Icon(Icons.notifications, color: Colors.amber),
        title: Text(message),
      ),
    );
  }
}
