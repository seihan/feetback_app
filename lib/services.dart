import 'package:feet_back_app/global_params.dart';
import 'package:feet_back_app/models/bluetooth_connection_model.dart';
import 'package:feet_back_app/models/device_id_model.dart';
import 'package:feet_back_app/models/permission_model.dart';
import 'package:feet_back_app/models/sensor_device_selector.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'models/record_model.dart';

GetIt services = GetIt.instance;

Future<void> setupServices() async {
  // global navigation (dialogs)
  services.registerSingletonAsync<GlobalParams>(
    () => GlobalParams().init(),
  );
  // permission handler
  services.registerSingletonAsync<PermissionModel>(
    () => PermissionModel().init(),
  );
  // shared preferences
  services.registerSingletonAsync<SharedPreferences>(
    () => SharedPreferences.getInstance(),
  );
  // device ids
  services.registerSingletonWithDependencies<DeviceIdModel>(
      () => DeviceIdModel(),
      dependsOn: [SharedPreferences]);
  // sensor devices
  services.registerSingletonWithDependencies<SensorDeviceSelector>(
      () => SensorDeviceSelector(),
      dependsOn: [DeviceIdModel]);
  // ble model
  services.registerSingletonWithDependencies<BluetoothConnectionModel>(
      () => BluetoothConnectionModel().init(),
      dependsOn: [GlobalParams, SensorDeviceSelector]);
  // record model
  services.registerLazySingleton<RecordModel>(
    () => RecordModel(),
  );
}
