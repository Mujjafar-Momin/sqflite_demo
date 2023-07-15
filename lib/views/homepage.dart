// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:sqflite_demo_project/sqlDataBase/sqlhelper.dart';

class HomePage extends StatefulWidget {
  final String title;
  const HomePage({super.key, required this.title});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> _journals = [];
  bool isLoading = true;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  void _refreshJournals() async {
    final data = await SqlHelper.getItems();
    setState(() {
      _journals = data;
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _refreshJournals();
    debugPrint("..journals count ${_journals.length}");
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _addItem() async {
    await SqlHelper.createItem(_titleController.text, _descController.text);
    _refreshJournals();
  }

  Future<void> _updateItem(int id) async {
    await SqlHelper.updateItem(id, _titleController.text, _descController.text);
    _refreshJournals();
  }

  void _deletItem(int id) async {
    await SqlHelper.deleteItem(id);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        duration: Duration(seconds: 1),
        padding: EdgeInsets.all(10),
        backgroundColor: Colors.amberAccent,
        showCloseIcon: true,
        closeIconColor: Colors.black,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(15))),
        content: Padding(
          padding: EdgeInsets.all(14.0),
          child: Text(
            'Note Deleted Successfully',
            style: TextStyle(color: Colors.black),
          ),
        )));
    _refreshJournals();
  }

  _showCard(int? id) async {
    if (id != null) {
      final existingJournal =
          _journals.firstWhere((element) => element['id'] == id);
      _titleController.text = existingJournal['title'];
      _descController.text = existingJournal['description'];
    }
    submitNote() async {
      if (_formKey.currentState!.validate()) {
        String textValue = _titleController.text;
        debugPrint('Text field value: $textValue');

        if (id == null) {
          await _addItem();
        }
        if (id != null) {
          await _updateItem(id);
        }
        _titleController.clear();
        _descController.clear();
        Navigator.of(context).pop();
      }
    }

    showModalBottomSheet(
        context: context,
        elevation: 5,
        isScrollControlled: true,
        builder: (_) => Container(
              padding: EdgeInsets.only(
                left: 20,
                right: 30,
                top: 15,
                bottom: MediaQuery.of(context).viewInsets.bottom + 220,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      TextFormField(
                        controller: _titleController,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter a title';
                          }
                          return null;
                        },
                        decoration: const InputDecoration(hintText: 'Title'),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      TextFormField(
                        controller: _descController,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter a description';
                          }
                          return null;
                        },
                        decoration:
                            const InputDecoration(hintText: 'Description'),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              _titleController.clear();
                              _descController.clear();
                              Navigator.of( context).pop();
                            },
                            style: const ButtonStyle(
                                backgroundColor:
                                    MaterialStatePropertyAll(Colors.amber)),
                            child:const Text("Cancel"),
                          ),
                         const SizedBox(width: 7,),
                        ElevatedButton(
                            onPressed: () => submitNote(),
                            style: const ButtonStyle(
                                backgroundColor:
                                    MaterialStatePropertyAll(Colors.amber)),
                            child: Text(id == null ? "Create Item" : "Update Item"),
                          ),
                        ],
                      )
                    ]),
              ),
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("SQFlite"),
        backgroundColor: Colors.amberAccent,
      ),
      body: ListView.builder(
        itemCount: _journals.length,
        itemBuilder: (context, index) => Card(
          child: ListTile(
            title: Text(_journals[index]['title']),
            subtitle: Text(_journals[index]['description']),
            trailing: SizedBox(
                width: 100,
                child: Row(
                  children: [
                    IconButton(
                        onPressed: () => _showCard(_journals[index]['id']),
                        icon: const Icon(Icons.edit)),
                    IconButton(
                        onPressed: () => _deletItem(_journals[index]['id']),
                        icon: const Icon(Icons.delete)),
                  ],
                )),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCard(null),
        backgroundColor: Colors.amber,
        child: const Icon(Icons.add),
      ),
    );
  }
}
