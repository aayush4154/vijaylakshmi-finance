import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() {
  runApp(const VijaylakshmiFinanceApp());
}

// ============================================================
// APP
// ============================================================

class VijaylakshmiFinanceApp extends StatelessWidget {
  const VijaylakshmiFinanceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vijaylakshmi Finance',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Arial',
        scaffoldBackgroundColor: const Color(0xFFF4F7FB),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0D2747),
        ),
      ),
      home: const MainScreen(),
    );
  }
}
Future<Map<String, dynamic>> predictLoanRisk({
  required double income,
  required double loanAmount,
  required int tenureMonths,
  required int previousLoans,
  required int latePayments,
  required int overdueInstallments,
  required double paymentCompletion,
}) async {
  final response = await http.post(
    Uri.parse('http://127.0.0.1:8000/predict'),
    headers: {
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      'income': income,
      'loan_amount': loanAmount,
      'tenure_months': tenureMonths,
      'previous_loans': previousLoans,
      'late_payments': latePayments,
      'overdue_installments': overdueInstallments,
      'payment_completion': paymentCompletion,
    }),
  );

  if (response.statusCode == 200) {
    return jsonDecode(response.body) as Map<String, dynamic>;
  } else {
    throw Exception('AI prediction failed');
  }
}

// ============================================================
// MODELS
// ============================================================

class Customer {
  final int id;
  String name;
  String phone;
  String address;
  Uint8List? photoBytes;

  Customer({
    required this.id,
    required this.name,
    required this.phone,
    required this.address,
    this.photoBytes,
  });
}

class Loan {
  final int id;
  final int customerId;
  final double principal;
  final double monthlyRate;
  final int tenureMonths;
  final String frequency;
  final DateTime startDate;
  final List<String> collectionDays;
final List<int> collectionDates;

  Loan({
    required this.id,
    required this.customerId,
    required this.principal,
    required this.monthlyRate,
    required this.tenureMonths,
    required this.frequency,
    required this.startDate,
    this.collectionDays = const [],
this.collectionDates = const [],
  });

  double get totalInterest =>
      principal * (monthlyRate / 100) * tenureMonths;

  double get totalPayable => principal + totalInterest;

  int get installmentCount {
    switch (frequency) {
      case 'Daily':
        return tenureMonths * 30;
      case 'Weekly':
        return (tenureMonths * 30 / 7).ceil();
      case '15 Days':
        return (tenureMonths * 30 / 15).ceil();
      case 'Monthly':
        return tenureMonths;
      default:
        return tenureMonths;
    }
  }

  double get installmentAmount =>
      totalPayable / installmentCount;
    double get remainingAmount => totalPayable;    
}

class Payment {
  final int id;
  final int loanId;
  final double amount;
  final DateTime date;
  final String mode;
  final int installmentNumber;
final DateTime dueDate;

  Payment({
    required this.id,
    required this.loanId,
    required this.amount,
    required this.date,
    required this.mode,
    required this.installmentNumber,
required this.dueDate,
  });
}

