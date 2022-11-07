import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:uuid/uuid.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

@immutable
class Person {
  final String name;
  final int age;
  final String uuid;
  Person({required this.name, required this.age, String? uuid})
      : uuid = uuid ?? const Uuid().v4();

  Person updated([String? name, int? age]) => Person(
        name: name ?? this.name,
        age: age ?? this.age,
        uuid: uuid,
      );

  String get displayName => '$name ($age years old)';

  @override
  bool operator ==(covariant Person other) => uuid == other.uuid;

  @override
  int get hashCode => uuid.hashCode;

  @override
  String toString() => 'Person (name: $name, age: $age, uuid:$uuid)';
}

class DataModel extends ChangeNotifier {
  final List<Person> _person = [];

  int get count => _person.length;

  UnmodifiableListView<Person> get person => UnmodifiableListView(_person);

  void addPerson(Person person) {
    _person.add(person);
    notifyListeners();
  }

  void removePerson(Person person) {
    _person.remove(person);
    notifyListeners();
  }

  void update(Person updatePerson) {
    final index = _person.indexOf(updatePerson);
    final oldPerson = _person[index];
    if (oldPerson.name != updatePerson.name ||
        oldPerson.age != updatePerson.age) {
      _person[index] = oldPerson.updated(
        updatePerson.name,
        updatePerson.age,
      );
    }
    notifyListeners();
  }
}

final peopleProvider = ChangeNotifierProvider((_) => DataModel());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    // testIt();
    return MaterialApp(
      title: 'Flutter Demo',
      // theme: ThemeData(
      //   primarySwatch: Colors.blue,
      // ),
      debugShowCheckedModeBanner: false,
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.dark,
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends ConsumerWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather'),
      ),
      body: Consumer(builder: (context, ref, child) {
        final datamodel = ref.watch(peopleProvider);
        return ListView.builder(
          itemCount: datamodel.count,
          itemBuilder: ((context, index) {
            final person = datamodel.person[index];
            return ListTile(
              title: GestureDetector(
                  onTap: () async {
                    final updatePerson =
                        await createOrUpdatePersonDialog(context, person);
                    if (updatePerson != null) {
                      datamodel.update(updatePerson);
                    }
                  },
                  child: Text(person.displayName)),
            );
          }),
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final persons = await createOrUpdatePersonDialog(context);
          if (persons != null) {
            final datamodel = ref.read(peopleProvider);
            datamodel.addPerson(persons);
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

final nameController = TextEditingController();
final ageController = TextEditingController();

Future<Person?> createOrUpdatePersonDialog(
  BuildContext context, [
  Person? person,
]) {
  String? name = person?.name;
  int? age = person?.age;
  nameController.text = name ?? '';
  ageController.text = age.toString();
  return showDialog<Person?>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add a person'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration:
                    const InputDecoration(labelText: 'Enter name here ... '),
                onChanged: (value) => name = value,
              ),
              TextField(
                controller: ageController,
                decoration:
                    const InputDecoration(labelText: 'Enter name here ... '),
                onChanged: (value) => age = int.tryParse(value),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (name != null && age != null) {
                  if (person != null) {
                    final newPerson = person.updated(
                      name,
                      age,
                    );
                    Navigator.of(context).pop(newPerson);
                  } else {
                    //no existing person
                    Navigator.of(context).pop(
                      Person(name: name!, age: age!),
                    );
                  }
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      });
}
