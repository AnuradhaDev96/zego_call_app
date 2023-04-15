import 'package:get_it/get_it.dart';

import '../change_notifiers/call_state_change_notifier.dart';

void injectDependencies() {
  GetIt.I.registerLazySingleton(() => CallStateChangeNotifier());
}