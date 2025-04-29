import 'dart:developer';

import 'package:background_locator_2/location_dto.dart';

class LocationCallbackHandler {

  @pragma('vm:entry-point')
  static void callback(LocationDto locationDto) async {
    print("callback 실행");

    log("callback 실행: ${locationDto.latitude}, ${locationDto.longitude}");
  }

//Optional
  @pragma('vm:entry-point')
  static void initCallback(dynamic _) {
    print('Plugin initialization');
  }

//Optional
  @pragma('vm:entry-point')
  static void notificationCallback() {
    print('User clicked on the notification');
  }
}
