import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:sweaden_old_new_version/modules/review_request/widgets/media%20form/models/media_storage.dart';
// import 'package:sweaden_old_new_version/shared/widgets/media%20form/models/media_storage.dart';

class MediaDataStorage {
  final storage = const FlutterSecureStorage();

  Future<List<MediaStorage>?> getMediaData(int idRequest) async {
    final data = await storage.read(key: 'mediaData_$idRequest');
    // print(data);
    if (data != null) {
      List<MediaStorage> response = mediaStorageFromJson(data);
      return response;
    }
    return null;
  }

  void setMediaData(int idRequest, List<MediaStorage> mediaData) async {
    
    final data = mediaStorageToJson(mediaData);
    
    await storage.write(key: 'mediaData_$idRequest', value: data);
  }

  Future<void> removeMediaData(int idRequest) async {
    final media = await getMediaData(idRequest);
    for (var item in media!) {
      if (item.path != null) {
        var exist = await File(item.path!).exists();
        if(exist){
          await File(item.path!).delete();
        }
      }
    }
    await storage.delete(key: 'mediaData_$idRequest');
  }

  Future<void> removeAll() async {
    await storage.deleteAll();
  }
}