// ============================================================
// MAIN SCREEN
// ============================================================

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int selectedIndex = 0;
  String collectionType = 'Daily';
  String? selectedCollectionDay;
  int? collectionDate;

  final List<Customer> customers = [
    Customer(
      id: 1,
      name: 'Rahul Sharma',
      phone: '9876543210',
      address: 'Roorkee, Uttarakhand',
    ),
    Customer(
      id: 2,
      name: 'Amit Kumar',
      phone: '9812345678',
      address: 'Haridwar, Uttarakhand',
    ),
    Customer(
      id: 3,
      name: 'Neha Singh',
      phone: '9898989898',
      address: 'Dehradun, Uttarakhand',
    ),
  ];

  final List<Loan> loans = [];

  final List<Payment> payments = [];

  int nextCustomerId = 4;
  int nextLoanId = 1;
  int nextPaymentId = 1;

  @override
  Widget build(BuildContext context) {
    final screens = [
  buildDashboard(),
  buildCustomers(),
  buildLoans(),
  buildPayments(),
  buildCollection(),
  buildReports(),
];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D2747),
        foregroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 8,
        title: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Image.asset(
                'assets/logo.png',
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Vijaylakshmi Finance',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Finance Management',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_none),
          ),
          const SizedBox(width: 8),
        ],
      ),

      drawer: buildDrawer(),

      body: screens[selectedIndex],
    );
  }

  // ==========================================================
  // DRAWER
  // ==========================================================

  Drawer buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(
            height: 190,
            color: const Color(0xFF0D2747),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 82,
                  height: 82,
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Image.asset(
                    'assets/logo.png',
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Vijaylakshmi Finance',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          drawerItem(Icons.dashboard_outlined, 'Dashboard', 0),
          drawerItem(Icons.people_outline, 'Customers', 1),
          drawerItem(Icons.account_balance_wallet_outlined, 'Loans', 2),
          drawerItem(Icons.payments_outlined, 'Payments', 3),
          drawerItem(Icons.bar_chart_outlined, 'Reports', 4),
          drawerItem(
  Icons.calendar_month_outlined,
  'Collection',
  4,
),
drawerItem(Icons.bar_chart_outlined, 'Reports', 5),

          const Divider(),

          ListTile(
            leading: const Icon(Icons.settings_outlined),
            title: const Text('Settings'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  Widget drawerItem(IconData icon, String title, int index) {
    return ListTile(
      leading: Icon(
        icon,
        color: selectedIndex == index
            ? const Color(0xFF0D2747)
            : Colors.grey[700],
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight:
              selectedIndex == index ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: selectedIndex == index,
      onTap: () {
        setState(() {
          selectedIndex = index;
        });
        Navigator.pop(context);
      },
    );
  }

  // ==========================================================
  // DASHBOARD
  // ==========================================================
Widget buildCollection() {
  return SingleChildScrollView(
    padding: const EdgeInsets.all(20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Collection',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 20),

        Row(
          children: [
            Expanded(
              child: collectionTypeCard(
                'Daily',
                Icons.today,
                () {
                  setState(() {
                    collectionType = 'Daily';
                  });
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: collectionTypeCard(
                'Weekly',
                Icons.view_week,
                () {
                  setState(() {
                    collectionType = 'Weekly';
                  });
                },
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        Row(
          children: [
            Expanded(
              child: collectionTypeCard(
                'Monthly',
                Icons.calendar_month,
                () {
                  setState(() {
                    collectionType = 'Monthly';
                  });
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: collectionTypeCard(
                '15 Days',
                Icons.date_range,
                () {
                  setState(() {
                    collectionType = '15 Days';
                  });
                },
              ),
            ),
          ],
        ),

        const SizedBox(height: 25),
if (collectionType == 'Monthly') ...[
  const SizedBox(height: 20),

  Wrap(
    spacing: 10,
    runSpacing: 10,
    children: [5, 10, 15, 20, 25, 30].map((day) {
      return ChoiceChip(
        label: Text('$day'),
        selected: collectionDate == day,
        onSelected: (selected) {
          setState(() {
            collectionDate = selected ? day : null;
          });
        },
      );
    }).toList(),
  ),

  const SizedBox(height: 20),
],
if (collectionType == 'Daily') ...[
  ...loans
      .where((loan) => loan.frequency == 'Daily')
      .map((loan) {
    final customer = customers.firstWhere(
      (c) => c.id == loan.customerId,
    );

    final paid = loanPaid(loan);
    final isPaid = paid >= loan.installmentAmount;

    return Card(
      child: ListTile(
        leading: const CircleAvatar(
          child: Icon(Icons.person),
        ),
        title: Text(customer.name),
        subtitle: Text(customer.phone),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 7,
              ),
              decoration: BoxDecoration(
                color: isPaid
                    ? Colors.green.shade100
                    : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                isPaid ? 'Paid' : 'Pending',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isPaid
                      ? Colors.green.shade700
                      : Colors.grey.shade700,
                ),
              ),
            ),
            const SizedBox(width: 10),
            ElevatedButton(
              onPressed: () {
                showPaymentDialog(loan);
              },
              child: const Text('Collect'),
            ),
          ],
        ),
      ),
    );
  }),
],
if (collectionType == 'Weekly') ...[
  const SizedBox(height: 15),

  Wrap(
    spacing: 10,
    children: ['Tuesday', 'Saturday'].map((day) {
      return ChoiceChip(
        label: Text(day),
        selected: selectedCollectionDay == day,
        onSelected: (selected) {
          setState(() {
            selectedCollectionDay = selected ? day : null;
          });
        },
      );
    }).toList(),
  ),

  
  
  


  if (selectedCollectionDay != null) ...[
    ...loans
        .where(
          (loan) =>
              loan.frequency == 'Weekly' &&
              loan.collectionDays.contains(selectedCollectionDay),
        )
        .map((loan) {
      final customer = customers.firstWhere(
        (c) => c.id == loan.customerId,
      );

      return Card(
        child: ListTile(
          leading: const CircleAvatar(
            child: Icon(Icons.person),
          ),
          title: Text(customer.name),
          subtitle: Text(customer.phone),
         trailing: Row(
  mainAxisSize: MainAxisSize.min,
  children: [
    Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: loanPaid(loan).round() >= loan.installmentAmount.round()
            ? Colors.green.shade100
            : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
       loanPaid(loan).round() >= loan.installmentAmount.round()
    ? 'Paid'
    : 'Pending',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: loanPaid(loan).round() >= loan.installmentAmount.round()
              ? Colors.green.shade700
              : Colors.grey.shade700,
        ),
      ),
    ),

    const SizedBox(width: 8),

    ElevatedButton(
      onPressed: () {
        showPaymentDialog(loan);
      },
      child: const Text('Collect'),
    ),
  ],
),
        ),
      );
    }),
  ],
],
if (collectionType == 'Monthly' && collectionDate != null) ...[
  const SizedBox(height: 15),

  ...loans
      .where(
        (loan) =>
            loan.frequency == 'Monthly' &&
            loan.collectionDates.contains(collectionDate),
      )
      .map((loan) {
        final customer = customers.firstWhere(
          (c) => c.id == loan.customerId,
        );

        return Card(
          child: ListTile(
            leading: const CircleAvatar(
              child: Icon(Icons.person),
            ),
            title: Text(customer.name),
            subtitle: Text(customer.phone),
            trailing: Row(
  mainAxisSize: MainAxisSize.min,
  children: [
    Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: loanPaid(loan) >= loan.installmentAmount
            ? Colors.green.shade100
            : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        loanPaid(loan) >= loan.installmentAmount
            ? 'Paid'
            : 'Pending',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: loanPaid(loan) >= loan.installmentAmount
              ? Colors.green.shade700
              : Colors.grey.shade700,
        ),
      ),
    ),

    const SizedBox(width: 8),

    ElevatedButton(
      onPressed: () {
        showPaymentDialog(loan);
      },
      child: const Text('Collect'),
    ),
  ],
),
          
 

          ),
        );
      }),
],
        Text(
          '$collectionType Collection',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    ),
  );
}
Widget collectionTypeCard(
  String title,
  IconData icon,
  VoidCallback onTap,
) {
  final selected = collectionType == title;

  return GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: selected
            ? const Color(0xFF0D2747)
            : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: selected
              ? const Color(0xFF0D2747)
              : Colors.grey.shade300,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 32,
            color: selected
                ? Colors.white
                : const Color(0xFF0D2747),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: selected
                  ? Colors.white
                  : const Color(0xFF102A43),
            ),
          ),
        ],
      ),
    ),
  );
}
void showAIRiskDialog() {
  final incomeController = TextEditingController();
  final loanAmountController = TextEditingController();
  final tenureController = TextEditingController();
  final previousLoansController = TextEditingController();
  final latePaymentsController = TextEditingController();
  final overdueController = TextEditingController();
  final completionController = TextEditingController();

  bool loading = false;

  showDialog(
    context: context,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.psychology, color: Colors.indigo),
                SizedBox(width: 10),
                Text('AI Loan Risk Analysis'),
              ],
            ),
            content: SizedBox(
              width: 500,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    TextField(
                      controller: incomeController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Monthly Income',
                        prefixText: '₹ ',
                      ),
                    ),
                    TextField(
                      controller: loanAmountController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Loan Amount',
                        prefixText: '₹ ',
                      ),
                    ),
                    TextField(
                      controller: tenureController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Tenure (Months)',
                      ),
                    ),
                    TextField(
                      controller: previousLoansController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Previous Loans',
                      ),
                    ),
                    TextField(
                      controller: latePaymentsController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Late Payments',
                      ),
                    ),
                    TextField(
                      controller: overdueController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Overdue Installments',
                      ),
                    ),
                    TextField(
                      controller: completionController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Payment Completion (%)',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                },
                child: const Text('Cancel'),
              ),
              FilledButton.icon(
                onPressed: loading
                    ? null
                    : () async {
                        setDialogState(() {
                          loading = true;
                        });

                        try {
                          final result = await predictLoanRisk(
                            income: double.parse(incomeController.text),
                            loanAmount:
                                double.parse(loanAmountController.text),
                            tenureMonths:
                                int.parse(tenureController.text),
                            previousLoans:
                                int.parse(previousLoansController.text),
                            latePayments:
                                int.parse(latePaymentsController.text),
                            overdueInstallments:
                                int.parse(overdueController.text),
                            paymentCompletion:
                                double.parse(completionController.text),
                          );

                          if (!context.mounted) return;

                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: const Text('AI Risk Result'),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      result['risk_level'],
                                      style: const TextStyle(
                                        fontSize: 30,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      'Risk Probability: '
                                      '${result['risk_probability']}%',
                                    ),
                                    const SizedBox(height: 8),
                                    Text(result['prediction']),
                                  ],
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context),
                                    child: const Text('Close'),
                                  ),
                                ],
                              );
                            },
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'AI prediction failed: $e',
                              ),
                            ),
                          );
                        } finally {
                          setDialogState(() {
                            loading = false;
                          });
                        }
                      },
                icon: const Icon(Icons.auto_awesome),
                label: Text(
                  loading ? 'Analyzing...' : 'Analyze Risk',
                ),
              ),
            ],
          );
        },
      );
    },
  );
}
  Widget buildDashboard() {
    double totalCollected = payments.fold(
      0,
      (sum, payment) => sum + payment.amount,
    );
    final now = DateTime.now();

double todayCollection = payments
    .where(
      (payment) =>
          payment.date.year == now.year &&
          payment.date.month == now.month &&
          payment.date.day == now.day,
    )
    .fold(
      0,
      (sum, payment) => sum + payment.amount,
    );

    double totalLoanAmount = loans.fold(
      0,
      (sum, loan) => sum + loan.principal,
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Dashboard',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF102A43),
            ),
          ),

          const SizedBox(height: 6),

          Text(
            'Welcome to Vijaylakshmi Finance',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),

          const SizedBox(height: 24),

          Container(
  width: double.infinity,
  padding: const EdgeInsets.all(18),
  decoration: BoxDecoration(
    gradient: const LinearGradient(
      colors: [
        Color(0xFF172554),
        Color(0xFF3730A3),
      ],
    ),
    borderRadius: BorderRadius.circular(18),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.08),
        blurRadius: 10,
        offset: const Offset(0, 4),
      ),
    ],
  ),
  child: Row(
    children: [
      Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.psychology,
          color: Colors.white,
          size: 30,
        ),
      ),
      const SizedBox(width: 14),
      const Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'AI Loan Risk Analysis',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Predict customer default risk using AI',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
      FilledButton(
        onPressed: showAIRiskDialog,
        style: FilledButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Color(0xFF3730A3),
        ),
        child: const Text('Analyze'),
      ),
    ],
  ),
),

