import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

enum TransactionType { sent, received, deposit, withdrawal }

class Transaction {
  final String id;
  final double amount;
  final String description;
  final DateTime timestamp;
  final TransactionType type;
  final String? recipientAccount;
  final String? recipientName;
  
  Transaction({
    required this.id,
    required this.amount,
    required this.description,
    required this.timestamp,
    required this.type,
    this.recipientAccount,
    this.recipientName,
  });
  
  factory Transaction.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Transaction(
      id: doc.id,
      amount: (data['amount'] ?? 0.0).toDouble(),
      description: data['description'] ?? '',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      type: TransactionType.values.firstWhere(
        (e) => e.name == data['type'],
        orElse: () => TransactionType.sent,
      ),
      recipientAccount: data['recipientAccount'],
      recipientName: data['recipientName'],
    );
  }
}

class TransactionProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  List<Transaction> _transactions = [];
  bool _isLoading = false;
  String? _errorMessage;
  
  List<Transaction> get transactions => _transactions;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  
  // Add a method to get recent transactions count for debugging
  int get transactionCount => _transactions.length;
  
  Future<void> fetchTransactions() async {
    try {
      _setLoading(true);
      _clearError();
      final User? user = _auth.currentUser;
      
      if (user == null) {
        _setError('No user logged in');
        _setLoading(false);
        return;
      }

      print('Fetching transactions for user: ${user.uid}');
      
      final QuerySnapshot snapshot = await _firestore
          .collection('transactions')
          .where('userId', isEqualTo: user.uid)
          .get();
      
      print('Found ${snapshot.docs.length} transaction documents');
      
      // Convert to Transaction objects and sort in memory to avoid composite index requirement
      var transactions = snapshot.docs
          .map((doc) {
            try {
              return Transaction.fromFirestore(doc);
            } catch (e) {
              print('Error parsing transaction ${doc.id}: $e');
              return null;
            }
          })
          .whereType<Transaction>()
          .toList();
      
      // Sort by timestamp descending
      transactions.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      
      // Apply limit
      if (transactions.length > 50) {
        transactions = transactions.take(50).toList();
      }
      
      _transactions = transactions;
      print('Successfully loaded ${transactions.length} transactions');
      
      _setLoading(false);
    } catch (e) {
      print('Error fetching transactions: $e');
      _setError('Failed to fetch transactions: $e');
      _setLoading(false);
    }
  }
  
  Future<bool> addTransaction({
    required double amount,
    required String description,
    required TransactionType type,
    String? recipientAccount,
    String? recipientName,
  }) async {
    try {
      final User? user = _auth.currentUser;
      
      if (user == null) {
        _setError('No user logged in');
        return false;
      }
      
      print('Adding transaction: amount=$amount, type=${type.name}, user=${user.uid}');
      
      await _firestore.collection('transactions').add({
        'userId': user.uid,
        'amount': amount,
        'description': description,
        'type': type.name,
        'recipientAccount': recipientAccount,
        'recipientName': recipientName,
        'timestamp': FieldValue.serverTimestamp(),
      });
      
      print('Transaction added successfully to Firestore');
      
      // Refresh transactions
      await fetchTransactions();
      return true;
    } catch (e) {
      print('Error adding transaction: $e');
      _setError('Failed to add transaction: $e');
      return false;
    }
  }
  
  List<Transaction> getTransactionsByType(TransactionType type) {
    return _transactions.where((t) => t.type == type).toList();
  }
  
  double getTotalAmountByType(TransactionType type) {
    return _transactions
        .where((t) => t.type == type)
        .fold(0.0, (sum, t) => sum + t.amount);
  }
  
  List<Transaction> getRecentTransactions(int count) {
    return _transactions.take(count).toList();
  }
  
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
  
  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }
  
  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }
  
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
