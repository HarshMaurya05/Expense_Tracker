import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../appModels/expenseModel.dart';

class ExpensesNotifier extends ChangeNotifier {
  final String apiUrl = 'https://6878e84563f24f1fdc9ff73f.mockapi.io/api/v1/Expenses';

  List<expenseModel> _expenses = [];
  int _total = 0;

  List<expenseModel> get expenses => _expenses;
  int get total => _total;
  bool load = false;

  // Fetch
  Future<void> fetchExpenses() async {
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        load = true;
        List jsonList = jsonDecode(response.body);
        _expenses = jsonList.map((e) => expenseModel.fromJson(e)).toList();
        _total = _expenses.fold(0, (sum, item) {
          int amountValue;

          if (item.amount is int) {
            amountValue = item.amount!;
          } else if (item.amount is String) {
            amountValue = int.tryParse(item.amount as String) ?? 0;
          } else {
            amountValue = 0;
          }

          return sum + amountValue;
        });

        notifyListeners();
        load = false;
      }
    } catch (e) {
      print("Fetch error: $e");
    }
  }

  // Add
  Future<void> addExpense(expenseModel expense) async {
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(expense.toJson()),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        await fetchExpenses();
      }
    } catch (e) {
      print("Add error: $e");
    }
  }

  // Update
  Future<void> updateExpense(String id, expenseModel updatedExpense) async {
    try {
      final response = await http.put(
        Uri.parse('$apiUrl/$id'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(updatedExpense.toJson()),
      );
      if (response.statusCode == 200) {
        notifyListeners();
        await fetchExpenses();

      }
    } catch (e) {
      print("Update error: $e");
    }
  }

  // Delete
  Future<void> deleteExpense(int? id) async {
    try {
      final response = await http.delete(
        Uri.parse("$apiUrl/$id"),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode >= 200 && response.statusCode < 300) {
        await fetchExpenses();
      } else {
        throw Exception("Failed to delete expense: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Delete error: $e");
    }
  }
}

final expensesProvider = ChangeNotifierProvider((ref) => ExpensesNotifier());

