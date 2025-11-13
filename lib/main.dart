import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

enum PopUpItem { itemOne, itemTwo, itemThree }

void main() {
  runApp(MainApp());
}

class MainApp extends StatefulWidget {
  MainApp({super.key});
  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
List<Person> contactList = [Person('Alice Burger', 0, 'alice.burger@mc-donalds.de', 'Loves burgers'), Person('Alice Pasta', 1, 'alice.pasta@spaghetti-mafia.it', 'Loves pasta')];
  List<Person> filteredContactList = [];
  bool adminFilterBool = false;
  bool userFilterBool = false;
  bool guestFilterBool = false;
  final filterValue = <String>[];

  @override
  void initState() {
    filteredContactList = contactList;
    super.initState();
  }

  List<String> roles = ['Admin', 'User', 'Guest'];
  void addPerson(Person person) {
    setState(() {
      contactList.add(person);
    });
  }

Future<void> sendMail(int index, String bodyText, String subject) async {
        final url = 'https://api.mailersend.com/v1/email';
        final API_KEY = 'mlsn.3d59a101087d58d62616f7d1589b8ea96877a4c97ba720b2ea02927a4e799e39';

        Map<String, String> headers = ({
          'Content-Type': 'application/json',
          'X-Requested-With': 'XMLHttpRequest',
          'Authorization': 'Bearer ${API_KEY}'
        });

        Object body = jsonEncode({
          "from": {"email": "MS_ApjIxP@test-vz9dlem26np4kj50.mlsender.net"},
          "to": [
          {"email": "theo.kramer.bus@gmail.com"}
          ],
          "subject": subject,
          "text": bodyText,
          "html": bodyText
        });      

        final response = await http.post(Uri.parse(url), headers: headers, body: body);
        if (response.statusCode == 202) {
          print('Mail send');
        }
        else {print(response.body);
        }
      }

