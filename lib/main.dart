import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

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

const names = [
  'fred',
  'peace',
  'goodness',
  'ifeanyi',
  'joy',
  'divine',
  'faith',
  'glad',
  'uchechi',
  'bright',
  'dera',
  'alice',
];

final tickerProvider = StreamProvider(
  (ref) => Stream.periodic(
    const Duration(seconds: 2),
    (i) => i + 1,
  ),
);

final namesProvider = StreamProvider((ref) {
  return ref.watch(tickerProvider.stream).map(
        (event) => names.getRange(
          0,
          event,
        ),
      );
});

class MyHomePage extends ConsumerWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final names = ref.watch(namesProvider);

    return Scaffold(
        appBar: AppBar(
          title: const Text('Weather'),
        ),
        body: names.when(
          data: ((data) {
            return ListView.builder(
                itemCount: data.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(
                      data.elementAt(index),
                    ),
                  );
                });
          }),
          error: (error, stackTrace) => const Text('reached the end '),
          loading: () => const Center(child: CircularProgressIndicator()),
        ));
  }
}