const SizedBox(height: 18),

          GridView.count(
            crossAxisCount: MediaQuery.of(context).size.width > 900 ? 4 : 2,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.7,
            children: [
              statCard(
                'Customers',
                customers.length.toString(),
                Icons.people,
                Colors.blue,
              ),
              statCard(
                'Active Loans',
                loans.where((loan) => loanStatus(loan) == 'Active').length.toString(),
                Icons.account_balance_wallet,
                Colors.orange,
              ),
              statCard(
                'Loan Amount',
                money(loans.where((loan) => loanStatus(loan) == 'Active').fold(0.0, (sum, loan) => sum + loan.principal)),
                Icons.currency_rupee,
                Colors.purple,
              ),
              statCard(
                'Collected',
              money(
  payments.fold(
    0.0,
    (sum, payment) => sum + payment.amount,
  ),
),
                Icons.trending_up,
                Colors.green,
              ),
              statCard(
  'Outstanding',
  money(
    loans.fold(
      0.0,
      (sum, loan) => sum + loanOutstanding(loan),
    ),
  ),
  Icons.account_balance_wallet_outlined,
  Colors.orange,
),

  GestureDetector(
  onTap: showOverdueLoansDialog,
  child: statCard(
    'Overdue',
    loans.fold(
      0,
      (sum, loan) => sum + overdueInstallments(loan),
    ).toString(),
    Icons.warning_amber_rounded,
    Colors.red,
  ),
),

            ],
          ),

          const SizedBox(height: 30),

          const Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.bold,
              color: Color(0xFF102A43),
            ),
          ),

          const SizedBox(height: 14),

          GridView.count(
            crossAxisCount: MediaQuery.of(context).size.width > 900 ? 4 : 2,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 2.3,
            children: [
              actionCard(
                Icons.person_add_alt_1,
                'Add Customer',
                () => showAddCustomerDialog(),
              ),
              actionCard(
                Icons.account_balance_wallet,
                'New Loan',
                () => showNewLoanDialog(),
              ),
              actionCard(
                Icons.currency_rupee,
                'Collect Payment',
                () => showPaymentDialog(),
              ),
              actionCard(
                Icons.bar_chart,
                'Reports',
                () {
                  setState(() {
                    selectedIndex = 4;
                  });
                },
              ),
            ],
          ),

          const SizedBox(height: 30),

          const Text(
            "Today's Collection",
            style: TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.bold,
              color: Color(0xFF102A43),
            ),
          ),

          const SizedBox(height: 14),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: cardDecoration(),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.green.withOpacity(.1),
                  child: const Icon(
                    Icons.trending_up,
                    color: Colors.green,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 18),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Today's Total",
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      money(totalCollected),
                      style: const TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),

          const Text(
            'Recent Activity',
            style: TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.bold,
              color: Color(0xFF102A43),
            ),
          ),

          const SizedBox(height: 14),

          if (payments.isEmpty)
            emptyCard('No payments recorded yet')
          else
            ...payments.reversed.take(5).map(
              (payment) {
                final loan = loans.firstWhere(
                  (l) => l.id == payment.loanId,
                  orElse: () => Loan(
                    id: 0,
                    customerId: 0,
                    principal: 0,
                    monthlyRate: 5,
                    tenureMonths: 1,
                    frequency: 'Monthly',
                    startDate: DateTime.now(),
                  ),
                );

                final customer = customers.firstWhere(
                  (c) => c.id == loan.customerId,
                  orElse: () => Customer(
                    id: 0,
                    name: 'Unknown',
                    phone: '',
                    address: '',
                  ),
                );

                return activityCard(
                  customer.name,
                  payment.amount,
                );
              },
            ),
        ],
      ),
    );
  }

  Widget statCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: cardDecoration(),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color.withOpacity(.1),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget actionCard(
    IconData icon,
    String title,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF0D2747),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 30,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget activityCard(String name, double amount) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(18),
      decoration: cardDecoration(),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.green.withOpacity(.1),
            child: const Icon(
              Icons.arrow_downward,
              color: Colors.green,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Payment Received',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  name,
                  style: TextStyle(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Text(
            money(amount),
            style: const TextStyle(
              color: Colors.green,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // CUSTOMERS
  // ==========================================================

  Widget buildCustomers() {
    return CustomersScreen(
      customers: customers,
      onAdd: showAddCustomerDialog,
      onDelete: (customer) {
        setState(() {
          customers.remove(customer);
        });
      },
      onView: showCustomerDetails,
    );
  }

  void showAddCustomerDialog() {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final addressController = TextEditingController();
    Uint8List? selectedPhoto;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Add Customer',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: SizedBox(
            width: 450,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Center(
  child: StatefulBuilder(
    builder: (context, setPhotoState) {
      return GestureDetector(
        onTap: () async {
          final picker = ImagePicker();

          final image = await picker.pickImage(
            source: ImageSource.gallery,
          );

          if (image != null) {
            selectedPhoto = await image.readAsBytes();
            setPhotoState(() {});
          }
        },
        child: CircleAvatar(
          radius: 45,
          backgroundColor: Colors.grey.shade200,
          backgroundImage: selectedPhoto != null
              ? MemoryImage(selectedPhoto!)
              : null,
          child: selectedPhoto == null
              ? const Icon(
                  Icons.camera_alt,
                  size: 32,
                )
              : null,
        ),
      );
    },
  ),
),
const SizedBox(height: 16),
                  TextField(
                    controller: nameController,
                    decoration: inputDecoration(
                      'Customer Name',
                      Icons.person_outline,
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    inputFormatters: [
  FilteringTextInputFormatter.digitsOnly,
  LengthLimitingTextInputFormatter(10),
],
                    decoration: inputDecoration(
                      'Phone Number',
                      Icons.phone_outlined,
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: addressController,
                    maxLines: 3,
                    decoration: inputDecoration(
                      'Address',
                      Icons.location_on_outlined,
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                if (nameController.text.trim().isEmpty) {
                  return;
                }

                setState(() {
                  customers.add(
                    Customer(
                      id: nextCustomerId++,
                      name: nameController.text.trim(),
                      phone: phoneController.text.trim(),
                      address: addressController.text.trim(),
                      photoBytes: selectedPhoto,
                    ),
                  );
                });

                Navigator.pop(context);

                ScaffoldMessenger.of(this.context).showSnackBar(
                  const SnackBar(
                    content: Text('Customer added successfully'),
                  ),
                );
              },
              child: const Text('Add Customer'),
            ),
          ],
        );
      },
    );
  }

  void showCustomerDetails(Customer customer) {
    final customerLoans =
        loans.where((loan) => loan.customerId == customer.id).toList();
        final totalCustomerPayable = customerLoans.fold(
  0.0,
  (sum, loan) => sum + loan.totalPayable,
);

final totalCustomerPaid = customerLoans.fold(
  0.0,
  (sum, loan) => sum + loanPaid(loan),
);

final totalCustomerOutstanding = customerLoans.fold(
  0.0,
  (sum, loan) => sum + loanOutstanding(loan),
);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
         

          title: Text(customer.name),
          content: SizedBox(
            width: 500,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                infoRow(Icons.phone, customer.phone),
                Center(
  child: CircleAvatar(
    radius: 50,
    backgroundImage: customer.photoBytes != null
        ? MemoryImage(customer.photoBytes!)
        : null,
    child: customer.photoBytes == null
        ? Text(
            customer.name.isNotEmpty
                ? customer.name[0].toUpperCase()
                : '?',
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          )
        : null,
  ),
),

const SizedBox(height: 15),
                const SizedBox(height: 10),
                infoRow(Icons.location_on, customer.address),
                const SizedBox(height: 18),
                const Divider(),
                const Text(
  'Financial Summary',
  style: TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
  ),
),

const SizedBox(height: 10),

Text('Total Payable: ${money(totalCustomerPayable)}'),
Text('Total Paid: ${money(totalCustomerPaid)}'),
Text('Total Outstanding: ${money(totalCustomerOutstanding)}'),

const SizedBox(height: 18),
                
                const Text(
                  'Loans',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                if (customerLoans.isEmpty)
                  const Text('No loans yet')
                else
                  ...customerLoans.map(
                    (loan) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(
                        Icons.account_balance_wallet,
                      ),
                      title: Text(
                        money(loan.principal),
                      ),
                     subtitle: Text(
  '${loan.frequency} • ${loan.tenureMonths} months\n'
  'Paid: ${money(loanPaid(loan))} • Outstanding: ${money(loanOutstanding(loan))}\n'
  'Status: ${loanStatus(loan) == 'Active' ? '🟢 Active' : '⚪ Closed'}',
),
trailing: Row(
  mainAxisSize: MainAxisSize.min,
  children: [
    Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: loanPaid(loan) >= loan.installmentAmount
            ? Colors.green.shade100
            : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        loanPaid(loan) >= loan.installmentAmount
            ? 'Paid'
            : 'Pending',
        style: TextStyle(
          color: loanPaid(loan) >= loan.installmentAmount
              ? Colors.green.shade700
              : Colors.grey.shade700,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),

    const SizedBox(width: 10),

    ElevatedButton(
      onPressed: () {
        showPaymentDialog(loan);
      },
      child: const Text('Collect'),
    ),
  ],
),
                     
                    ),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  // ==========================================================
  // LOANS
  // ==========================================================

  Widget buildLoans() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Loans',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              FilledButton.icon(
                onPressed: showNewLoanDialog,
                icon: const Icon(Icons.add),
                label: const Text('New Loan'),
              ),
            ],
          ),

          const SizedBox(height: 20),

          if (loans.isEmpty)
            emptyCard('No loans created yet')
          else
            ...loans.map((loan) {
              final customer = customers.firstWhere(
                (c) => c.id == loan.customerId,
                orElse: () => Customer(
                  id: 0,
                  name: 'Unknown',
                  phone: '',
                  address: '',
                ),
              );

              return loanCard(loan, customer);
            }),
        ],
      ),
    );
  }

