import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:audio_monitor/models/app_state.dart';
import 'package:audio_monitor/models/models.dart';
import 'package:audio_monitor/pages/setting.dart';
import 'package:audio_monitor/pages/source.dart';
import 'package:audio_monitor/store/actions/record_status_action.dart';
import 'package:audio_monitor/store/actions/result_action.dart';
import 'package:audio_monitor/widgets/bottombar.dart';
import 'package:audio_monitor/widgets/stop_rec_back_btn.dart';
import 'package:audio_monitor/widgets/stop_rec_btn.dart';
import 'package:audio_monitor/widgets/toaster_message.dart';
import 'package:flutter/material.dart';
import 'package:audio_monitor/utils/consts.dart';
import 'package:flutter_acrcloud/flutter_acrcloud.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:phone_state/phone_state.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:audio_session/audio_session.dart';

@pragma('vm:entry-point')
void startCallback() {
	// The setTaskHandler function must be called to handle the task in the background.
	FlutterForegroundTask.setTaskHandler(AudioMonitorTaskHandler());
}

class Home extends StatefulWidget {
	Home({super.key});

	@override
	_HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
	ReceivePort? _receivePort;
	dynamic _session;
	final MethodChannel _channel = const MethodChannel('app_state');

  // Add a function to handle phone call interruptions
  void _handlePhoneCall(PhoneStateStatus phoneState) {
    print ("STATO TELEFONO");
    print (phoneState);
    switch (phoneState) {
      case PhoneStateStatus.CALL_INCOMING:
      case PhoneStateStatus.CALL_STARTED:
        // Pause the service or stop the recording when the call starts
        stopRecord(); // Implement this function to pause or stop recording
        break;
      case PhoneStateStatus.CALL_ENDED:
        // Resume your app's functionality or restart the service after the call ends
        runBackgroundService(); // Implement this function to restart the service
        break;
      default:
        break;
    }
  }

	@override
	void initState() {
		super.initState();
    PhoneState.phoneStateStream.listen((event) {
    if (event != null) {
      print("HANDLING CALL!L!L!");
      _handlePhoneCall(event);
    }
    });
		WidgetsBinding.instance.addPostFrameCallback((_) async {
			await _requestPermissionForAndroid();
			_initForegroundTask();
			
			// You can get the previous ReceivePort without restarting the service.
			if (await FlutterForegroundTask.isRunningService) {
				final newReceivePort = FlutterForegroundTask.receivePort;
				_registerReceivePort(newReceivePort);
			}

			var prefs = await SharedPreferences.getInstance();
			var isRememberMe = prefs.getBool('isRememberMe') ?? false;
			if (isRememberMe) {
				runBackgroundService();
			}
		});
	}

	void onInit(store) async {
		await askPermissions();
		// await ACRCloud.setUp(const ACRCloudConfig(accessKey, accessSecret, host));
	}

