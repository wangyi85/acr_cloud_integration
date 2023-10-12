import 'package:audio_monitor/models/app_state.dart';
import 'package:audio_monitor/store/reducers/record_status_reducer.dart';

AppState appReducer(AppState state, dynamic action) {
	return AppState(
		recordStatus: recordStatusReducer(state.recordStatus, action)
	);
}