double loanPaid(Loan loan) {
  return payments
      .where((p) => p.loanId == loan.id)
      .fold(0.0, (sum, p) => sum + p.amount);
}

double loanOutstanding(Loan loan) {
  return (loan.totalPayable - loanPaid(loan))
      .clamp(0.0, double.infinity)
      .toDouble();
}
int overdueInstallments(Loan loan) {
  final dates = getInstallmentDates(loan);
  final installment = loan.installmentAmount;
  final paid = loanPaid(loan);

  return List.generate(dates.length, (index) {
    final alreadyAllocated = installment * index;
    final remainingPaid = paid - alreadyAllocated;

    final installmentPaid =
        remainingPaid >= installment;

    final isOverdue =
        !installmentPaid &&
        dates[index].isBefore(DateTime.now());

    return isOverdue ? 1 : 0;
  }).fold(0, (sum, value) => sum + value);
}
String loanStatus(Loan loan) {
  return loanOutstanding(loan) <= 0 ? 'Closed' : 'Active';
}
void showOverdueLoansDialog() {
  final overdueLoans = loans
      .where((loan) => overdueInstallments(loan) > 0)
      .toList();

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Overdue Loans'),
        content: SizedBox(
          width: 500,
          child: overdueLoans.isEmpty
              ? const Text('No overdue installments')
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: overdueLoans.length,
                  itemBuilder: (context, index) {
                    final loan = overdueLoans[index];
                    final customer = customers.firstWhere(
                      (c) => c.id == loan.customerId,
                    );

                    return ListTile(
                      title: Text(customer.name),
                      subtitle: Text(
                        '${overdueInstallments(loan)} overdue installment(s)',
                      ),
                      trailing: Text(
                        money(loanOutstanding(loan)),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      );
    },
  );
}
int _weekdayNumber(String day) {
  switch (day) {
    case 'Monday':
      return DateTime.monday;
    case 'Tuesday':
      return DateTime.tuesday;
    case 'Wednesday':
      return DateTime.wednesday;
    case 'Thursday':
      return DateTime.thursday;
    case 'Friday':
      return DateTime.friday;
    case 'Saturday':
      return DateTime.saturday;
    case 'Sunday':
      return DateTime.sunday;
    default:
      return DateTime.monday;
  }
}
List<DateTime> getInstallmentDates(Loan loan) {
  List<DateTime> dates = [];

  for (int i = 1; i <= loan.installmentCount; i++) {
    DateTime date;

    switch (loan.frequency) {
      case 'Daily':
        date = loan.startDate.add(Duration(days: i));
        break;

      case 'Weekly':
  date = loan.startDate.add(Duration(days: i * 7));

  if (loan.collectionDays.isNotEmpty) {
    final targetDay = loan.collectionDays.first;

    while (date.weekday != _weekdayNumber(targetDay)) {
      date = date.add(const Duration(days: 1));
    }
  }
  break;

      case '15 Days':
        date = loan.startDate.add(Duration(days: i * 15));
        break;

      case 'Monthly':
  final day = loan.collectionDates.isNotEmpty
      ? loan.collectionDates.first
      : loan.startDate.day;

  date = DateTime(
    loan.startDate.year,
    loan.startDate.month + i,
    day,
  );
  break;
      default:
        date = loan.startDate.add(Duration(days: i * 30));
    }

    dates.add(date);
  }

  return dates;
}
void showLoanDetails(Loan loan, Customer customer) {
  final dates = getInstallmentDates(loan);
  final paid = loanPaid(loan);
  final installment = loan.installmentAmount;
  final loanPayments =
    payments.where((p) => p.loanId == loan.id).toList()
      ..sort((a, b) => b.date.compareTo(a.date));

final lastPaymentDate =
    loanPayments.isEmpty ? null : loanPayments.first.date;
  final List<double> installmentPaidAmounts =
    List.generate(dates.length, (index) {
  final alreadyAllocated = installment * index;
  final remainingPaid = paid - alreadyAllocated;

  if (remainingPaid <= 0) {
    return 0;
  }

  return remainingPaid >= installment
      ? installment
      : remainingPaid;
});
  

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(
          '${customer.name} - Loan Details',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        content: SizedBox(
          width: 600,
          height: 550,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
  child: CircleAvatar(
    radius: 45,
    backgroundImage: customer.photoBytes != null
        ? MemoryImage(customer.photoBytes!)
        : null,
    child: customer.photoBytes == null
        ? Text(
            customer.name.isNotEmpty
                ? customer.name[0].toUpperCase()
                : '?',
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          )
        : null,
  ),
),

const SizedBox(height: 12),
                Text(
                  'Loan Amount: ${money(loan.principal)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text('Interest: ${money(loan.totalInterest)}'),
                Text('Total Payable: ${money(loan.totalPayable)}'),
                Text(
  'Outstanding: ${money(loanOutstanding(loan))}',
  style: const TextStyle(
    fontWeight: FontWeight.bold,
  ),
),
                Text('Installment: ${money(installment)}'),
                Text('Frequency: ${loan.frequency}'),
                Text('Tenure: ${loan.tenureMonths} months'),
                Text(
  'Last Payment: ${lastPaymentDate == null ? 'No payment yet' : '${lastPaymentDate.day}/${lastPaymentDate.month}/${lastPaymentDate.year}'}',
),

                const SizedBox(height: 18),
                const Divider(),
                const Text(
  'Payment History',
  style: TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
  ),
),
const SizedBox(height: 10),
Text(
  'Total Collected: ${money(paid)}',
  style: const TextStyle(
    fontWeight: FontWeight.bold,
  ),
),

if (loanPayments.isEmpty)
  const Text('No payments yet')
else
  ...loanPayments.map(
    (payment) => Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '${payment.date.day}/${payment.date.month}/${payment.date.year}',
          ),
          Text(
            money(payment.amount),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(payment.mode),
        ],
      ),
    ),
  ),

