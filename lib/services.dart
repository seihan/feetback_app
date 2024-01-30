import 'package:feet_back_app/global_params.dart';
import 'package:feet_back_app/models/bluetooth_connection_model.dart';
import 'package:feet_back_app/models/permission_model.dart';
import 'package:get_it/get_it.dart';

import 'models/record_model.dart';

GetIt services = GetIt.instance;

Future<void> setupServices() async {
  // global navigation
  services.registerSingletonAsync<GlobalParams>(
    () => GlobalParams().init(),
  );
  // permission handler
  services.registerSingletonAsync<PermissionModel>(
    () => PermissionModel().init(),
  );
  // ble model
  services.registerSingletonWithDependencies<BluetoothConnectionModel>(
      () => BluetoothConnectionModel().init(),
      dependsOn: [GlobalParams]);
  // record model
  services.registerLazySingleton<RecordModel>(() => RecordModel());
}
