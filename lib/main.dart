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

enum City {
  owerri,
  lagos,
  aba,
}

typedef WeatherEmoji = String;
Future<WeatherEmoji> getWeather(City city) {
  return Future.delayed(
      const Duration(seconds: 2),
      () =>
          {
            City.aba: 'rainy ',
            City.lagos: 'sunny',
            City.owerri: 'dry',
          }[city] ??
          'no city');
}

//ui reads and writes from this one
final currentCityProvider = StateProvider<City?>(
  (ref) => null,
);
const unKonwnWeatherEmoji = 'no such weather';
//Ui reads this one
final weatherProvider = FutureProvider<WeatherEmoji>((ref) {
  final city = ref.watch(currentCityProvider);
  if (city != null) {
    return getWeather(city);
  } else {
    return unKonwnWeatherEmoji;
  }
});

class MyHomePage extends ConsumerWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentWeather = ref.watch(
      weatherProvider,
    );
    return Scaffold(
        appBar: AppBar(
          title: const Text('Weather'),
        ),
        body: Column(
          children: [
            currentWeather.when(
              data: (data) {
                return Text(
                  data,
                  style: const TextStyle(fontSize: 40),
                );
              },
              error: (_, __) {
                return const Text('no such data');
              },
              loading: () => const Padding(
                padding: EdgeInsets.all(8.0),
                child: CircularProgressIndicator(),
              ),
            ),
            Expanded(
              child: ListView.builder(
                  itemCount: City.values.length,
                  itemBuilder: (context, value) {
                    final city = City.values[value];
                    final isSelected = city == ref.watch(currentCityProvider);
                    return ListTile(
                      title: Text(city.toString()),
                      trailing: isSelected ? const Icon(Icons.check) : null,
                      onTap: () {
                        ref
                            .read(
                              currentCityProvider.notifier,
                            )
                            .state = city;
                      },
                    );
                  }),
            ),
          ],
        ));
  }
}
