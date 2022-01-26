//网络请求返回监听
abstract class DioResponseListener {
  //当做接口   接口：就是约定 、规范
  dioResponse(String tag, Map<String, dynamic> data);
}

abstract class BlueDataResponseListener {
  //当做接口   接口：就是约定 、规范
  dioResponseBlueData(int tag, List<dynamic> list);
}

abstract class SocketDataResponseListener {
  //当做接口   接口：就是约定 、规范
  dioResponseSocketData(int tag, String data);
}

abstract class BlueStateResponseListener {
  //当做接口   接口：就是约定 、规范
  dioResponseBlueState(int tag, List<int> list);
}