      Future<void> openMailForm(BuildContext context, String contactName) async {
    double width = MediaQuery.sizeOf(context).width;
    double height = MediaQuery.sizeOf(context).height;

    print("hellooo, width: $width, height: $height");

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        final controller = TextEditingController(
          text:
              'Hello $contactName,\n\n'
        );

        return AlertDialog(
          title: const Text("Sending Email!"),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Sending Reminder to $contactName'),
                const SizedBox(height: 12),
                TextField(
                  controller: controller,
                  maxLines: null,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Email Content',
                    alignLabelWithHint: true,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => sendMail(  contactList.indexWhere((person) => person.name == contactName), controller.text, "Mail von FlüBa").then((_) {
                Navigator.of(context).pop();
              }),
              child: const Text('Send'),
            ),
          ],
        );
      },
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        floatingActionButton: AddParticipant(onAdd: addPerson, roles: roles),
        body: Center(
          child: Column(
            children: [
              PopupMenuButton(
                itemBuilder: (BuildContext context) => [
                  PopupMenuItem(
                    value: PopUpItem.itemOne,
                    child: StatefulBuilder(
                      builder: (_context, _setState) => CheckboxListTile(
                        title: const Text('Admins'),
                        autofocus: false,
                        selected: adminFilterBool,
                        value: adminFilterBool,
                        onChanged: (bool? value) {
                          _setState(() {
                            adminFilterBool = value ?? true;
                            adminFilterBool
                                ? filterValue.add('Admin')
                                : filterValue.remove('Admin');
                          });
                        },
                      ),
                    ),
                  ),
                  PopupMenuItem(
                    child: StatefulBuilder(
                      builder: (_context, _setState) => CheckboxListTile(
                        title: const Text('User'),
                        autofocus: false,
                        selected: userFilterBool,
                        value: userFilterBool,
                        onChanged: (bool? value) {
                          _setState(() {
                            userFilterBool = value ?? true;
                            userFilterBool
                                ? filterValue.add('User')
                                : filterValue.remove('User');
                          });
                        },
                      ),
                    ),
                  ),
                  PopupMenuItem(
                    child: StatefulBuilder(
                      builder: (_context, _setState) => CheckboxListTile(
                        title: const Text('Guests'),
                        autofocus: false,
                        selected: guestFilterBool,
                        value: guestFilterBool,
                        onChanged: (bool? value) {
                          _setState(() {
                            guestFilterBool = value ?? true;
                            guestFilterBool
                                ? filterValue.add('Guest')
                                : filterValue.remove('Guest');
                          });
                        },
                      ),
                    ),
                  ),
                  PopupMenuItem(
                    child: StatefulBuilder(
                      builder: (_context, _setState) => ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          adminFilterBool || userFilterBool || guestFilterBool
                              ? {
                                  /* filterValue.forEach((value){}), */
                                  print(filterValue),
                                  filteredContactList = contactList
                                      .where(
                                        (dude) =>
                                            dude.rolle ==
                                            roles.indexWhere(
                                              (rolle) => rolle.contains(
                                                filterValue[0],
                                              ),
                                            ),
                                      )
                                      .toList(),
                                  setState(() {}),
                                  filteredContactList.isEmpty
                                      ? {
                                          filteredContactList = [
                                            Person(
                                              'Leider gibt es keine Personen mit dieser Rolle:',
                                              roles.indexWhere(
                                                (rolle) => rolle.contains(
                                                  filterValue[0],
                                                ),
                                              ),
                                              '',
                                              '',
                                            ),
                                          ],
                                        }
                                      : {},
                                }
                              : {
                                  filteredContactList = contactList,
                                  setState(() {}),
                                };
                        },
                        child: Text('Anwenden'),
                      ),
                    ),
                  ),
                ],
                icon: Icon(Icons.tune),
                tooltip: 'Filter',
              ),
              /* SizedBox(
                width: 150,
                child: CheckboxListTile(
                  title: const Text('Admins'),
                  autofocus: false,
                  selected: adminFilterValue,
                  value: adminFilterValue,
                  onChanged: (bool? value) {
                    setState(() {
                      adminFilterValue = value ?? true;
                      userFilterValue = false;
                      guestfilterValue = false;
                      filterValue = 'Admin';
                    });
                  },
                ),
              ),
              SizedBox(
                width: 150,
                child: CheckboxListTile(
                  title: const Text('User'),
                  autofocus: false,
                  selected: userFilterValue,
                  value: userFilterValue,
                  onChanged: (bool? value) {
                    setState(() {
                      userFilterValue = value ?? true;
                      adminFilterValue = false;
                      guestfilterValue = false;
                      filterValue = 'User';
                    });
                  },
                ),
              ),
              SizedBox(
                width: 150,
                child: CheckboxListTile(
                  title: const Text('Guest'),
                  autofocus: false,
                  selected: guestfilterValue,
                  value: guestfilterValue,
                  onChanged: (bool? value) {
                    setState(() {
                      guestfilterValue = value ?? true;
                      adminFilterValue = false;
                      userFilterValue = false;
                      filterValue = 'Guest';
                    });
                  },
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  adminFilterValue || userFilterValue || guestfilterValue
                      ? {
                          filteredContactList
                     = contactList
                              .where(
                                (dude) =>
                                    dude.rolle ==
                                    roles.indexWhere(
                                      (rolle) => rolle.contains(filterValue),
                                    ),
                              )
                              .toList(),
                          setState(() {}),
                          filteredContactList
                    .isEmpty
                              ? {
                                  filteredContactList
                             = [
                                    Person(
                                      'Leider gibt es keine Personen mit dieser Rolle:',
                                      roles.indexWhere(
                                        (rolle) => rolle.contains(filterValue),
                                      ),
                                      '',
                                      '',
                                    ),
                                  ],
                                }
                              : {},
                        }
                      : {filteredContactList
                 = contactList, setState(() {})};
                },
                child: Text('Anwenden'),
              ), */
              Expanded(
                flex: 2,
                child: ListView.builder(
                  itemCount: 1,
                  itemBuilder: (context, index) {
                    return SizedBox(
                      height: 520,
                      child: ListView.builder(
                        itemCount: filteredContactList.length,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () => openMailForm(context, contactList[index].name),
                            child: ListTile(
                              title: Column(
                                children: [
                                  Row(
                                    spacing: 10.0,
                                    children: [
                                      Text(filteredContactList[index].name),
                                      Text(
                                        roles[filteredContactList[index].rolle],
                                      ),
                                    ],
                                  ),
                                  Row(
                                    spacing: 5.0,
                                    children: [
                                      Text(filteredContactList[index].mail),
                                      Text(filteredContactList[index].text),
                                    ],
                                  ),
                                ],
                              ),
                              horizontalTitleGap: 5.0,
                              tileColor: (index % 2 == 0)
                                  ? const Color.fromARGB(255, 177, 177, 177)
                                  : const Color.fromARGB(255, 141, 141, 141),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
              /*               filteredContactList
         = contactList.indexWhere((penis) => penis.rolle.toInt() == 0);
 */
              /*               SizedBox(
                height: 520,
                child: ListView.builder(
                  itemCount: contactList.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Column(
                        children: [
                          Row(
                            spacing: 10.0,
                            children: [
                              Text(contactList[index].name),
                              Text(roles[contactList[index].rolle]),
                            ],
                          ),
                          Row(
                            spacing: 5.0,
                            children: [
                              Text(contactList[index].mail),
                              Text(contactList[index].text),
                            ],
                          ),
                        ],
                      ),
                      horizontalTitleGap: 5.0,
                      tileColor: (index % 2 == 0)
                          ? const Color.fromARGB(255, 177, 177, 177)
                          : const Color.fromARGB(255, 141, 141, 141),
                    );
                  },
                ),
              ), */
            ],
          ),
        ),
      ),
    );
  }
}

