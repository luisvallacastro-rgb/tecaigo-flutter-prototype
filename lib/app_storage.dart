import 'app_storage_stub.dart'
    if (dart.library.html) 'app_storage_web.dart' as storage;

String? storageRead(String key) => storage.storageRead(key);

void storageWrite(String key, String value) => storage.storageWrite(key, value);
