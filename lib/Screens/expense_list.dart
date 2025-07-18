import 'package:expense_tracker/Provider/expenseProvider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../Screens/add_update_expense_screen.dart';
import '../appModels/expenseModel.dart';

class ExpenseList extends ConsumerStatefulWidget {
  const ExpenseList({super.key});

  @override
  ConsumerState<ExpenseList> createState() => _ExpenseListState();
}

class _ExpenseListState extends ConsumerState<ExpenseList> {
  TextEditingController searchController = TextEditingController();
  List<expenseModel> filteredExpenses = [];

  @override
  void initState() {
    super.initState();
    final notifier = ref.read(expensesProvider.notifier);
    notifier.fetchExpenses().then((_) {
      setState(() {
        filteredExpenses = ref.read(expensesProvider).expenses.cast<expenseModel>();
      });
    });
  }

  void filterSearchResults(String query) {
    final allExpenses = ref.read(expensesProvider).expenses;
    if (query.isEmpty) {
      setState(() {
        filteredExpenses = allExpenses.cast<expenseModel>();
      });
    } else {
      setState(() {
        filteredExpenses = allExpenses
            .where((expense) =>
            expense.title!.toLowerCase().contains(query.toLowerCase())).cast<expenseModel>()
            .toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    print("build called");
    final expenseData = ref.watch(expensesProvider);
    final notifier = ref.read(expensesProvider.notifier);

    return Scaffold(
      backgroundColor: Colors.grey.shade800,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Expenses", style: TextStyle(color: Colors.white)),
            Text("Total Exp.: ₹${expenseData.total}",
                style: const TextStyle(color: Colors.white)),
          ],
        ),
      ),
      body: expenseData.expenses.isEmpty
          ? const Center(child: Text("No Expenses yet!!", style: TextStyle(color: Colors.white)))
          : Column(
        children: [
          SizedBox(height: 10,),
          Padding(
            padding: const EdgeInsets.only(left: 8,right: 8),
            child: TextField(
              controller: searchController,
              onChanged: filterSearchResults,
              style: const TextStyle(color: Colors.black),
              decoration: InputDecoration(
                hintText: "Search Expenses with Title",
                label : Text("Search" , style: TextStyle(color: Colors.white),),
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey.shade500,
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white54,width: 2),
                  borderRadius: BorderRadius.circular(9),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              itemCount: filteredExpenses.length,
              itemBuilder: (context, index) {
                final item = filteredExpenses[index];
                return Padding(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.blueGrey.shade200,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "    ${item.date!.split('T')[0]}",
                          style: const TextStyle(color: Colors.black),
                        ),
                        ListTile(
                          shape: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          tileColor: Colors.grey,
                          title: Text(
                            item.title ?? "",
                            style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            "₹ ${item.amount} | ${item.category}",
                            style: const TextStyle(
                                fontWeight: FontWeight.bold),
                          ),
                          trailing: PopupMenuButton<String>(
                            onSelected: (value) async {
                              if (value == 'update') {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        AddUpdateExpenseScreen(
                                            expense: item),
                                  ),
                                );
                              } else if (value == 'delete') {
                                await notifier.deleteExpense(item.id! as int);
                                filterSearchResults(searchController.text);
                              }
                            },
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'update',
                                child: Text('Update'),
                              ),
                              const PopupMenuItem(
                                value: 'delete',
                                child: Text('Delete'),
                              ),
                            ],
                            icon: const Icon(Icons.more_vert),
                          ),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddUpdateExpenseScreen(),
            ),
          );
          await notifier.fetchExpenses();
          filterSearchResults(searchController.text);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
