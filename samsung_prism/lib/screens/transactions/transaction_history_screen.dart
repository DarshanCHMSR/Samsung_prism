import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../providers/transaction_provider.dart';
import '../../utils/app_colors.dart';

class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  State<TransactionHistoryScreen> createState() => _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadTransactions();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadTransactions() {
    final transactionProvider = Provider.of<TransactionProvider>(context, listen: false);
    transactionProvider.fetchTransactions();
  }

  void _addTestTransaction() async {
    final transactionProvider = Provider.of<TransactionProvider>(context, listen: false);
    
    final testTransactions = [
      {
        'amount': 500.0,
        'description': 'Test Payment to Merchant',
        'type': TransactionType.sent,
        'recipientName': 'Test Merchant',
      },
      {
        'amount': 1000.0,
        'description': 'Test Transfer to Friend',
        'type': TransactionType.sent,
        'recipientAccount': '1234567890',
        'recipientName': 'John Doe',
      },
      {
        'amount': 250.0,
        'description': 'Test Received Payment',
        'type': TransactionType.received,
        'recipientName': 'Jane Smith',
      },
    ];

    for (final transaction in testTransactions) {
      await transactionProvider.addTransaction(
        amount: transaction['amount'] as double,
        description: transaction['description'] as String,
        type: transaction['type'] as TransactionType,
        recipientAccount: transaction['recipientAccount'] as String?,
        recipientName: transaction['recipientName'] as String?,
      );
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Test transactions added!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGrey,
      appBar: AppBar(
        title: Text(
          'Transaction History',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: _addTestTransaction,
            tooltip: 'Add Test Transactions',
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _showSearchDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSummaryCards(),
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildAllTransactions(),
                _buildTransactionsByType(TransactionType.sent),
                _buildTransactionsByType(TransactionType.received),
                _buildAnalytics(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards() {
    return Consumer<TransactionProvider>(
      builder: (context, transactionProvider, child) {
        final sentTotal = transactionProvider.getTotalAmountByType(TransactionType.sent);
        final receivedTotal = transactionProvider.getTotalAmountByType(TransactionType.received);

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            gradient: AppColors.primaryGradient,
          ),
          child: Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  'Total Sent',
                  '\$${sentTotal.toStringAsFixed(2)}',
                  Icons.arrow_upward,
                  AppColors.error,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildSummaryCard(
                  'Total Received',
                  '\$${receivedTotal.toStringAsFixed(2)}',
                  Icons.arrow_downward,
                  AppColors.success,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSummaryCard(String title, String amount, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(icon, color: Colors.white, size: 16),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.poppins(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              amount,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: AppColors.primaryBlue,
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        indicatorColor: Colors.white,
        indicatorWeight: 3,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white.withOpacity(0.7),
        labelStyle: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600),
        tabs: const [
          Tab(text: 'All'),
          Tab(text: 'Sent'),
          Tab(text: 'Received'),
          Tab(text: 'Analytics'),
        ],
      ),
    );
  }

  Widget _buildAllTransactions() {
    return Consumer<TransactionProvider>(
      builder: (context, transactionProvider, child) {
        if (transactionProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        // Show error state
        if (transactionProvider.errorMessage != null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: AppColors.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading transactions',
                    style: GoogleFonts.poppins(
                      color: AppColors.error,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    transactionProvider.errorMessage!,
                    style: GoogleFonts.poppins(
                      color: AppColors.textGrey,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      transactionProvider.clearError();
                      _loadTransactions();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    child: Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        final transactions = transactionProvider.transactions;

        if (transactions.isEmpty) {
          return _buildEmptyState();
        }

        return RefreshIndicator(
          onRefresh: () async => _loadTransactions(),
          child: ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: transactions.length,
            itemBuilder: (context, index) {
              final transaction = transactions[index];
              return _buildTransactionCard(transaction);
            },
          ),
        );
      },
    );
  }

  Widget _buildTransactionsByType(TransactionType type) {
    return Consumer<TransactionProvider>(
      builder: (context, transactionProvider, child) {
        if (transactionProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        // Show error state
        if (transactionProvider.errorMessage != null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: AppColors.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading transactions',
                    style: GoogleFonts.poppins(
                      color: AppColors.error,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      transactionProvider.clearError();
                      _loadTransactions();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      foregroundColor: Colors.white,
                    ),
                    child: Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        final transactions = transactionProvider.getTransactionsByType(type);

        if (transactions.isEmpty) {
          return _buildEmptyState(
            message: 'No ${type.name} transactions found',
          );
        }

        return RefreshIndicator(
          onRefresh: () async => _loadTransactions(),
          child: ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: transactions.length,
            itemBuilder: (context, index) {
              final transaction = transactions[index];
              return _buildTransactionCard(transaction);
            },
          ),
        );
      },
    );
  }

  Widget _buildTransactionCard(Transaction transaction) {
    final dateFormat = DateFormat('MMM dd, yyyy • hh:mm a');
    final isReceived = transaction.type == TransactionType.received;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _showTransactionDetails(transaction),
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: isReceived
                        ? AppColors.success.withOpacity(0.1)
                        : AppColors.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Icon(
                    isReceived ? Icons.arrow_downward : Icons.arrow_upward,
                    color: isReceived ? AppColors.success : AppColors.error,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        transaction.description,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (transaction.recipientName != null)
                        Text(
                          isReceived ? 'From ${transaction.recipientName}' : 'To ${transaction.recipientName}',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: AppColors.textGrey,
                          ),
                        ),
                      Text(
                        dateFormat.format(transaction.timestamp),
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: AppColors.textGrey,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${isReceived ? '+' : '-'}\$${transaction.amount.toStringAsFixed(2)}',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        color: isReceived ? AppColors.success : AppColors.error,
                        fontSize: 16,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isReceived
                            ? AppColors.success.withOpacity(0.1)
                            : AppColors.error.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        transaction.type.name.toUpperCase(),
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: isReceived ? AppColors.success : AppColors.error,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState({String? message}) {
    return Consumer<TransactionProvider>(
      builder: (context, transactionProvider, child) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.receipt_long_outlined,
                size: 80,
                color: AppColors.textLight,
              ),
              const SizedBox(height: 16),
              Text(
                message ?? 'No transactions found',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: AppColors.textGrey,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Your transaction history will appear here',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: AppColors.textLight,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Total transactions in database: ${transactionProvider.transactionCount}',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: AppColors.textGrey,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _loadTransactions,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: Colors.white,
                ),
                child: Text('Refresh'),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAnalytics() {
    return Consumer<TransactionProvider>(
      builder: (context, transactionProvider, child) {
        final transactions = transactionProvider.transactions;
        
        if (transactions.isEmpty) {
          return _buildEmptyState(message: 'No data for analytics');
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAnalyticsCard(
                'This Month',
                _getMonthlyStats(transactions),
                Icons.calendar_month,
                AppColors.primaryBlue,
              ),
              const SizedBox(height: 16),
              _buildAnalyticsCard(
                'Average Transaction',
                _getAverageTransactionAmount(transactions),
                Icons.trending_up,
                AppColors.accentGreen,
              ),
              const SizedBox(height: 16),
              _buildAnalyticsCard(
                'Most Frequent',
                _getMostFrequentTransaction(transactions),
                Icons.repeat,
                AppColors.accentOrange,
              ),
              const SizedBox(height: 24),
              _buildRecentActivity(transactions),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAnalyticsCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Icon(icon, color: color, size: 30),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: AppColors.textGrey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivity(List<Transaction> transactions) {
    final recentTransactions = transactions.take(5).toList();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Activity',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 16),
        ...recentTransactions.map((transaction) => Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.backgroundGrey),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  transaction.description,
                  style: GoogleFonts.poppins(fontSize: 14),
                ),
              ),
              Text(
                '\$${transaction.amount.toStringAsFixed(2)}',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  color: transaction.type == TransactionType.received 
                      ? AppColors.success 
                      : AppColors.error,
                ),
              ),
            ],
          ),
        )).toList(),
      ],
    );
  }

  String _getMonthlyStats(List<Transaction> transactions) {
    final now = DateTime.now();
    final thisMonth = transactions.where((t) => 
        t.timestamp.year == now.year && t.timestamp.month == now.month).length;
    return '$thisMonth transactions';
  }

  String _getAverageTransactionAmount(List<Transaction> transactions) {
    if (transactions.isEmpty) return '\$0.00';
    final total = transactions.fold(0.0, (sum, t) => sum + t.amount);
    return '\$${(total / transactions.length).toStringAsFixed(2)}';
  }

  String _getMostFrequentTransaction(List<Transaction> transactions) {
    if (transactions.isEmpty) return 'None';
    final sentCount = transactions.where((t) => t.type == TransactionType.sent).length;
    final receivedCount = transactions.where((t) => t.type == TransactionType.received).length;
    return sentCount > receivedCount ? 'Sent' : 'Received';
  }

  void _showTransactionDetails(Transaction transaction) {
    final dateFormat = DateFormat('MMMM dd, yyyy • hh:mm a');
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textLight,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Transaction Details',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 24),
            _buildDetailRow('Transaction ID', transaction.id),
            _buildDetailRow('Amount', '\$${transaction.amount.toStringAsFixed(2)}'),
            _buildDetailRow('Type', transaction.type.name.toUpperCase()),
            _buildDetailRow('Description', transaction.description),
            if (transaction.recipientName != null)
              _buildDetailRow('Recipient', transaction.recipientName!),
            if (transaction.recipientAccount != null)
              _buildDetailRow('Account', transaction.recipientAccount!),
            _buildDetailRow('Date & Time', dateFormat.format(transaction.timestamp)),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(
                  'Close',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: AppColors.textGrey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Filter Transactions',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('All Transactions'),
              leading: Radio<String>(
                value: 'All',
                groupValue: _selectedFilter,
                onChanged: (value) {
                  setState(() {
                    _selectedFilter = value!;
                  });
                  Navigator.pop(context);
                },
              ),
            ),
            ListTile(
              title: const Text('Last 7 Days'),
              leading: Radio<String>(
                value: '7days',
                groupValue: _selectedFilter,
                onChanged: (value) {
                  setState(() {
                    _selectedFilter = value!;
                  });
                  Navigator.pop(context);
                },
              ),
            ),
            ListTile(
              title: const Text('Last 30 Days'),
              leading: Radio<String>(
                value: '30days',
                groupValue: _selectedFilter,
                onChanged: (value) {
                  setState(() {
                    _selectedFilter = value!;
                  });
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Search Transactions',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: TextField(
          decoration: const InputDecoration(
            hintText: 'Search by description or amount',
            prefixIcon: Icon(Icons.search),
            border: OutlineInputBorder(),
          ),
          onSubmitted: (value) {
            Navigator.pop(context);
            // TODO: Implement search functionality
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Search'),
          ),
        ],
      ),
    );
  }
}
