import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:audio_monitor/models/app_state.dart';
import 'package:audio_monitor/models/models.dart';
import 'package:audio_monitor/pages/setting.dart';
import 'package:audio_monitor/pages/source.dart';
import 'package:audio_monitor/store/actions/record_status_action.dart';
import 'package:audio_monitor/widgets/bottombar.dart';
import 'package:audio_monitor/widgets/start_rec_btn.dart';
import 'package:audio_monitor/widgets/stop_rec_back_btn.dart';
import 'package:audio_monitor/widgets/stop_rec_btn.dart';
import 'package:background_fetch/background_fetch.dart';
import 'package:flutter/material.dart';
import 'package:audio_monitor/utils/consts.dart';
import 'package:flutter_acrcloud/flutter_acrcloud.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:permission_handler/permission_handler.dart';

@pragma('vm:entry-point')
void startCallback() {
	// The setTaskHandler function must be called to handle the task in the background.
	FlutterForegroundTask.setTaskHandler(MyTaskHandler());
}

class Home extends StatefulWidget {
	Home({super.key});

	@override
	_HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
	ReceivePort? _receivePort;
	String _result = '';
	dynamic _session;

	@override
	void initState() {
		super.initState();
		_initForegroundTask();
	}

	void onInit(store) async {
		// await askPermissions();
		// ACRCloud.setUp(const ACRCloudConfig(accessKey, accessSecret, host));
		// await initPlatformState();
	}

	Future<void> askPermissions() async {
		var status = await Permission.microphone.status;
		if ((status.isDenied || status.isPermanentlyDenied) && Platform.isAndroid) {
			await [Permission.microphone, Permission.location, Permission.locationAlways, Permission.locationWhenInUse, Permission.phone, Permission.storage].request();
		}
	}

	Future<void> _requestPermissionForAndroid() async {
		if (!Platform.isAndroid) {
			return;
		}

		// "android.permission.SYSTEM_ALERT_WINDOW" permission must be granted for
		// onNotificationPressed function to be called.
		//
		// When the notification is pressed while permission is denied,
		// the onNotificationPressed function is not called and the app opens.
		//
		// If you do not use the onNotificationPressed or launchApp function,
		// you do not need to write this code.
		if (!await FlutterForegroundTask.canDrawOverlays) {
			// This function requires `android.permission.SYSTEM_ALERT_WINDOW` permission.
			await FlutterForegroundTask.openSystemAlertWindowSettings();
		}

		// Android 12 or higher, there are restrictions on starting a foreground service.
		//
		// To restart the service on device reboot or unexpected problem, you need to allow below permission.
		if (!await FlutterForegroundTask.isIgnoringBatteryOptimizations) {
			// This function requires `android.permission.REQUEST_IGNORE_BATTERY_OPTIMIZATIONS` permission.
			await FlutterForegroundTask.requestIgnoreBatteryOptimization();
		}

		// Android 13 and higher, you need to allow notification permission to expose foreground service notification.
		final NotificationPermission notificationPermissionStatus =
			await FlutterForegroundTask.checkNotificationPermission();
		if (notificationPermissionStatus != NotificationPermission.granted) {
			await FlutterForegroundTask.requestNotificationPermission();
		}
  	}

	bool _registerReceivePort(ReceivePort? newReceivePort) {
		if (newReceivePort == null) {
		return false;
		}

		_closeReceivePort();

		_receivePort = newReceivePort;
		_receivePort?.listen((data) {
			if (data is int) {
				print('eventCount: $data');
			} else if (data is String) {
				if (data == 'onNotificationPressed') {
					// Navigator.of(context).pushNamed('/resume-route');
				}
			} else if (data is DateTime) {
				print('timestamp: ${data.toString()}');
			}
		});

		return _receivePort != null;
	}

	void _closeReceivePort() {
		_receivePort?.close();
		_receivePort = null;
	}

	@override
	void dispose() {
		_closeReceivePort();
		super.dispose();
	}

	void _initForegroundTask() {
		FlutterForegroundTask.init(
			androidNotificationOptions: AndroidNotificationOptions(
				channelId: 'foreground_service',
				channelName: 'Foreground Service Notification',
				channelDescription: 'This notification appears when the foreground service is running.',
				channelImportance: NotificationChannelImportance.LOW,
				priority: NotificationPriority.LOW,
				iconData: const NotificationIconData(
					resType: ResourceType.mipmap,
					resPrefix: ResourcePrefix.ic,
					name: 'launcher',
				),
				buttons: [
					const NotificationButton(id: 'sendButton', text: 'Send'),
					const NotificationButton(id: 'testButton', text: 'Test'),
				],
			),
			iosNotificationOptions: const IOSNotificationOptions(
				showNotification: true,
				playSound: false,
			),
			foregroundTaskOptions: const ForegroundTaskOptions(
				interval: 5000,
				isOnceEvent: false,
				autoRunOnBoot: true,
				allowWakeLock: true,
				allowWifiLock: true,
			),
		);
	}