	Future<void> askPermissions() async {
		var status = await Permission.microphone.status;
		if ((status.isDenied || status.isPermanentlyDenied) && Platform.isAndroid) {
			await [Permission.microphone, Permission.location, Permission.locationAlways, Permission.locationWhenInUse, Permission.phone, Permission.storage,].request();
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
		if (_session != null) {
			if (Platform.isAndroid) {
				_session.destroy();
			}
			else {
				_session.cancel();
			}
		}
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
				playSound: false,
				visibility: NotificationVisibility.VISIBILITY_SECRET,
				buttons: [
					// const NotificationButton(id: 'sendButton', text: 'Send'),
					// const NotificationButton(id: 'testButton', text: 'Test'),
				],
			),
			iosNotificationOptions: const IOSNotificationOptions(
				showNotification: false,
			),
			foregroundTaskOptions: const ForegroundTaskOptions(
				interval: 60000,
				isOnceEvent: false,
				autoRunOnBoot: true,
				allowWakeLock: true,
				allowWifiLock: true,
			),
		);
	}

	Future<bool> _startForegroundTask() async {
		dynamic store;
		if (context.mounted) store = StoreProvider.of<AppState>(context);

		// You can save data using the saveData function.
		var prefs = await SharedPreferences.getInstance();
		await FlutterForegroundTask.saveData(key: 'user_id', value: prefs.getInt('userId') ?? 0);
		await FlutterForegroundTask.saveData(key: 'uuid', value: prefs.getString('uuid') ?? '');
		await FlutterForegroundTask.saveData(key: 'imei', value: prefs.getString('imei') ?? '');
		await FlutterForegroundTask.saveData(key: 'model', value: prefs.getString('model') ?? '');
		await FlutterForegroundTask.saveData(key: 'brand', value: prefs.getString('brand') ?? '');
		await FlutterForegroundTask.saveData(key: 'longitude', value: prefs.getString('longitude') ?? '');
		await FlutterForegroundTask.saveData(key: 'latitude', value: prefs.getString('latitude') ?? '');
		await FlutterForegroundTask.saveData(key: 'locationAddress', value: prefs.getString('locationAddress') ?? '');

		// Register the receivePort before starting the service.
		final ReceivePort? receivePort = FlutterForegroundTask.receivePort;
		final bool isRegistered = _registerReceivePort(receivePort);
		if (!isRegistered) {
			print('Failed to register receivePort!');
			return false;
		/// The above code is checking if a Flutter foreground service is already running. If it is running, it restarts the service. If it is not running, it starts the service with a notification title and text. It also specifies a callback function called "startCallback" to be executed when the service is started.
		}

		if (await FlutterForegroundTask.isRunningService) {
			return FlutterForegroundTask.restartService();
		} else {
			return FlutterForegroundTask.startService(
			notificationTitle: 'RadioMonitor è in esecuzione',
				notificationText: 'Tocca per tornare all\'applicazione',
				callback: startCallback,
			);
		}
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
		if (!ACRCloud.isSetUp) await ACRCloud.setUp(const ACRCloudConfig(accessKey, accessSecret, host));
		setState(() {
			_session = ACRCloud.startSession();
		});
		dynamic store;
		if (context.mounted) store = StoreProvider.of<AppState>(context);
		store.dispatch(SetRecordStatus(RecordStatus(isBackground: false, isRunning: true)));
		final result = await _session.result;
		if (result != null && context.mounted) ScaffoldMessenger.of(context).showSnackBar(ToasterMessage.showSuccessMessage(result.status.msg));
		await setResult(result);
		store.dispatch(SetRecordStatus(RecordStatus(isBackground: false, isRunning: false)));
	}

	void stopRecord() async {
		dynamic store;
		if (context.mounted) store = StoreProvider.of<AppState>(context);
		store.dispatch(SetRecordStatus(RecordStatus(isBackground: false, isRunning: false)));
		_session.cancel();
	}

	Future<void> setResult(ACRCloudResponse? result) async {
		dynamic store;
		if (context.mounted) store = StoreProvider.of<AppState>(context);
		
		if (result == null || result.status.code != 0) {
			store.dispatch(SetResult('NULL'));
			sendResult();
		} else {
			if (result.metadata!.customFiles.isNotEmpty) {
				dynamic customFile = result.metadata!.customFiles.first;
				store.dispatch(SetResult(customFile!.title));
				sendResult();
			}
			else if (result.metadata!.customStreams.isNotEmpty) {
				dynamic customStream = result.metadata!.customStreams.first;
				store.dispatch(SetResult(customStream!.title));
				sendResult();
			}
		}
	}

	Future<void> sendResult() async {
		dynamic store;
		if (context.mounted) store = StoreProvider.of<AppState>(context);
		var prefs = await SharedPreferences.getInstance();

		try {
			var response = (await http.post(Uri.parse('$serverBaseUrl/registerACRResult'), 
				headers: <String, String>{
					'Content-Type': 'application/json; charset=UTF-8'
				},
				body: jsonEncode(<String, dynamic>{
					'user_id': prefs.getInt('userId') ?? 0,
					'uuid': prefs.getString('uuid') ?? '',
					'imei': prefs.getString('imei') ?? '',
					'model': prefs.getString('model') ?? '',
					'brand': prefs.getString('brand') ?? '',
					'longitude': prefs.getString('longitude') ?? '',
					'latitude': prefs.getString('latitude') ?? '',
					'locationAddress': prefs.getString('locationAddress') ?? '',
					'acr_result': store.state.result.result,
					'duration': 10,
					'recorded_at': DateFormat('dd/MM/yyyy hh:mm').format(DateTime.now())
				})
			));
			var data = jsonDecode(response.body);
			if (data['status'] == 'success') {
			} else {
				print(data['comment']);
			}
		} catch (e) {
			print(e.toString());
		}
	}

	Future<bool> _stopForegroundTask() {
		return FlutterForegroundTask.stopService();
	}

	Future<void> sendAppState(String state) async {
		try {
			await _channel.invokeMethod('appState', state);
		} on PlatformException catch (e) {
			print('Error sending app state: $e');
		}
	}

	void stopRecordBackground() async {
		if (Platform.isIOS) {
			sendAppState('stopped');
		}
		await _stopForegroundTask();
		dynamic store;
		if (context.mounted) store = StoreProvider.of<AppState>(context);
		store.dispatch(SetRecordStatus(RecordStatus(isBackground: false, isRunning: false)));
	}

	void runBackgroundService() async {
		if (_session != null) {
			if (Platform.isAndroid) {
				_session.destroy();
			}
			else {
				_session.cancel();
			}
		}
		if (Platform.isIOS) {
			sendAppState('background');
		}

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
					builder: (context, state) => LayoutBuilder(
						builder: (BuildContext context, BoxConstraints viewportConstraints) {
							return SingleChildScrollView(
								child: ConstrainedBox(
									constraints: BoxConstraints(
										minHeight: viewportConstraints.maxHeight
									),
									child: IntrinsicHeight(
										child: InkWell(
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
																		children: [
																			Padding(
																				padding: const EdgeInsets.only(top: 30, bottom: 10),
																				child: Image.asset('assets/images/logo.jpg')
																			),
																			const Padding(
																				padding: EdgeInsets.only(bottom: 30),
																				child: Text(
																					'Tocca lo schermo due volte per avviare',
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
																!state.recordStatus.isRunning ? Container(width: 130, height: 130,) : state.recordStatus.isBackground ? StopRecBackBtn(onStop: stopRecordBackground,) : StopRecBtn(onStop: stopRecord,),
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
																	'Matching ${state.result.result}',
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
																	top: 180,
																	child: Row(
																		mainAxisAlignment: MainAxisAlignment.center,
																		mainAxisSize: MainAxisSize.min,
																		children: const [
																			Icon(Icons.warning_amber_outlined, size: 18, color: Colors.black,),
																			SizedBox(width: 5,),
																			Text(
																				'BACKGROUND MODE ON',
																				style: TextStyle(
																					fontFamily: 'Futura',
																					fontSize: 17,
																					color: Colors.black,
																					fontWeight: FontWeight.w400
																				),
																			)
																		],
																	)
																)
															: Positioned(
																top: 180,
																child: Row(
																	mainAxisAlignment: MainAxisAlignment.center,
																	mainAxisSize: MainAxisSize.min,
																	children: const [
																		Icon(Icons.warning_amber_outlined, size: 18, color: Colors.black,),
																		SizedBox(width: 5,),
																		Text(
																			'FOREGROUND MODE ON',
																			style: TextStyle(
																				fontFamily: 'Futura',
																				fontSize: 17,
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
										)
									),
								),
							);
						}
					),
				),
			)
		);
	}
}

class AudioMonitorTaskHandler extends TaskHandler {
	SendPort? _sendPort;
	int _eventCount = 0;
	dynamic _session;
	dynamic _acrResult;
	int _userId = 0;
	String _uuid = '';
	String _imei = '';
	String _model = '';
	String _brand = '';
	String _longitude = '';
	String _latitude = '';
	String _locationAddress = '';
	PhoneStateStatus status = PhoneStateStatus.NOTHING;
	late MethodChannel _currentAppChannel;

	@override
	void onStart(DateTime timestamp, SendPort? sendPort) async {
		print('onStart');
		_sendPort = sendPort;
		_currentAppChannel = const MethodChannel('RunningApp');
		await askPermissions();
		AudioSession.instance.then((audioSession) async {
			await audioSession.configure(const AudioSessionConfiguration(
				avAudioSessionCategory: AVAudioSessionCategory.playAndRecord,
				avAudioSessionCategoryOptions: AVAudioSessionCategoryOptions.mixWithOthers,
				avAudioSessionMode: AVAudioSessionMode.spokenAudio,
				avAudioSessionRouteSharingPolicy: AVAudioSessionRouteSharingPolicy.defaultPolicy,
				avAudioSessionSetActiveOptions: AVAudioSessionSetActiveOptions.none,
				androidAudioAttributes: AndroidAudioAttributes(
					contentType: AndroidAudioContentType.speech,
					flags: AndroidAudioFlags.none,
					usage: AndroidAudioUsage.voiceCommunication
				),
				androidAudioFocusGainType: AndroidAudioFocusGainType.gain,
				androidWillPauseWhenDucked: true
			));

			_handleInterruptions(audioSession);
		});
		setStream();
		_userId = await FlutterForegroundTask.getData<int>(key: 'user_id') ?? 0;
		_uuid = await FlutterForegroundTask.getData<String>(key: 'uuid') ?? '';
		_imei = await FlutterForegroundTask.getData<String>(key: 'imei') ?? '';
		_model = await FlutterForegroundTask.getData<String>(key: 'model') ?? '';
		_brand = await FlutterForegroundTask.getData<String>(key: 'brand') ?? '';
		_longitude = await FlutterForegroundTask.getData<String>(key: 'longitude') ?? '';
		_latitude = await FlutterForegroundTask.getData<String>(key: 'latitude') ?? '';
		_locationAddress = await FlutterForegroundTask.getData<String>(key: 'locationAddress') ?? '';
		await requestPhonePermission();

	}

	@override
	void onRepeatEvent(DateTime timestamp, SendPort? sendPort) async {
		print('onRepeatEvent');
		print('phone status: $status');
		if (status == PhoneStateStatus.CALL_INCOMING || status == PhoneStateStatus.CALL_STARTED) return;
		print('after checking phone status');
		if (status == PhoneStateStatus.CALL_ENDED) {
			// Do something to reactive recording like on iOS
		}
		
		await ACRCloud.setUp(const ACRCloudConfig(accessKey, accessSecret, host));
		_session = ACRCloud.startSession();
		_acrResult = await _session.result;
    var errorStatus = 0;
    if (_acrResult.status.code == 2004) {        
      //problem with fp generation ACR on Android 
       print("TRY TO FIX PROBLEM AFTER CALL");          
       // FlutterForegroundTask.stopService();

       errorStatus = 1;  
       if (await FlutterForegroundTask.isRunningService) {
          print ("isRunning restart service");
          await ACRCloud.setUp(const ACRCloudConfig(accessKey, accessSecret, host));
          _session = ACRCloud.startSession();
          _acrResult = await _session.destroy;
  
          if (await FlutterForegroundTask.restartService()){
            print ("SERVICE RESTARTED");
            return;
          }
        } else {
          print ("isNOTRunning start service");
          FlutterForegroundTask.startService(
          notificationTitle: 'RadioMonitor è di nuovo in esecuzione',
            notificationText: 'Tocca per tornare all\'applicazione',
            callback: startCallback,
          );
        }
    }
		String result = '';
		if (_eventCount % 5 == 0) {
			print('get location');
			final location = await _getCurrentPosition();
			if (location != null) {
				_longitude = location.longitude.toString();
				_latitude = location.latitude.toString();
				print('longitude: ${_longitude}');
				print('latitude: ${_latitude}');
				_locationAddress = await _getAddressFromLatLng(location);
			}
		}
		if (_acrResult == null || _acrResult.metadata == null) {
			result = 'NULL';
		} else {
			if (_acrResult.metadata!.customFiles.isNotEmpty) {
				dynamic customFile = _acrResult.metadata!.customFiles.first;
				result = customFile!.title;
			}
			else if (_acrResult.metadata!.customStreams.isNotEmpty) {
				dynamic customStream = _acrResult.metadata!.customStreams.first;
				result = customStream!.title;
			}
		}
		FlutterForegroundTask.updateService(
			notificationText: 'result: $result',
			notificationTitle: 'AudioMonitor'
		);
		// try {
		// 	final String result = await _currentAppChannel.invokeMethod('getRunningApps');
		// 	print('Result from Channel: $result');
		// } on PlatformException catch (e) {
		// 	print('Error: ${e.message}');
		// }
		
	  if ((result != '')&&(errorStatus == 0)) sendResult(result);
 
		sendPort?.send(_eventCount);
		_eventCount ++;
	}

	@override
	void onDestroy(DateTime timestamp, SendPort? sendPort) async {
		print(sendPort.hashCode);
		if (Platform.isAndroid) {
				_session.destroy();
			}
			else {
				_session.cancel();
			}
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

	void _handleInterruptions(AudioSession audioSession) {
		audioSession.interruptionEventStream.listen((event) {
			if (event.begin) {
				switch (event.type) {
					case AudioInterruptionType.duck:
						print('interruption begin => audio is duck');
						break;
					case AudioInterruptionType.pause:
						print('interruption begin => audio is paused');
						break;
					case AudioInterruptionType.unknown:
						print('interruption begin => unknown interruption');
						break;
				}
			} else {
				audioSession.setActive(true);
				switch (event.type) {
					case AudioInterruptionType.duck:
						print('interruption end => audio is duck');
						break;
					case AudioInterruptionType.pause:
						print('interruption end => audio is paused');
						break;
					case AudioInterruptionType.unknown:
						print('interruption end => unknown interruption');
						break;
				}
			}
		});
	}

	Future<void> sendResult(result) async {
		try {
			var response = (await http.post(Uri.parse('$serverBaseUrl/registerACRResult'), 
				headers: <String, String>{
					'Content-Type': 'application/json; charset=UTF-8'
				},
				body: jsonEncode(<String, dynamic>{
					'user_id': _userId,
					'uuid': _uuid,
					'imei': _imei,
					'model': _model,
					'brand': _brand,
					'longitude': _longitude,
					'latitude': _latitude,
					'locationAddress': _locationAddress,
					'acr_result': result,
					'duration': 10,
					'recorded_at': DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())
				})
			));
			var data = jsonDecode(response.body);
			if (data['status'] == 'success') {
			} else {
				print(data['comment']);
			}
		} catch (e) {
			print(e.toString());
		}
	}

	Future<void> askPermissions() async {
		var status = await Permission.microphone.status;
		if ((status.isDenied || status.isPermanentlyDenied) && Platform.isAndroid) {
			await [Permission.microphone, Permission.location, Permission.locationAlways, Permission.locationWhenInUse, Permission.phone, Permission.storage,].request();
		}
	}

	Future<bool> requestPhonePermission() async {
		var status = await Permission.phone.request();

		switch (status) {
			case PermissionStatus.denied:
			case PermissionStatus.restricted:
			case PermissionStatus.limited:
			case PermissionStatus.permanentlyDenied:
				return false;
			case PermissionStatus.provisional:
			case PermissionStatus.granted:
				return true;
		}
	}

	void setStream() {
		PhoneState.phoneStateStream.listen((event) {
			if (event != null) {
				print('call status');
				print(event);
				status = event;
			}
		});
	}

	Future<bool> _handleLocationPermission() async {
		bool serviceEnabled;
		LocationPermission permission;
		
		serviceEnabled = await Geolocator.isLocationServiceEnabled();
		if (!serviceEnabled) {
			return false;
		}
		permission = await Geolocator.checkPermission();
		if (permission == LocationPermission.denied) {
			permission = await Geolocator.requestPermission();
			if (permission == LocationPermission.denied) {   
				return false;
			}
		}
		if (permission == LocationPermission.deniedForever) {
			return false;
		}
		return true;
	}

	Future<String> _getAddressFromLatLng(Position position) async {
		if (position == null) return '';
		try {
			List<Placemark> placeMarks = await placemarkFromCoordinates(position.latitude, position.longitude);
			Placemark place = placeMarks[0];
			return '${place.street}, ${place.subLocality}, ${place.subAdministrativeArea}, ${place.postalCode}';
		} catch (e) {
			print(e);
			return '';
		}
	}

	Future<Position?> _getCurrentPosition() async {
		final hasPermission = await _handleLocationPermission();
		if (!hasPermission) return null;
		try {
			final position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
			return position;
		} catch (e) {
			print(e);
			return null;
		}
	}
}