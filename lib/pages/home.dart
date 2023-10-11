import 'package:acr_cloud_sdk/acr_cloud_sdk.dart';
import 'package:audio_monitor/pages/setting.dart';
import 'package:audio_monitor/pages/source.dart';
import 'package:audio_monitor/widgets/bottombar.dart';
import 'package:audio_monitor/widgets/start_rec_btn.dart';
import 'package:flutter/material.dart';
import 'package:audio_monitor/utils/consts.dart';

class Home extends StatefulWidget {
	Home({super.key});

	@override
	_HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
	final AcrCloudSdk arc = AcrCloudSdk();
	@override
	void initState() {
		super.initState();
		arc..init(host: host, accessKey: accessKey, accessSecret: accessSecret, setLog: false)..songModelStream.listen(searchSong);
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
		bool started = await arc.start();
		print(started);
	}
	void searchSong(SongModel song) async {
		print(song);
	}
	@override
	Widget build(BuildContext context) {
		return Scaffold(
			bottomNavigationBar: BottomBar(onTap: onNavigate, currentIndex: 0),
			body: Container(
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
						StartRecBtn(onRecord: startRecord,)
					],
				),
			),
		);
	}
}