const SizedBox(height: 12),

                const SizedBox(height: 10),
                const Text(
                  'Installment Schedule',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 12),

                ...List.generate(dates.length, (index) {
                  
    final date = dates[index];

final installmentPaid =
    installmentPaidAmounts[index] >= installment;
    final installmentPartial =
    installmentPaidAmounts[index] > 0 &&
    installmentPaidAmounts[index] < installment;

final isOverdue =
    !installmentPaid && date.isBefore(DateTime.now());


                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: installmentPaid
                          ? Colors.green.withOpacity(.08)
                          : Colors.grey.withOpacity(.06),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: installmentPaid
    ? Colors.green.withOpacity(.15)
    : isOverdue
        ? Colors.red.withOpacity(.15)
        : Colors.orange.withOpacity(.15),
                          child: Text(
                            '${index + 1}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                             color: installmentPaid
    ? Colors.green
    : isOverdue
        ? Colors.red
        : Colors.orange,
                            ),
                          ),
                        ),

                        const SizedBox(width: 12),

                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Installment ${index + 1}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '${date.day.toString().padLeft(2, '0')}/'
                                '${date.month.toString().padLeft(2, '0')}/'
                                '${date.year}',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),

                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                             '${money(installmentPaidAmounts[index])} / ${money(installment)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                             installmentPaid
    ? 'Paid'
    : installmentPartial
        ? 'Partially Paid'
        : isOverdue
            ? 'Overdue'
            : 'Pending',
                              style: TextStyle(
                                color: installmentPaid
    ? Colors.green
    : isOverdue
        ? Colors.red
        : Colors.orange,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      );
    },
  );
}
Widget loanCard(Loan loan, Customer customer) {
  final paid = loanPaid(loan);
  final outstanding = loanOutstanding(loan);
  final status = loanStatus(loan);

  return Container(
    margin: const EdgeInsets.only(bottom: 14),
    padding: const EdgeInsets.all(20),
    decoration: cardDecoration(),
    child: Column(
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 25,
              backgroundColor:
                  const Color(0xFF0D2747).withOpacity(.1),
              child: const Icon(
                Icons.account_balance_wallet,
                color: Color(0xFF0D2747),
              ),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    customer.name,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    '${loan.frequency} • ${loan.tenureMonths} months',
                    style: TextStyle(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),

            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  money(loan.principal),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 6),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: status == 'Active'
                        ? Colors.green.withOpacity(.1)
                        : Colors.grey.withOpacity(.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      color: status == 'Active'
                          ? Colors.green[700]
                          : Colors.grey[700],
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),

        const Divider(height: 30),

        Wrap(
          alignment: WrapAlignment.spaceAround,
          spacing: 30,
          runSpacing: 16,
          children: [
            loanInfo(
              'Interest',
              money(loan.totalInterest),
            ),

            loanInfo(
              'Total Payable',
              money(loan.totalPayable),
            ),

            loanInfo(
              'Paid',
              money(paid),
            ),

            loanInfo(
              'Outstanding',
              money(outstanding),
            ),

            loanInfo(
              'Installment',
              money(loan.installmentAmount),
            ),
            const SizedBox(height: 18),

SizedBox(
  width: double.infinity,
  child: OutlinedButton.icon(
    onPressed: () => showLoanDetails(loan, customer),
    icon: const Icon(Icons.visibility_outlined),
    label: const Text('View Loan Details'),
    ),
),

const SizedBox(height: 10),

SizedBox(
  width: double.infinity,
  child: FilledButton.icon(
   onPressed: () => showPaymentDialog(loan), 
    icon: const Icon(Icons.payments_outlined),
    label: const Text('Collect Payment'),
  ),
),

          ],
        ),
      ],
    ),
  );
}  

  DateTime addMonthsClamped(DateTime date, int months) {
  final target = DateTime(date.year, date.month + months, 1);
  final lastDay =
      DateTime(target.year, target.month + 1, 0).day;

  final day = date.day > lastDay ? lastDay : date.day;

  return DateTime(
    target.year,
    target.month,
    day,
  );
}
Widget loanDetailRow(String title, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 7),
    child: Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ],
    ),
  );
}
  Widget loanInfo(String title, String value) {
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  // ==========================================================
  // NEW LOAN DIALOG
  // ==========================================================

  void showNewLoanDialog() {
    if (customers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('First add a customer'),
        ),
      );
      return;
    }

    Customer selectedCustomer = customers.first;

    final amountController = TextEditingController();
    final tenureController = TextEditingController(text: '10');

    String frequency = 'Monthly';
   String? collectionDay = 'Tuesday';
