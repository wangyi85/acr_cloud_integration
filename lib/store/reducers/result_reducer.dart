import 'package:audio_monitor/models/models.dart';
import 'package:audio_monitor/store/actions/result_action.dart';

Result resultReducer(Result state, dynamic action) {
	if (action is SetResult) {
		state.result = action.result;
		return state;
	}
	return state;
}