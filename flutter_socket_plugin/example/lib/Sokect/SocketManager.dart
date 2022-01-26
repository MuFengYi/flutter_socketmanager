import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

// import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_socket_plugin/flutter_socket_plugin.dart';

import 'SocketListener.dart';

class SocketManager {
  late FlutterSocket mSocket;
  bool isConnnect = false;

  late Timer connectTimer;
  bool isKaiJi = false;

  // 单例模式
  static final SocketManager _instance = SocketManager._internal();
  factory SocketManager() => _instance;
  SocketManager._internal() {
    init();
  }
  init() {}

  //socket 发送数据
  void writeDataqqqqqqqqqqqq(String data) {
    // print("socket发送的数据是=====" + data.toString());
    mSocket.send(data);
  }

  //连接服务器
  Future<bool> connectServerWith(
      String host,
      String port,
      String extraData,
      String extraData1,
      SocketDataResponseListener socketDataResponseListener,
      bool isOpenData) async {
    mSocket = FlutterSocket();

    /// listen receive callback
    mSocket.receiveListener((data) {
      if (socketDataResponseListener != null) {
        socketDataResponseListener.dioResponseSocketData(1, data);
      }
    });

    /// listen disconnect callback
    mSocket.disconnectListener((data) {
      if (data == "disconnnected") {
        isConnnect = false;
        if (SocketManager().isKaiJi = true) {
          mSocket.tryConnect();
        }
      }
      print("disconnect listener data:$data");
    });
    mSocket.connectListener((data) {
      print("connect listener data:$data");
      if (data == "connected") {
        isConnnect = true;
        if (isOpenData == true) {
        } else {
          isKaiJi = true;
        }
      }
    });
    //
    mSocket.createSocket('localhost', 8080, timeout: 20);
    mSocket.tryConnect();
    return true;
  }
}