int? collectionDate;

    double interest = 0;
    double total = 0;
    double installment = 0;
    int installmentCount = 10;

    void calculate(StateSetter setDialogState) {
      final principal =
          double.tryParse(amountController.text) ?? 0;

      final tenure =
          int.tryParse(tenureController.text) ?? 0;

      interest = principal * 0.05 * tenure;
      total = principal + interest;

      switch (frequency) {
        case 'Daily':
          installmentCount = tenure * 30;
          break;
        case 'Weekly':
          installmentCount = (tenure * 30 / 7).ceil();
          break;
        case '15 Days':
          installmentCount = (tenure * 30 / 15).ceil();
          break;
        case 'Monthly':
          installmentCount = tenure;
          break;
      }

      installmentCount =
          installmentCount <= 0 ? 1 : installmentCount;

      installment = total / installmentCount;

      setDialogState(() {});
    }

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text(
                'Create New Loan',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: SizedBox(
                width: 520,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DropdownButtonFormField<Customer>(
                        value: selectedCustomer,
                        decoration: inputDecoration(
                          'Customer',
                          Icons.person_outline,
                        ),
                        items: customers.map(
                          (customer) {
                            return DropdownMenuItem(
                              value: customer,
                              child: Text(customer.name),
                            );
                          },
                        ).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            selectedCustomer = value;
                            setDialogState(() {});
                          }
                        },
                      ),
                  

                      const SizedBox(height: 14),

                      TextField(
                        controller: amountController,
                        keyboardType:
                            const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: inputDecoration(
                          'Loan Amount',
                          Icons.currency_rupee,
                        ),
                        onChanged: (_) {
                          calculate(setDialogState);
                        },
                      ),

                      const SizedBox(height: 14),

                      TextField(
                        controller: tenureController,
                        keyboardType: TextInputType.number,
                        decoration: inputDecoration(
                          'Tenure (Months)',
                          Icons.calendar_month,
                        ),
                        onChanged: (_) {
                          calculate(setDialogState);
                        },
                      ),

                      const SizedBox(height: 14),

                      TextField(
                        readOnly: true,
                        controller:
                            TextEditingController(text: '5% per month'),
                        decoration: inputDecoration(
                          'Interest Rate',
                          Icons.percent,
                        ),
                      ),

                      const SizedBox(height: 14),

                      DropdownButtonFormField<String>(
                        value: frequency,
                        decoration: inputDecoration(
                          'Payment Frequency',
                          Icons.schedule,
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'Daily',
                            child: Text('Daily'),
                          ),
                          DropdownMenuItem(
                            value: 'Weekly',
                            child: Text('Weekly'),
                          ),
                          DropdownMenuItem(
                            value: '15 Days',
                            child: Text('Every 15 Days'),
                          ),
                          DropdownMenuItem(
                            value: 'Monthly',
                            child: Text('Monthly'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
  frequency = value;
  collectionDay = null;
  collectionDate = null;
  calculate(setDialogState);
}
                        },
                      ),
           const SizedBox(height: 14),

if (frequency == 'Weekly') ...[
  DropdownButtonFormField<String>(
    value: collectionDay,
    decoration: inputDecoration(
      'Collection Day',
      Icons.calendar_today,
    ),
    items: const [
      DropdownMenuItem(
        value: 'Tuesday',
        child: Text('Tuesday'),
      ),
      DropdownMenuItem(
        value: 'Saturday',
        child: Text('Saturday'),
      ),
    ],
    onChanged: (value) {
      if (value != null) {
        setDialogState(() {
          collectionDay = value;
          collectionDate = null;
        });
      }
    },
  ),
],

