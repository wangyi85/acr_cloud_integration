import 'package:audio_monitor/pages/splash.dart';
import 'package:flutter/material.dart';

void main() {
  	runApp(const MainApp());
}

class MainApp extends StatelessWidget {
	const MainApp({super.key});

	@override
	Widget build(BuildContext context) {
		return MaterialApp(
			home: Splash(),
			theme: ThemeData(
				primaryColor: Colors.white
			),
			debugShowCheckedModeBanner: false,
		);
	}
}
