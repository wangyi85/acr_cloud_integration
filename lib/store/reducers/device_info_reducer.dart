import 'package:audio_monitor/models/models.dart';
import 'package:audio_monitor/store/actions/device_info_action.dart';

DeviceInfo deviceInfoReducer(DeviceInfo state, dynamic action) {
	if (action is SetIMEI) {
		state.imei = action.imei;
		return state;
	}
	else if (action is SetUUID) {
		state.uuid = action.uuid;
		return state;
	}
	else if (action is SetDeviceModel) {
		state.model = action.model;
		return state;
	}
	else if (action is SetBrand) {
		state.brand = action.brand;
		return state;
	}
	return state;
}