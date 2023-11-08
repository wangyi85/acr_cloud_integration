import 'dart:io';

import 'package:audio_monitor/models/app_state.dart';
import 'package:audio_monitor/models/models.dart';
import 'package:audio_monitor/pages/splash.dart';
import 'package:audio_monitor/store/reducers/app_reducer.dart';
import 'package:background_fetch/background_fetch.dart';
import 'package:flutter/material.dart';
import 'package:flutter_acrcloud/flutter_acrcloud.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
import 'package:audio_monitor/utils/consts.dart';

void main() {
	HttpOverrides.global = MyHttpOverrides();
	final store = Store<AppState>(appReducer, initialState: AppState(
		recordStatus: RecordStatus(isBackground: false, isRunning: false),
		result: Result(''),
		deviceInfo: DeviceInfo(uuid: '', imei: '', model: '', brand: ''),
		user: User(id: 0, name: '', lastName: '', email: '', gender: '')
	));
	WidgetsFlutterBinding.ensureInitialized();
	// BackgroundFetch.registerHeadlessTask(backgroundFetchHeadlessTask);
  	runApp(RestartWidget(child: StoreProvider(store: store, child: const MainApp())));
}

@pragma('vm:entry-point')
void backgroundFetchHeadlessTask(HeadlessTask task) async {
	String taskId = task.taskId;
	bool isTimeout = task.timeout;
	if (isTimeout) {
		// This task has exceeded its allowed running-time.  
		// You must stop what you're doing and immediately .finish(taskId)
		print("[BackgroundFetch] Headless task timed-out: $taskId");
		BackgroundFetch.finish(taskId);
		return;
	}  
	print('[BackgroundFetch] Headless event received.');
	// Do your work here...
	await ACRCloud.setUp(const ACRCloudConfig(accessKey, accessSecret, host));
	final session = ACRCloud.startSession();
	print(session.volumeStream);
	Future.delayed(const Duration(seconds: 10), () async {
		session.cancel();
		final result = await session.result;
		print(result!.status.msg);
	});
	if (taskId == 'acr_background') {
		BackgroundFetch.scheduleTask(TaskConfig(
			taskId: "acr_background",
			delay: 5000,
			periodic: true,
			forceAlarmManager: true,
			stopOnTerminate: false,
			enableHeadless: true
		));
	}
	BackgroundFetch.finish(taskId);
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

class RestartWidget extends StatefulWidget {
	final Widget child;

  	RestartWidget({required this.child});

	static void restartApp(BuildContext context) {
		context.findAncestorStateOfType<_RestartWidgetState>()!.restartApp();
	}

	@override
	_RestartWidgetState createState() => _RestartWidgetState();
}

class _RestartWidgetState extends State<RestartWidget> {
	Key key = UniqueKey();

	void restartApp() {
		setState(() {
			key = UniqueKey();
		});
	}

	@override
	Widget build(BuildContext context) {
		return KeyedSubtree(
			key: key,
			child: widget.child,
		);
	}
}

class MyHttpOverrides extends HttpOverrides{
	@override
	HttpClient createHttpClient(SecurityContext? context){
		return super.createHttpClient(context)
			..badCertificateCallback = (X509Certificate cert, String host, int port)=> true;
	}
}
