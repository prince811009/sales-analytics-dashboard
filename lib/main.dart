import 'package:csv/csv.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class SalesRecord {
  final String month;
  final double sales;

  SalesRecord({required this.month, required this.sales});
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sales Analytics Dashboard',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedIndex = 0;
  List<SalesRecord> salesData = [];

  final String sampleCsv = '''
month,sales
2025-01,120000
2025-02,135000
2025-03,128000
2025-04,150000
2025-05,160000
2025-06,172000
2025-07,168000
2025-08,181000
''';

void importSampleCsv() {
  print('Import button clicked');

  setState(() {
    salesData = [
      SalesRecord(month: '2025-01', sales: 120000),
      SalesRecord(month: '2025-02', sales: 135000),
      SalesRecord(month: '2025-03', sales: 128000),
      SalesRecord(month: '2025-04', sales: 150000),
      SalesRecord(month: '2025-05', sales: 160000),
      SalesRecord(month: '2025-06', sales: 172000),
      SalesRecord(month: '2025-07', sales: 168000),
      SalesRecord(month: '2025-08', sales: 181000),
    ];
  });
}

  double get totalSales =>
      salesData.fold(0, (sum, item) => sum + item.sales);

  double get averageSales =>
      salesData.isEmpty ? 0 : totalSales / salesData.length;

  double get forecastSales =>
      salesData.isEmpty ? 0 : salesData.last.sales * 1.08;

  String formatMoney(double value) {
    return '\$${value.toStringAsFixed(0)}';
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      DashboardPage(
        salesData: salesData,
        totalSales: totalSales,
        averageSales: averageSales,
        forecastSales: forecastSales,
        formatMoney: formatMoney,
        onImport: importSampleCsv,
      ),
      DataExplorerPage(
        salesData: salesData,
        formatMoney: formatMoney,
      ),
      ManagementReportPage(
        salesData: salesData,
        formatMoney: formatMoney,
        averageSales: averageSales,
        forecastSales: forecastSales,
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xfffbf7ff),
      appBar: AppBar(
        title: const Text('Sales Analytics Dashboard'),
        centerTitle: true,
        backgroundColor: const Color(0xfffbf7ff),
      ),
      body: pages[selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.table_chart),
            label: 'Data Explorer',
          ),
          NavigationDestination(
            icon: Icon(Icons.analytics),
            label: 'Report',
          ),
        ],
      ),
    );
  }
}

class DashboardPage extends StatelessWidget {
  final List<SalesRecord> salesData;
  final double totalSales;
  final double averageSales;
  final double forecastSales;
  final String Function(double) formatMoney;
  final VoidCallback onImport;

  const DashboardPage({
    super.key,
    required this.salesData,
    required this.totalSales,
    required this.averageSales,
    required this.forecastSales,
    required this.formatMoney,
    required this.onImport,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _buildCard('Total Sales', formatMoney(totalSales))),
              const SizedBox(width: 16),
              Expanded(child: _buildCard('Average Sales', formatMoney(averageSales))),
              const SizedBox(width: 16),
              Expanded(child: _buildCard('Forecast', formatMoney(forecastSales))),
            ],
          ),
          const SizedBox(height: 20),
          Align(
            alignment: Alignment.centerLeft,
            child: ElevatedButton.icon(
              onPressed: onImport,
              icon: const Icon(Icons.upload_file),
              label: const Text('Import Sample CSV'),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
              ),
              child: salesData.isEmpty
                  ? const Center(
                      child: Text(
                        'No data imported yet.\nClick "Import Sample CSV" to load sales data.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 18),
                      ),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Sales Trend Chart',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Expanded(child: SalesLineChart(salesData: salesData)),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(String title, String value) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(title),
            const SizedBox(height: 10),
            Text(
              value,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

class SalesLineChart extends StatelessWidget {
  final List<SalesRecord> salesData;

  const SalesLineChart({super.key, required this.salesData});

  @override
  Widget build(BuildContext context) {
    if (salesData.isEmpty) {
      return const Center(child: Text('No chart data'));
    }

    final spots = salesData.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.sales / 1000);
    }).toList();

    return LineChart(
      LineChartData(
        minY: 0,
        maxY: 220,
        gridData: const FlGridData(show: true),
        borderData: FlBorderData(show: true),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            barWidth: 3,
            dotData: const FlDotData(show: true),
          ),
        ],
        titlesData: const FlTitlesData(
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
      ),
    );
  }
}

class DataExplorerPage extends StatefulWidget {
  final List<SalesRecord> salesData;
  final String Function(double) formatMoney;

  const DataExplorerPage({
    super.key,
    required this.salesData,
    required this.formatMoney,
  });

  @override
  State<DataExplorerPage> createState() => _DataExplorerPageState();
}

class _DataExplorerPageState extends State<DataExplorerPage> {
  String keyword = '';

  @override
  Widget build(BuildContext context) {
    final filteredData = widget.salesData.where((item) {
      return item.month.contains(keyword);
    }).toList();

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          TextField(
            decoration: const InputDecoration(
              labelText: 'Search by month, e.g. 2025-03',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              setState(() {
                keyword = value;
              });
            },
          ),
          const SizedBox(height: 20),
          Expanded(
            child: widget.salesData.isEmpty
                ? const Center(
                    child: Text('Please import sample CSV data first.'),
                  )
                : SingleChildScrollView(
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('Month')),
                        DataColumn(label: Text('Sales')),
                      ],
                      rows: filteredData.map((item) {
                        return DataRow(
                          cells: [
                            DataCell(Text(item.month)),
                            DataCell(Text(widget.formatMoney(item.sales))),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class ManagementReportPage extends StatelessWidget {
  final List<SalesRecord> salesData;
  final String Function(double) formatMoney;
  final double averageSales;
  final double forecastSales;

  const ManagementReportPage({
    super.key,
    required this.salesData,
    required this.formatMoney,
    required this.averageSales,
    required this.forecastSales,
  });

  @override
  Widget build(BuildContext context) {
    if (salesData.isEmpty) {
      return const Center(
        child: Text('Please import sample CSV first.'),
      );
    }

    final bestMonth =
        salesData.reduce((a, b) => a.sales > b.sales ? a : b);

    final worstMonth =
        salesData.reduce((a, b) => a.sales < b.sales ? a : b);

    return Padding(
      padding: const EdgeInsets.all(20),
      child: ListView(
        children: [
          const Text(
            'Management Report',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 30),

          _buildItem(
            'Best Month',
            '${bestMonth.month} (${formatMoney(bestMonth.sales)})',
          ),

          _buildItem(
            'Worst Month',
            '${worstMonth.month} (${formatMoney(worstMonth.sales)})',
          ),

          _buildItem(
            'Average Sales',
            formatMoney(averageSales),
          ),

          _buildItem(
            'Forecast Next Month',
            formatMoney(forecastSales),
          ),

          const SizedBox(height: 30),

          const Text(
            'Recommendation',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 12),

          Text(
            forecastSales > averageSales
                ? 'Sales have shown a positive trend. Consider preparing inventory and operational resources to support continued growth.'
                : 'Sales performance appears stable. Continue monitoring trends and operational efficiency.',
            style: const TextStyle(fontSize: 18),
          ),
        ],
      ),
    );
  }

  Widget _buildItem(String title, String value) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        title: Text(title),
        subtitle: Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}