class AddParticipant extends StatefulWidget {
  final Function(Person) onAdd;
  final List<String> roles;
  AddParticipant({super.key, required this.onAdd, required this.roles});

  @override
  State<AddParticipant> createState() => _AddParticipantState();
}

class _AddParticipantState extends State<AddParticipant> {
  TextEditingController nameController = TextEditingController();

  TextEditingController mailController = TextEditingController();

  TextEditingController textController = TextEditingController();

  int selectedRole = 0;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        showDialog(
          builder: (context) {
            return StatefulBuilder(
              builder: (context, setState) {
                return AlertDialog(
                  title: Text("Add Participant"),
                  content: Column(
                    children: [
                      MyFormField(myController: nameController, text: "Name"),
                      DropdownButton<String>(
                        items: widget.roles.map((role) {
                          return DropdownMenuItem<String>(
                            value: role,
                            child: Text(role),
                          );
                        }).toList(),
                        value: widget.roles[selectedRole],
                        onChanged: (value) {
                          setState(() {
                            selectedRole = widget.roles.indexOf(value!);
                          });
                        },
                      ),
                      MyFormField(myController: mailController, text: "Mail"),
                      MyFormField(myController: textController, text: "Text"),
                      SizedBox(height: 20.0),
                      ElevatedButton(
                        onPressed: () {
                          widget.onAdd(
                            Person(
                              nameController.text,
                              int.parse(selectedRole.toString()),
                              mailController.text,
                              textController.text,
                            ),
                          );
                          nameController.clear();
                          mailController.clear();
                          textController.clear();
                          selectedRole = 0;
                          Navigator.of(context).pop();
                        },
                        child: Text("Add Participant"),
                      ),
                    ],
                  ),
                );
              },
            );
          },
          context: context,
        );
      },
      child: Icon(Icons.add),
    );
  }
}

class Person {
  String name;
  int rolle;
  String mail;
  String text;

  Person(this.name, this.rolle, this.mail, this.text);
}

class MyFormField extends StatelessWidget {
  const MyFormField({
    super.key,
    required this.myController,
    required this.text,
  });

  final TextEditingController myController;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 30.0),
      child: Column(
        children: [
          Text(text),
          TextField(controller: myController),
        ],
      ),
    );
  }
}
