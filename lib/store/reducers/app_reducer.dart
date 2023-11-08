import 'package:audio_monitor/models/app_state.dart';
import 'package:audio_monitor/store/reducers/device_info_reducer.dart';
import 'package:audio_monitor/store/reducers/record_status_reducer.dart';
import 'package:audio_monitor/store/reducers/result_reducer.dart';
import 'package:audio_monitor/store/reducers/user_reducer.dart';

AppState appReducer(AppState state, dynamic action) {
	return AppState(
		recordStatus: recordStatusReducer(state.recordStatus, action),
		result: resultReducer(state.result, action),
		deviceInfo: deviceInfoReducer(state.deviceInfo, action),
		user: userReducer(state.user, action)
	);
}