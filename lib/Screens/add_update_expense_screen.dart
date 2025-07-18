import 'package:expense_tracker/appModels/expenseModel.dart';
import 'package:expense_tracker/Provider/expenseProvider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';

class AddUpdateExpenseScreen extends ConsumerStatefulWidget {
  final expenseModel? expense;

  const AddUpdateExpenseScreen({super.key, this.expense});

  @override
  ConsumerState<AddUpdateExpenseScreen> createState() => _AddUpdateExpenseScreenState();
}

class _AddUpdateExpenseScreenState extends ConsumerState<AddUpdateExpenseScreen> {
  final formKey = GlobalKey<FormState>();

  TextEditingController title = TextEditingController();
  TextEditingController amount = TextEditingController();
  TextEditingController note = TextEditingController();
  String? drpValue;
  DateTime? selectedDate;

  List<String> category = ["Travel", "Medicine", "Recharge", "Food", "Clothes"];

  @override
  void initState() {
    super.initState();
    if (widget.expense != null) {
      title.text = widget.expense!.title ?? '';
      amount.text = widget.expense!.amount?.toString() ?? '';
      note.text = widget.expense!.note ?? '';
      // Only set drpValue if the category is valid and exists in the category list
      if (widget.expense!.category != null && category.contains(widget.expense!.category)) {
        drpValue = widget.expense!.category;
      } else {
        drpValue = null; // Fallback to null if category is invalid
      }
      selectedDate = DateTime.tryParse(widget.expense!.date ?? '');
    }
  }

  Future<void> _pickDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        selectedDate = pickedDate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.expense == null ? "Add Expense" : "Update Expense"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: title,
                decoration: const InputDecoration(
                  labelText: "Title",
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value == null || value.isEmpty ? "Title is required" : null,
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: amount,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: "Amount",
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Amount is required";
                        }
                        if (int.tryParse(value) == null) {
                          return "Please enter a valid integer";
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: DropdownButtonFormField<String>(
                      value: drpValue,
                      decoration: const InputDecoration(
                        labelText: "Category",
                        border: OutlineInputBorder(),
                      ),
                      items: category.map((item) {
                        return DropdownMenuItem(
                          value: item,
                          child: Text(item),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          drpValue = value;
                        });
                      },
                      validator: (value) => value == null ? "Select category" : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: note,
                decoration: const InputDecoration(
                  labelText: "Note (Optional)",
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 12),

              InkWell(
                onTap: _pickDate,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    selectedDate == null
                        ? "Select Date *"
                        : "Date: ${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}",
                    style: TextStyle(
                      fontSize: 16,
                      color: selectedDate == null ? Colors.grey : Colors.black87,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              Center(
                child: ElevatedButton(
                  onPressed: submit,
                  child: Text(widget.expense == null ? "Add Expense" : "Update Expense"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void submit() async {
    if (!formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all required fields")),
      );
      return;
    }

    if (selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a date")),
      );
      return;
    }

    final amountValue = int.tryParse(amount.text);
    if (amountValue == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Invalid amount format")),
      );
      return;
    }

    final newExpense = expenseModel(
      id: widget.expense?.id,
      title: title.text,
      amount: amountValue,
      category: drpValue,
      date: selectedDate!.toIso8601String(),
      note: note.text.isEmpty ? null : note.text,
    );

    try {
      if (widget.expense == null) {
        await ref.read(expensesProvider.notifier).addExpense(newExpense);
        Success();
      } else {
        await ref.read(expensesProvider.notifier).updateExpense(widget.expense!.id!.toString(), newExpense);
        Success();
      }
      Navigator.pop(context); // Go back
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    }
  }

  Center Success(){
    return Center(
      child: Lottie.asset(
        'assets/lottie/success.json',
        width: 200,
        height: 200,
        repeat: true,
        animate: true,
      ),
    );
  }
}