// location_callback_handler.dart
import 'package:background_locator_2/location_dto.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart'; // @pragma 사용을 위해 import

class LocationCallbackHandler{

  static Future<void> callback(LocationDto locationDto) async {
    print( locationDto );
    print(">> 백그라운드 콜백 함수 실행됨");
  }
}
