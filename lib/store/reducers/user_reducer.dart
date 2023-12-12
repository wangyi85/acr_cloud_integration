import 'package:audio_monitor/models/models.dart';
import 'package:audio_monitor/store/actions/user_action.dart';

User userReducer(User state, dynamic action) {
	if (action is SetUser) {
		state.id = action.user.id;
		state.email = action.user.email;
		state.gender = action.user.gender;
		state.homeAddress = action.user.homeAddress;
		return state;
	}
	return state;
}