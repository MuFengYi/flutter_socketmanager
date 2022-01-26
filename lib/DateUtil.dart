import 'package:intl/intl.dart';

//Todo 日期工具类
class DateUtil {
  static DateUtil? _instance; //唯一单例, _代表类私有,禁止外部直接访问
  factory DateUtil() => _getInstance(); //使用工厂构造方法，DateUtil()获取类时，返回唯一实例
  static DateUtil? get instance => _getInstance(); //通过静态变量instance获取实例

  static DateUtil _getInstance() {
    //这里真正生成唯一实例
    if (_instance == null) {
      _instance = DateUtil._internal(); //命名构造函数初始化唯一实例
    }
    return _instance!;
  }

  DateUtil._internal() {
    //命名构造函数
    //初始化
  }

  //Todo 获取当前时间戳
  int currentTimeMillis() {
    int currentTimeMillis = new DateTime.now().millisecondsSinceEpoch;
    print("currentTimeMillis----------" + currentTimeMillis.toString());
    return currentTimeMillis;
  } //Todo 获取当前时间戳

  String currentTime({format = "HH:mm"}) {
    int currentTimeMillis = new DateTime.now().millisecondsSinceEpoch;
    var DateFormart = new DateFormat(format);
    var dateTime = new DateTime.fromMillisecondsSinceEpoch(currentTimeMillis);
    String formartResult = DateFormart.format(dateTime);
    return formartResult;
  }

  //Todo 时间戳转化为日期  timeSamp:毫秒值  yyyy年MM月
  String getFormartDate3(int timeSamp, {format = "yyyy年MM月"}) {
    var DateFormart = new DateFormat(format);
    var dateTime = new DateTime.fromMillisecondsSinceEpoch(timeSamp);
    String formartResult = DateFormart.format(dateTime);
    return formartResult;
  }

  //Todo 时间戳转化为日期  timeSamp:毫秒值  yyyy年MM月dd hh:mm:ss
  String getFormartDate(int timeSamp, {format = "yyyy年MM月dd日"}) {
    var DateFormart = new DateFormat(format);
    var dateTime = new DateTime.fromMillisecondsSinceEpoch(timeSamp);
    String formartResult = DateFormart.format(dateTime);
    return formartResult;
  }

  //Todo 时间戳转化为日期  timeSamp:毫秒值  yyyy年MM月dd hh:mm:ss  这里要注意的是 小时分钟是用的HH:mm
  //Todo H大写代表24小时制
  //Todo 如果改成hh:mm 则是12小时制
  String getFormartDate2(int timeSamp, {format = "yyyy年MM月dd日 HH:mm:ss"}) {
    var DateFormart = new DateFormat(format);
    //timestamp 为毫秒时间戳
    var dateTime = new DateTime.fromMillisecondsSinceEpoch(timeSamp);
    String formartResult = DateFormart.format(dateTime);
    return formartResult;
  }

  //Todo 获取当前日期时间
  String getCurrentDate({format = "yyyy年MM月dd HH:mm:ss"}) {
    var now = new DateTime.now();
    var formatter = new DateFormat(format);
    String formatted = formatter.format(now);
    return formatted;
  }

  //Todo 获取当前日期时间
  String getCurrentDateYue({format = "yyyy-MM"}) {
    var now = new DateTime.now();
    var formatter = new DateFormat(format);
    String formatted = formatter.format(now);
    return formatted;
  }

//Todo 时间戳转化为日期  timeSamp:毫秒值  yyyy-MM
  String getFormartDateaa(int timeSamp, {format = "yyyy-MM"}) {
    var DateFormart = new DateFormat(format);
    var dateTime = new DateTime.fromMillisecondsSinceEpoch(timeSamp);
    String formartResult = DateFormart.format(dateTime);
    return formartResult;
  }

  //Todo 时间戳转化为日期 format
  String getCurrentDateFormat(String format) {
    var now = new DateTime.now().toUtc();
    var formatter = new DateFormat(format);
    String formartResult = formatter.format(now);
    return formartResult;
  }

  //Todo 时间戳转化为日期 timeSamp:毫毫秒值秒 format
  String getDateFormat(int timeSamp, String format) {
    var DateFormart = new DateFormat(format);
    var dateTime = new DateTime.fromMillisecondsSinceEpoch(timeSamp);
    String formartResult = DateFormart.format(dateTime);
    return formartResult;
  }
}
