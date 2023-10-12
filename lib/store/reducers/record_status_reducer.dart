import 'package:audio_monitor/models/models.dart';
import 'package:audio_monitor/store/actions/record_status_action.dart';

RecordStatus recordStatusReducer(RecordStatus state, dynamic action) {
	if (action is SetRecordStatus) {
		state.isBackground = action.recordStatus.isBackground;
		state.isRunning = action.recordStatus.isRunning;
		return state;
	}
	return state;
}