if (frequency == 'Monthly') ...[
  DropdownButtonFormField<int>(
    value: collectionDate,
    decoration: inputDecoration(
      'Collection Date',
      Icons.event,
    ),
    items: const [
      DropdownMenuItem(
        value: 5,
        child: Text('5'),
      ),
      DropdownMenuItem(
        value: 10,
        child: Text('10'),
      ),
      DropdownMenuItem(
        value: 15,
        child: Text('15'),
      ),
      DropdownMenuItem(
        value: 20,
        child: Text('20'),
      ),
      DropdownMenuItem(
        value: 25,
        child: Text('25'),
      ),
      DropdownMenuItem(
        value: 30,
        child: Text('30'),
      ),
    ],
    onChanged: (value) {
      setDialogState(() {
        collectionDate = value;
      });
    },
  ),
],



          




                      const SizedBox(height: 20),

                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F6FB),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            calculationRow(
                              'Principal',
                              money(
                                double.tryParse(
                                      amountController.text,
                                    ) ??
                                    0,
                              ),
                            ),
                            calculationRow(
                              'Total Interest',
                              money(interest),
                            ),
                            calculationRow(
                              'Total Payable',
                              money(total),
                            ),
                            calculationRow(
                              'No. of Installments',
                              installmentCount.toString(),
                            ),
                            const Divider(),
                            calculationRow(
                              'Installment Amount',
                              money(installment),
                              bold: true,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                FilledButton.icon(
                  onPressed: () {
                    final principal =
                        double.tryParse(
                          amountController.text,
                        ) ??
                        0;

                    final tenure =
                        int.tryParse(
                          tenureController.text,
                        ) ??
                        0;

                    if (principal <= 0 || tenure <= 0) {
                      ScaffoldMessenger.of(this.context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Enter valid loan amount and tenure',
                          ),
                        ),
                      );
                      return;
                    }
                    if (frequency == 'Weekly' && collectionDay == null) {
  ScaffoldMessenger.of(this.context).showSnackBar(
    const SnackBar(
      content: Text('Please select a Collection Day'),
    ),
  );
  return;
}

if (frequency == 'Monthly' && collectionDate == null) {
  ScaffoldMessenger.of(this.context).showSnackBar(
    const SnackBar(
      content: Text('Please select a Collection Date'),
    ),
  );
  return;
}

                    setState(() {
                      loans.add(
                        Loan(
                          id: nextLoanId++,
                          customerId: selectedCustomer.id,
                          principal: principal,
                          monthlyRate: 5,
                          tenureMonths: tenure,
                         frequency: frequency,

collectionDays: frequency == 'Weekly' && collectionDay != null
    ? [collectionDay!]
    : const [],

collectionDates: frequency == 'Monthly'
    ? [collectionDate!]
    : const [],

startDate: DateTime.now(),
                        ),
                      );
                    });

                    Navigator.pop(context);

                    ScaffoldMessenger.of(this.context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Loan created successfully',
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.check),
                  label: const Text('Create Loan'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget calculationRow(
    String title,
    String value, {
    bool bold = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontWeight:
                    bold ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight:
                  bold ? FontWeight.bold : FontWeight.normal,
              fontSize: bold ? 17 : 14,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // PAYMENTS
  // ==========================================================

  Widget buildPayments() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Payments',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              FilledButton.icon(
                onPressed: showPaymentDialog,
                icon: const Icon(Icons.add),
                label: const Text('Collect Payment'),
              ),
            ],
          ),

          const SizedBox(height: 20),

          if (payments.isEmpty)
            emptyCard('No payments collected yet')
          else
            ...payments.reversed.map(
              (payment) {
                final loan = loans.firstWhere(
                  (l) => l.id == payment.loanId,
                );

                final customer = customers.firstWhere(
                  (c) => c.id == loan.customerId,
                );

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(18),
                  decoration: cardDecoration(),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor:
                            Colors.green.withOpacity(.1),
                        child: const Icon(
                          Icons.arrow_downward,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              customer.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              payment.mode,
                              style: TextStyle(
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        money(payment.amount),
                        style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

 void showPaymentDialog([Loan? preselectedLoan]) {
  if (loans.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('First create a loan'),
      ),
    );
    return;
  }

  Loan selectedLoan = preselectedLoan ?? loans.first;
  String mode = 'Cash';
  int selectedInstallment = 1;
DateTime paymentDate = DateTime.now();
for (int i = 0; i < selectedLoan.installmentCount; i++) {
  final installmentNo = i + 1;

  final paidAmount = payments
      .where(
        (p) =>
            p.loanId == selectedLoan.id &&
            p.installmentNumber == installmentNo,
      )
      .fold(0.0, (sum, p) => sum + p.amount);

  if (paidAmount < selectedLoan.installmentAmount) {
    selectedInstallment = installmentNo;
    break;
  }
}

  final amountController = TextEditingController(
    text: loanOutstanding(selectedLoan) > 0
        ? loanOutstanding(selectedLoan)
            .clamp(0, selectedLoan.installmentAmount)
            .toStringAsFixed(0)
        : '0',
  );

  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setDialogState) {
          final customer = customers.firstWhere(
            (c) => c.id == selectedLoan.customerId,
          );

          final paid = loanPaid(selectedLoan);
          final outstanding = loanOutstanding(selectedLoan);

          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Text(
              'Collect Payment',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 21,
              ),
            ),
            content: SizedBox(
              width: 430,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // CUSTOMER
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0D2747).withOpacity(.05),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          const CircleAvatar(
                            backgroundColor: Color(0xFF0D2747),
                            child: Icon(
                              Icons.person,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  customer.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  customer.phone,
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),
                    ListTile(
  contentPadding: EdgeInsets.zero,
  leading: const Icon(Icons.calendar_month),
  title: const Text('Payment Date'),
  subtitle: Text(
    '${paymentDate.day.toString().padLeft(2, '0')}/'
    '${paymentDate.month.toString().padLeft(2, '0')}/'
    '${paymentDate.year}',
  ),
  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
  onTap: () async {
    final picked = await showDatePicker(
      context: context,
      initialDate: paymentDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setDialogState(() {
        paymentDate = picked;
      });
    }
  },
),

                    // LOAN
                    DropdownButtonFormField<Loan>(
                      value: selectedLoan ?? loans.first,
                      decoration: inputDecoration(
  'Select Loan',
  Icons.account_balance_wallet_outlined,
),
                    items: (preselectedLoan != null ? [preselectedLoan] : loans).map((loan) {
                        final c = customers.firstWhere(
                          (customer) =>
                              customer.id == loan.customerId,
                        );

                        return DropdownMenuItem<Loan>(
                          value: loan,
                          child: Text(
                            '${c.name} • ${money(loan.principal)}',
                          ),
                        );
                      }).toList(),
                     onChanged: preselectedLoan != null
    ? null
    : (value) {
                        if (value == null) return;

                        setDialogState(() {
                          selectedLoan = value;

                          final remaining =
                              loanOutstanding(selectedLoan);

                          amountController.text =
                              remaining > 0
                                  ? remaining
                                      .clamp(
                                        0,
                                        selectedLoan
                                            .installmentAmount,
                                      )
                                      .toStringAsFixed(0)
                                  : '0';
                        });
                      },
                    ),
                    const SizedBox(height: 14),

DropdownButtonFormField<int>(
  value: selectedInstallment,
  decoration: inputDecoration(
    'Installment',
    Icons.event_note,
  ),
  items: List.generate(
  selectedLoan.installmentCount,
  (index) {
    final installmentNo = index + 1;

    final installmentDate =
        getInstallmentDates(selectedLoan)[index];

    final paidAmount = payments
        .where(
          (p) =>
              p.loanId == selectedLoan.id &&
              p.installmentNumber == installmentNo,
        )
        .fold(0.0, (sum, p) => sum + p.amount);

    final isPaid =
        paidAmount >= selectedLoan.installmentAmount;

    return DropdownMenuItem<int>(
      value: installmentNo,
      enabled: !isPaid,
      child: Text(
        'Installment $installmentNo — '
        '${installmentDate.day.toString().padLeft(2, '0')}/'
        '${installmentDate.month.toString().padLeft(2, '0')}/'
        '${installmentDate.year}'
        '${isPaid ? ' ✓ Paid' : ''}',
      ),
    );
  },
),
  onChanged: (value) {
    if (value != null) {
      setDialogState(() {
        selectedInstallment = value;
      });
    }
  },
),

                    const SizedBox(height: 18),

                    // LOAN SUMMARY
                    Row(
                      children: [
                        Expanded(
                          child: _paymentSummaryItem(
                            'Total Payable',
                            money(selectedLoan.totalPayable),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _paymentSummaryItem(
                            'Paid',
                            money(paid),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    Row(
                      children: [
                        Expanded(
                          child: _paymentSummaryItem(
                            'Outstanding',
                            money(outstanding),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _paymentSummaryItem(
                            'Installment',
                            money(
                              selectedLoan.installmentAmount,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // AMOUNT
                    TextField(
                      controller: amountController,
                      keyboardType:
                          const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: inputDecoration(
  'Payment Amount',
  Icons.currency_rupee,
),
                    ),

                    const SizedBox(height: 18),

                    // PAYMENT MODE
                    DropdownButtonFormField<String>(
                      value: mode,
                      decoration: inputDecoration(
  'Payment Mode',
  Icons.payment,
),
                      items: const [
                        DropdownMenuItem(
                          value: 'Cash',
                          child: Text('Cash'),
                        ),
                        DropdownMenuItem(
                          value: 'UPI',
                          child: Text('UPI'),
                        ),
                        DropdownMenuItem(
                          value: 'Bank Transfer',
                          child: Text('Bank Transfer'),
                        ),
                        DropdownMenuItem(
                          value: 'Cheque',
                          child: Text('Cheque'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value == null) return;

                        setDialogState(() {
                          mode = value;
                        });
                      },
                    ),

                    const SizedBox(height: 14),

                    // SUGGESTION
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(.07),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Colors.green[700],
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Suggested installment: '
                              '${money(selectedLoan.installmentAmount)}',
                              style: TextStyle(
                                color: Colors.green[800],
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Cancel'),
              ),
              FilledButton.icon(
                onPressed: () {
                  final amount = double.tryParse(
                    amountController.text.trim(),
                  );

                  if (amount == null || amount <= 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Enter a valid payment amount',
                        ),
                      ),
                    );
                    return;
                  }
                 

                  final currentOutstanding =
                      loanOutstanding(selectedLoan);

                  if (currentOutstanding <= 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'This loan is already closed',
                        ),
                      ),
                    );
                    return;
                  }

                  if (amount > currentOutstanding) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Maximum payment is '
                          '${money(currentOutstanding)}',
                        ),
                      ),
                    );
                    return;
                  }

                  setState(() {
                    payments.add(
                      Payment(
                        id: nextPaymentId++,
                        loanId: selectedLoan.id,
                        amount: amount,
                       date: paymentDate,
                        mode: mode,
                       installmentNumber: selectedInstallment,
dueDate: getInstallmentDates(selectedLoan)[selectedInstallment - 1],
                      ),
                    );
                  });

                  Navigator.pop(context);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Payment of ${money(amount)} collected successfully',
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.check),
                label: const Text('Save Payment'),
              ),
            ],
          );
        },
      );
    },
  );
}

