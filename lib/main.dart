import 'dart:async';
import 'dart:io';

import 'package:audio_monitor/models/app_state.dart';
import 'package:audio_monitor/models/models.dart';
import 'package:audio_monitor/pages/splash.dart';
import 'package:audio_monitor/store/reducers/app_reducer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/foundation.dart';

int id = 0;

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

final StreamController<ReceivedNotification> didReceiveLocalNotificationStream = StreamController<ReceivedNotification>.broadcast();

final StreamController<String?> selectNotificationStream = StreamController<String?>.broadcast();

const MethodChannel platform = MethodChannel('dexterx.dev/flutter_local_notifications_example');

const String portName = 'notification_send_port';

class ReceivedNotification {
	ReceivedNotification({
		required this.id,
		required this.title,
		required this.body,
		required this.payload,
	});

	final int id;
	final String? title;
	final String? body;
	final String? payload;
}

String? selectedNotificationPayload;

const String urlLaunchActionId = 'id_1';

const String navigationActionId = 'id_3';

const String darwinNotificationCategoryText = 'textCategory';

const String darwinNotificationCategoryPlain = 'plainCategory';

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
	// ignore: avoid_print
	print('notification(${notificationResponse.id}) action tapped: '
		'${notificationResponse.actionId} with'
		' payload: ${notificationResponse.payload}'
	);
	if (notificationResponse.input?.isNotEmpty ?? false) {
		// ignore: avoid_print
		print('notification action tapped with input: ${notificationResponse.input}');
	}
}

Future<void> _configureLocalTimeZone() async {
	if (kIsWeb || Platform.isLinux) {
		return;
	}
	tz.initializeTimeZones();
	final String? timeZoneName = await FlutterTimezone.getLocalTimezone();
	tz.setLocalLocation(tz.getLocation(timeZoneName!));
}
Future<void> main() async {
	HttpOverrides.global = MyHttpOverrides();
	final store = Store<AppState>(appReducer, initialState: AppState(
		recordStatus: RecordStatus(isBackground: false, isRunning: false),
		result: Result(''),
		deviceInfo: DeviceInfo(uuid: '', imei: '', model: '', brand: ''),
		user: User(id: 0, name: '', lastName: '', email: '', gender: '')
	));
	WidgetsFlutterBinding.ensureInitialized();

	await _configureLocalTimeZone();
	final NotificationAppLaunchDetails? notificationAppLaunchDetails = !kIsWeb && Platform.isLinux
		? null
		: await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
	const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
	final List<DarwinNotificationCategory> darwinNotificationCategories = <DarwinNotificationCategory>[
		DarwinNotificationCategory(
			darwinNotificationCategoryText,
			actions: <DarwinNotificationAction>[
				DarwinNotificationAction.text(
					'text_1',
					'Action 1',
					buttonTitle: 'Send',
					placeholder: 'Placeholder',
					),
				],
		),
		DarwinNotificationCategory(
			darwinNotificationCategoryPlain,
			actions: <DarwinNotificationAction>[
				DarwinNotificationAction.plain('id_1', 'Action 1'),
				DarwinNotificationAction.plain(
				'id_2',
				'Action 2 (destructive)',
				options: <DarwinNotificationActionOption>{
					DarwinNotificationActionOption.destructive,
				},
				),
				DarwinNotificationAction.plain(
				navigationActionId,
				'Action 3 (foreground)',
				options: <DarwinNotificationActionOption>{
					DarwinNotificationActionOption.foreground,
				},
				),
				DarwinNotificationAction.plain(
				'id_4',
				'Action 4 (auth required)',
				options: <DarwinNotificationActionOption>{
					DarwinNotificationActionOption.authenticationRequired,
				},
				),
			],
			options: <DarwinNotificationCategoryOption>{
				DarwinNotificationCategoryOption.hiddenPreviewShowTitle,
			},
		)
	];
	final DarwinInitializationSettings initializationSettingsDarwin = DarwinInitializationSettings(
		requestAlertPermission: false,
		requestBadgePermission: false,
		requestSoundPermission: false,
		onDidReceiveLocalNotification: (int id, String? title, String? body, String? payload) async {
			didReceiveLocalNotificationStream.add(
				ReceivedNotification(
				id: id,
				title: title,
				body: body,
				payload: payload,
				),
			);
		},
		notificationCategories: darwinNotificationCategories,
	);
	final LinuxInitializationSettings initializationSettingsLinux = LinuxInitializationSettings(
		defaultActionName: 'Open notification',
		defaultIcon: AssetsLinuxIcon('icons/app_icon.png'),
	);
	final InitializationSettings initializationSettings = InitializationSettings(
		android: initializationSettingsAndroid,
		iOS: initializationSettingsDarwin,
		macOS: initializationSettingsDarwin,
		linux: initializationSettingsLinux,
	);
	await flutterLocalNotificationsPlugin.initialize(
		initializationSettings,
		onDidReceiveNotificationResponse: (NotificationResponse notificationResponse) {
			switch (notificationResponse.notificationResponseType) {
				case NotificationResponseType.selectedNotification:
					selectNotificationStream.add(notificationResponse.payload);
					break;
				case NotificationResponseType.selectedNotificationAction:
					if (notificationResponse.actionId == navigationActionId) {
						selectNotificationStream.add(notificationResponse.payload);
					}
					break;
			}
		},
		onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
	);
	await _isAndroidPermissionGranted();
	await _requestPermissions();
	_configureDidReceiveLocalNotificationSubject();
	_configureSelectNotificationSubject();
	await _scheduleDailyTenAMNotification();
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

tz.TZDateTime _nextInstanceOfTenAM() {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, 10);
    if (scheduledDate.isBefore(now)) {
      	scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
}

Future<void> _isAndroidPermissionGranted() async {
    if (Platform.isAndroid) {
      	final bool granted = await flutterLocalNotificationsPlugin
			.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
			?.areNotificationsEnabled() ??
		false;
    }
}

Future<void> _requestPermissions() async {
    if (Platform.isIOS || Platform.isMacOS) {
		await flutterLocalNotificationsPlugin
			.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
			?.requestPermissions(
				alert: true,
				badge: true,
				sound: true,
			);
		await flutterLocalNotificationsPlugin
			.resolvePlatformSpecificImplementation<MacOSFlutterLocalNotificationsPlugin>()
			?.requestPermissions(
				alert: true,
				badge: true,
				sound: true,
			);
		} else if (Platform.isAndroid) {
		final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
			flutterLocalNotificationsPlugin
				.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

		final bool? grantedNotificationPermission =
			await androidImplementation?.requestNotificationsPermission();
    }
}

void _configureDidReceiveLocalNotificationSubject() {
    didReceiveLocalNotificationStream.stream
        .listen((ReceivedNotification receivedNotification) async {
		// Do something here when receiving notification
    });
}

void _configureSelectNotificationSubject() {
    selectNotificationStream.stream.listen((String? payload) async {
		// Do something here when receiving notification
    });
}

Future<void> _scheduleDailyTenAMNotification() async {
    await flutterLocalNotificationsPlugin.zonedSchedule(
        0,
        'audio_monitor',
        'Please tap to run audio_monitor',
        _nextInstanceOfTenAM(),
        const NotificationDetails(
          	android: AndroidNotificationDetails(
				'audio_monitor_channel_id', 'audio_monitor_channel_name',
				channelDescription: 'For running audio_monitor if it is closed'),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time
	);
}
