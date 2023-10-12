import 'package:meta/meta.dart';
import 'models.dart';

@immutable
class AppState {
	final RecordStatus recordStatus;

	const AppState({
		required this.recordStatus
	});
}