	Future<bool> _startForegroundTask() async {
		// You can save data using the saveData function.
		await FlutterForegroundTask.saveData(key: 'customData', value: 'hello');

		// Register the receivePort before starting the service.
		final ReceivePort? receivePort = FlutterForegroundTask.receivePort;
		final bool isRegistered = _registerReceivePort(receivePort);
		if (!isRegistered) {
			print('Failed to register receivePort!');
			return false;
		}

		if (await FlutterForegroundTask.isRunningService) {
			return FlutterForegroundTask.restartService();
		} else {
			return FlutterForegroundTask.startService(
				notificationTitle: 'Foreground Service is running',
				notificationText: 'Tap to return to the app',
				callback: startCallback,
			);
		}
	}

	// Platform messages are asynchronous, so we initialize in an async method.
  	Future<void> initPlatformState() async {
		// Configure BackgroundFetch.
		int status = await BackgroundFetch.configure(BackgroundFetchConfig(
			minimumFetchInterval: 15,
			stopOnTerminate: false,
			enableHeadless: true,
			requiresBatteryNotLow: false,
			requiresCharging: false,
			requiresStorageNotLow: false,
			requiresDeviceIdle: false,
			requiredNetworkType: NetworkType.NONE,
			forceAlarmManager: true
		), (String taskId) async {  // <-- Event handler
		// This is the fetch-event callback.
			print("[BackgroundFetch] Event received $taskId");
			// IMPORTANT:  You must signal completion of your task or the OS can punish your app
			// for taking too long in the background.
			await ACRCloud.setUp(const ACRCloudConfig(accessKey, accessSecret, host));
			final session = ACRCloud.startSession();
			print(session.volumeStream);
			Future.delayed(const Duration(seconds: 10), () async {
				session.cancel();
				final result = await session.result;
				print(result!.status.msg);
			});
			BackgroundFetch.finish(taskId);
		}, (String taskId) async {  // <-- Task timeout handler.
		// This task has exceeded its allowed running-time.  You must stop what you're doing and immediately .finish(taskId)
			print("[BackgroundFetch] TASK TIMEOUT taskId: $taskId");
			BackgroundFetch.finish(taskId);
		});
		print('[BackgroundFetch] configure success: $status');

		// If the widget was removed from the tree while the asynchronous platform
		// message was in flight, we want to discard the reply rather than calling
		// setState to update our non-existent appearance.
		if (!mounted) return;
  	}

	void onNavigate(int index) {
		switch(index) {
			case 0:
				break;
			case 1:
				Navigator.push(context, MaterialPageRoute(builder: (context) => Source()));
				break;
			case 2:
				Navigator.push(context, MaterialPageRoute(builder: (context) => Setting()));
				break;
			default:
				break;
		}
	}

	void startRecord() async {
		print('startRecord');
		setState(() {
			_session = ACRCloud.startSession();
		});
		dynamic store;
		if (context.mounted) store = StoreProvider.of<AppState>(context);
		store.dispatch(SetRecordStatus(RecordStatus(isBackground: false, isRunning: true)));
		final result = await _session.result;
		setState(() {
			_result = result!.status.msg;
		});
		store.dispatch(SetRecordStatus(RecordStatus(isBackground: false, isRunning: false)));
	}

	void stopRecord() async {
		dynamic store;
		if (context.mounted) store = StoreProvider.of<AppState>(context);
		store.dispatch(SetRecordStatus(RecordStatus(isBackground: false, isRunning: false)));
		_session.cancel();
		final result = await _session.result;
		if (result != null) {
			setState(() {
				_result = result!.status.msg;
			});
		}
	}

	Future<bool> _stopForegroundTask() {
		return FlutterForegroundTask.stopService();
	}

	void stopRecordBackground() async {
		// BackgroundFetch.stop().then((int status) {
		// 	print('[BackgroundFetch] stop success: $status');
		// });
		await _stopForegroundTask();
		dynamic store;
		if (context.mounted) store = StoreProvider.of<AppState>(context);
		store.dispatch(SetRecordStatus(RecordStatus(isBackground: false, isRunning: false)));
	}

	void runBackgroundService() async {
		if (_session != null) _session.cancel();
		// BackgroundFetch.start().then((int status) {
		// 	print('[BackgroundFetch] start success: $status');
		// }).catchError((e) {
		// 	print('[BackgroundFetch] start FAILURE: $e');
		// });
		await _startForegroundTask();
		dynamic store;
		if (context.mounted) store = StoreProvider.of<AppState>(context);
		store.dispatch(SetRecordStatus(RecordStatus(isBackground: true, isRunning: true)));
	}

