import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

class EventList extends StatefulWidget {
  const EventList({super.key});

  @override
  State<EventList> createState() => _EventListState();
}

class _EventListState extends State<EventList> {
  final List<String> initialEventsList = [
    "AED pads applied",
    "Backboard",
    "Bag-mask device",
    "Cardiac Monitor",
    "Endotracheal intubation",
    "IO access",
    "IV access",
    "Nasal cannula",
    "Nasopharyngeal airway",
    "Oropharyngeal airway",
    "Oxygen",
    "Pulse Check",
    "Supraglottic airway",
    "Waveform capnography"
  ];

  final _codeBlueBox = Hive.box('code_blue_box');
  List<String> itemsList = ["Empty List"];

  void checkForFirstRun() {
    if (_codeBlueBox.get("initialize_events_list") == null) {
      setState(() {
        itemsList = initialEventsList;
        saveItemsToDB();
      });
      _codeBlueBox.put("initialize_events_list", "false");
    }
  }

  void setList() {
    if (_codeBlueBox.get("events_list").toString().isNotEmpty) {
      setState(() {
        itemsList = _codeBlueBox.get("events_list");
      });
    }
  }

  void saveItemsToDB() {
    itemsList.sort((a, b) => a.toUpperCase().compareTo(b.toUpperCase()));
    _codeBlueBox.put("events_list", itemsList);
    setList();
  }

  void addItemToList(String value, int index) {
    itemsList[index] = value;
    saveItemsToDB();
  }

  void deleteItemFromList(int index) {
    itemsList.removeAt(index);
    saveItemsToDB();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      checkForFirstRun();
      setList();
    });
  }

  @override
  Widget build(BuildContext context) {
    Map<int, bool> selectedFlag = {};
    bool isSelectionMode = false;
    String addItemTextEntry = '';
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          showDialog(
              context: context,
              builder: (context) => SimpleDialog(
                    title: const Text('Add Item:'),
                    children: [
                      Padding(
                        padding: EdgeInsets.all(20.0),
                        child: TextFormField(
                          onChanged: (value) {
                            setState(() {
                              addItemTextEntry = value;
                            });
                          },
                        ),
                      ),
                      MaterialButton(
                        child: new Text("Save"),
                        onPressed: () {
                          setState(() {
                            itemsList.add(addItemTextEntry);
                            saveItemsToDB();
                          });
                          Navigator.pop(context);
                        },
                      )
                    ],
                  ));
        },
      ),
      appBar: AppBar(
        title: Text("Events"),
      ),
      body: ListView.builder(
          padding: EdgeInsets.all(15),
          itemCount: itemsList.length,
          itemBuilder: (BuildContext context, int index) {
            selectedFlag[index] = selectedFlag[index] ?? false;
            bool? isSelected = selectedFlag[index];
            String tempTextEntry = itemsList[index];
            return ListTile(
              visualDensity: VisualDensity(vertical: 3),
              title: InkWell(
                onTap: () {
                  Navigator.pop(context, '${itemsList[index]}');
                },
                child: Padding(
                  padding: EdgeInsets.all(15.0),
                  child: Text('${itemsList[index]}'),
                ),
              ),
              trailing: Container(
                  width: 70,
                  child: Row(
                    children: [
                      Expanded(
                        child: IconButton(
                            onPressed: () {
                              showDialog(
                                  context: context,
                                  builder: (context) => SimpleDialog(
                                        title: const Text('Edit Item:'),
                                        children: [
                                          Padding(
                                            padding: EdgeInsets.all(20.0),
                                            child: TextFormField(
                                              initialValue:
                                                  '${itemsList[index]}',
                                              onChanged: (value) {
                                                setState(() {
                                                  tempTextEntry = value;
                                                });
                                              },
                                            ),
                                          ),
                                          MaterialButton(
                                            child: new Text("Update"),
                                            onPressed: () {
                                              setState(() {
                                                addItemToList(
                                                    tempTextEntry, index);
                                              });
                                              Navigator.pop(context);
                                            },
                                          )
                                        ],
                                      ));
                            },
                            icon: Icon(Icons.edit)),
                      ),
                      Spacer(),
                      Expanded(
                          child: IconButton(
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text("Delete Item"),
                                    content: Text(
                                        'Are you sure you want to delete this item? : ${itemsList[index]}"'),
                                    actions: <Widget>[
                                      TextButton(
                                        onPressed: () {
                                          setState(() {
                                            deleteItemFromList(index);
                                          });
                                          Navigator.of(context).pop();
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.all(14),
                                          child: const Text("Yes"),
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.all(14),
                                          child: const Text("No"),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              icon: Icon(Icons.delete))),
                    ],
                  )),
            );
          }),
    );
  }
}
