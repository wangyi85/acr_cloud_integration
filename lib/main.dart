import 'package:audio_monitor/models/app_state.dart';
import 'package:audio_monitor/models/models.dart';
import 'package:audio_monitor/pages/splash.dart';
import 'package:audio_monitor/store/reducers/app_reducer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';

void main() {
	final store = Store<AppState>(appReducer, initialState: AppState(
		recordStatus: RecordStatus(isBackground: false, isRunning: false)
	));
  	runApp(StoreProvider(store: store, child: const MainApp()));
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
