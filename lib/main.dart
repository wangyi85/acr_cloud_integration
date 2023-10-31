import 'dart:io';

import 'package:audio_monitor/models/app_state.dart';
import 'package:audio_monitor/models/models.dart';
import 'package:audio_monitor/pages/splash.dart';
import 'package:audio_monitor/store/reducers/app_reducer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_acrcloud/flutter_acrcloud.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:redux/redux.dart';
import 'package:workmanager/workmanager.dart';
import 'package:audio_monitor/utils/consts.dart';

void main() {
	final store = Store<AppState>(appReducer, initialState: AppState(
		recordStatus: RecordStatus(isBackground: false, isRunning: false)
	));
	WidgetsFlutterBinding.ensureInitialized();
	Workmanager().initialize(callbackDispatcher, isInDebugMode: true);
  	runApp(StoreProvider(store: store, child: const MainApp()));
}

void callbackDispatcher() {
	Workmanager().executeTask((taskName, inputData) async {
		if (taskName == 'ACR') {
			print('ACR Background task started');
			if (!ACRCloud.isSetUp) await ACRCloud.setUp(const ACRCloudConfig(accessKey, accessSecret, host));
			final session = ACRCloud.startSession();
			// print(session.volumeStream);
			// Future.delayed(const Duration(seconds: 10), () async {
			// 	session.cancel();
			// 	final result = await session.result;
			// 	print(result!.status.msg);
			// });
		}
		return Future.value(true);
	});
}

Future<void> askPermissions() async {
	var status = await Permission.microphone.status;
	if ((status.isDenied || status.isPermanentlyDenied) && Platform.isAndroid) {
		await [Permission.microphone, Permission.location, Permission.locationAlways, Permission.locationWhenInUse, Permission.phone, Permission.storage].request();
	}
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