Widget _paymentSummaryItem(String title, String value) {
  return Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.grey.withOpacity(.06),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ],
    ),
  );
} 

  // ==========================================================
  // REPORTS
  // ==========================================================

  
  Widget buildReports() {
    final totalPrincipal = loans.fold<double>(
      0,
      (sum, loan) => sum + loan.principal,
    );

    final totalInterest = loans.fold<double>(
      0,
      (sum, loan) => sum + loan.totalInterest,
    );

    final totalPayable = loans.fold<double>(
      0,
      (sum, loan) => sum + loan.totalPayable,
    );

    final totalCollected = payments.fold<double>(
      0,
      (sum, payment) => sum + payment.amount,
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Reports',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 20),

          reportCard(
            'Total Principal',
            money(totalPrincipal),
            Icons.account_balance,
          ),

          reportCard(
            'Expected Interest',
            money(totalInterest),
            Icons.percent,
          ),

          reportCard(
            'Total Payable',
            money(totalPayable),
            Icons.currency_rupee,
          ),

          reportCard(
            'Total Collected',
            money(totalCollected),
            Icons.payments,
          ),

          reportCard(
            'Outstanding',
            money(totalPayable - totalCollected),
            Icons.pending_actions,
          ),
        ],
      ),
    );
  }

  Widget reportCard(
    String title,
    String value,
    IconData icon,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(20),
      decoration: cardDecoration(),
      child: Row(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor:
                const Color(0xFF0D2747).withOpacity(.08),
            child: Icon(
              icon,
              color: const Color(0xFF0D2747),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // HELPERS
  // ==========================================================

  String money(double value) {
    return '₹${value.toStringAsFixed(2)}';
  }

  BoxDecoration cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(.05),
          blurRadius: 15,
          offset: const Offset(0, 5),
        ),
      ],
    );
  }

  Widget emptyCard(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(35),
      decoration: cardDecoration(),
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            color: Colors.grey[600],
          ),
        ),
      ),
    );
  }

  InputDecoration inputDecoration(
    String label,
    IconData icon,
  ) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  Widget infoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 20),
        const SizedBox(width: 10),
        Expanded(
          child: Text(text),
        ),
      ],
    );
  }
}

// ============================================================
// CUSTOMERS SCREEN
// ============================================================

class CustomersScreen extends StatefulWidget {
  final List<Customer> customers;
  final VoidCallback onAdd;
  final Function(Customer) onDelete;
  final Function(Customer) onView;

  const CustomersScreen({
    super.key,
    required this.customers,
    required this.onAdd,
    required this.onDelete,
    required this.onView,
  });

  @override
  State<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> {
  String search = '';

  @override
  Widget build(BuildContext context) {
    final filtered = widget.customers.where((customer) {
      final query = search.toLowerCase();

      return customer.name.toLowerCase().contains(query) ||
          customer.phone.contains(query);
    }).toList();

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Customers',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              FilledButton.icon(
                onPressed: widget.onAdd,
                icon: const Icon(Icons.person_add),
                label: const Text('Add Customer'),
              ),
            ],
          ),

          const SizedBox(height: 20),

          TextField(
            decoration: InputDecoration(
              hintText: 'Search by name or phone...',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
            onChanged: (value) {
              setState(() {
                search = value;
              });
            },
          ),

          const SizedBox(height: 20),

          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Text(
                      'No customers found',
                      style: TextStyle(
                        color: Colors.grey[600],
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final customer = filtered[index];
                      
                      






                      return Container(
                        margin:
                            const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                              BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color:
                                  Colors.black.withOpacity(.04),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                           CircleAvatar(
  radius: 25,
  backgroundColor:
      const Color(0xFF0D2747).withOpacity(.1),
  backgroundImage: customer.photoBytes != null
      ? MemoryImage(customer.photoBytes!)
      : null,
  child: customer.photoBytes == null
      ? Text(
          customer.name.isNotEmpty
              ? customer.name[0].toUpperCase()
              : '?',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF0D2747),
          ),
        )
      : null,
),

                            const SizedBox(width: 14),

                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    customer.name,
                                    style: const TextStyle(
                                      fontSize: 17,
                                      fontWeight:
                                          FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    customer.phone,
                                    style: TextStyle(
                                      color:
                                          Colors.grey[600],
                                    ),
                                  ),
                                  const SizedBox(height: 4),




                                  Text(
                                    customer.address,
                                    maxLines: 1,
                                    overflow:
                                        TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color:
                                          Colors.grey[600],
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            IconButton(
                              tooltip: 'View',
                              onPressed: () =>
                                  widget.onView(customer),
                              icon: const Icon(
                                Icons.visibility_outlined,
                              ),
                            ),

                            IconButton(
                              tooltip: 'Delete',
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: const Text(
                                        'Delete Customer?',
                                      ),
                                      content: Text(
                                        'Delete ${customer.name}?',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(
                                            context,
                                          ),
                                          child: const Text(
                                            'Cancel',
                                          ),
                                        ),
                                        FilledButton(
                                          onPressed: () {
                                            widget.onDelete(
                                              customer,
                                            );
                                            Navigator.pop(
                                              context,
                                            );
                                            setState(() {});
                                          },
                                          child: const Text(
                                            'Delete',
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                              icon: const Icon(
                                Icons.delete_outline,
                                color: Colors.red,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}