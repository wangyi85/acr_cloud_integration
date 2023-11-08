import 'package:meta/meta.dart';
import 'models.dart';

@immutable
class AppState {
	final RecordStatus recordStatus;
	final Result result;
	final DeviceInfo deviceInfo;
	final User user;

	const AppState({
		required this.recordStatus,
		required this.result,
		required this.deviceInfo,
		required this.user
	});
}