	@override
	Widget build(BuildContext context) {
		return WithForegroundTask(
			child: Scaffold(
				bottomNavigationBar: BottomBar(onTap: onNavigate, currentIndex: 0),
				body: StoreConnector<AppState, AppState>(
					onInit: (store) => onInit(store),
					converter: (store) => store.state,
					builder: (context, state) => InkWell(
						onDoubleTap: () => runBackgroundService(),
						child: Container(
							width: double.infinity,
							height: double.infinity,
							padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
							color: Colors.white,
							child: Stack(
								alignment: Alignment.center,
								children: [
									Column(
										mainAxisAlignment: MainAxisAlignment.start,
										mainAxisSize: MainAxisSize.max,
										crossAxisAlignment: CrossAxisAlignment.center,
										children: [
											Container(
												width: double.infinity,
												child: Column(
													mainAxisAlignment: MainAxisAlignment.center,
													mainAxisSize: MainAxisSize.min,
													crossAxisAlignment: CrossAxisAlignment.start,
													children: const [
														Padding(
															padding: EdgeInsets.only(top: 30, bottom: 10),
															child: Text(
																'LOGO APP',
																style: TextStyle(
																	fontFamily: 'Futura',
																	fontSize: 30,
																	fontWeight: FontWeight.w700,
																	color: Colors.black
																),
															),
														),
														Padding(
															padding: EdgeInsets.only(bottom: 30),
															child: Text(
																'Double tap to record in background',
																style: TextStyle(
																	fontFamily: 'Futura',
																	fontSize: 16,
																	fontWeight: FontWeight.w500,
																	color: Colors.black
																),
															),
														)
													],
												),
											),
											const SizedBox(height: 100,),
											!state.recordStatus.isRunning ? StartRecBtn(onRecord: startRecord,) : state.recordStatus.isBackground ? StopRecBackBtn(onStop: stopRecordBackground,) : StopRecBtn(onStop: stopRecord,),
											const SizedBox(height: 15,),
											(state.recordStatus.isRunning && !state.recordStatus.isBackground && _session != null) ? StreamBuilder(
												stream: _session.volumeStream,
												initialData: 0.0,
												builder: (_, snapshot) =>
													Text(
														'Recorded Volume: ${snapshot.data.toString()}',
														style: const TextStyle(
															fontFamily: 'Futura',
															fontSize: 18,
															color: Colors.black,
															fontWeight: FontWeight.w400
														),
													),
											): Container(),
											const SizedBox(height: 5,),
											Text(
												'Match Result: $_result',
												style: const TextStyle(
													fontFamily: 'Futura',
													fontSize: 18,
													color: Colors.black,
													fontWeight: FontWeight.w400
												),
											)
										],
									),
									state.recordStatus.isRunning ? 
										state.recordStatus.isBackground ?
											Positioned(
												top: 130,
												child: Row(
													mainAxisAlignment: MainAxisAlignment.center,
													mainAxisSize: MainAxisSize.min,
													children: const [
														Icon(Icons.warning_amber_outlined, size: 18, color: Colors.black,),
														SizedBox(width: 5,),
														Text(
															'BACKGROUND RECOGNITION',
															style: TextStyle(
																fontFamily: 'Futura',
																fontSize: 18,
																color: Colors.black,
																fontWeight: FontWeight.w400
															),
														)
													],
												)
											)
										: Positioned(
											top: 130,
											child: Row(
												mainAxisAlignment: MainAxisAlignment.center,
												mainAxisSize: MainAxisSize.min,
												children: const [
													Icon(Icons.warning_amber_outlined, size: 18, color: Colors.black,),
													SizedBox(width: 5,),
													Text(
														'FOREGROUND RECOGNITION',
														style: TextStyle(
															fontFamily: 'Futura',
															fontSize: 18,
															color: Colors.black,
															fontWeight: FontWeight.w400
														),
													)
												],
											)
										)
									: Container()
								],
							),
						),
					),
				),
			)
		);
	}
}

class MyTaskHandler extends TaskHandler {
	SendPort? _sendPort;
	int _eventCount = 0;

	@override
	void onStart(DateTime timestamp, SendPort? sendPort) async {
		_sendPort = sendPort;

		final customData = await FlutterForegroundTask.getData<String>(key: 'customData');
		print('custom data: $customData');
	}

	@override
	void onRepeatEvent(DateTime timestamp, SendPort? sendPort) async {
		FlutterForegroundTask.updateService(
			notificationText: 'eventCount: $_eventCount',
			notificationTitle: 'MyTaskHandler'
		);
		sendPort?.send(_eventCount);
		_eventCount ++;
	}

	@override
	void onDestroy(DateTime timestamp, SendPort? sendPort) async {
		print('onDestroy');
	}

	@override
	void onNotificationButtonPressed(String id) {
		print('onNotificationButtonPressed: $id');
	}

	@override
	void onNotificationPressed() {
		FlutterForegroundTask.launchApp('/resume-route');
		_sendPort?.send('onNotificationPressed');
	}
}