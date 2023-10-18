import 'dart:convert';
import 'dart:io';

import 'package:audio_monitor/models/app_state.dart';
import 'package:audio_monitor/models/models.dart';
import 'package:audio_monitor/pages/setting.dart';
import 'package:audio_monitor/pages/source.dart';
import 'package:audio_monitor/store/actions/record_status_action.dart';
import 'package:audio_monitor/widgets/bottombar.dart';
import 'package:audio_monitor/widgets/start_rec_btn.dart';
import 'package:audio_monitor/widgets/stop_rec_back_btn.dart';
import 'package:audio_monitor/widgets/stop_rec_btn.dart';
import 'package:flutter/material.dart';
import 'package:audio_monitor/utils/consts.dart';
import 'package:flutter_acrcloud/flutter_acrcloud.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:permission_handler/permission_handler.dart';

class Home extends StatefulWidget {
	Home({super.key});

	@override
	_HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
	String _result = '';

	void onInit(store) async {
		await askPermissions();
		ACRCloud.setUp(const ACRCloudConfig(accessKey, accessSecret, host));
	}

	Future<void> askPermissions() async {
		var status = await Permission.microphone.status;
		if ((status.isDenied || status.isPermanentlyDenied) && Platform.isAndroid) {
			await [Permission.microphone, Permission.location, Permission.locationAlways, Permission.locationWhenInUse, Permission.phone, Permission.storage].request();
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
		print('startRecord');
		final session = ACRCloud.startSession();
		dynamic store;
		if (context.mounted) store = StoreProvider.of<AppState>(context);
		store.dispatch(SetRecordStatus(RecordStatus(isBackground: false, isRunning: true)));
		showDialog(
			context: context,
			barrierDismissible: false,
			builder: (context) => AlertDialog(
				title: Text('Listening...'),
				content: StreamBuilder(
					stream: session.volumeStream,
					initialData: 0.0,
					builder: (_, snapshot) =>
						Text(snapshot.data.toString()),
				),
				actions: [
					TextButton(
					child: Text('Cancel'),
					onPressed: () => stopRecord(session),
					)
				],
			),
		);
	}

	void stopRecord(ACRCloudSession session) async {
		dynamic store;
		if (context.mounted) store = StoreProvider.of<AppState>(context);
		store.dispatch(SetRecordStatus(RecordStatus(isBackground: false, isRunning: false)));
		session.cancel;
		if (context.mounted) Navigator.pop(context);
		final result = await session.result;
		setState(() {
			_result = result!.status.msg;
		});
	}

	void stopRecordBackground() async {
		dynamic store;
		if (context.mounted) store = StoreProvider.of<AppState>(context);
		store.dispatch(SetRecordStatus(RecordStatus(isBackground: false, isRunning: false)));
	}

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			bottomNavigationBar: BottomBar(onTap: onNavigate, currentIndex: 0),
			body: StoreConnector<AppState, AppState>(
				onInit: (store) => onInit(store),
				converter: (store) => store.state,
				builder: (context, state) => Container(
					width: double.infinity,
					height: double.infinity,
					padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
					color: Colors.white,
					child: Column(
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
							!state.recordStatus.isRunning ? StartRecBtn(onRecord: startRecord,) : state.recordStatus.isBackground ? StopRecBackBtn(onStop: stopRecord,) : StopRecBtn(onStop: stopRecordBackground,),
							const SizedBox(height: 15,),
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
				),
			),
		);
	}
}