package cn.waitwalker.flutter_socket_plugin.jt808_sdk.sdk;

import android.app.Application;
import android.os.Handler;
import android.os.Looper;
import android.text.TextUtils;

import cn.waitwalker.flutter_socket_plugin.jt808_sdk.oksocket.client.sdk.OkSocket;
import cn.waitwalker.flutter_socket_plugin.jt808_sdk.sdk.exceptions.SocketManagerException;
import cn.waitwalker.flutter_socket_plugin.jt808_sdk.sdk.interfaces.OnGetResetDeviceList;
import cn.waitwalker.flutter_socket_plugin.jt808_sdk.sdk.interfaces.SocketActionListener;
import cn.waitwalker.flutter_socket_plugin.jt808_sdk.sdk.interfaces.SocketPulseListener;
import cn.waitwalker.flutter_socket_plugin.jt808_sdk.sdk.interfaces.StartLocationBackList;
import cn.waitwalker.flutter_socket_plugin.jt808_sdk.sdk.jt808bean.Generate808andSeqBean;
import cn.waitwalker.flutter_socket_plugin.jt808_sdk.sdk.jt808bean.JTT808Bean;
import cn.waitwalker.flutter_socket_plugin.jt808_sdk.sdk.jt808bean.Jt808MapLocation;
import cn.waitwalker.flutter_socket_plugin.jt808_sdk.sdk.jt808coding.JT808Directive;
import cn.waitwalker.flutter_socket_plugin.jt808_sdk.sdk.jt808coding.JTT808Coding;
import cn.waitwalker.flutter_socket_plugin.jt808_sdk.sdk.jt808coding.Jt808StickDataUtil;
import cn.waitwalker.flutter_socket_plugin.jt808_sdk.sdk.jt808utils.ByteUtil;
import cn.waitwalker.flutter_socket_plugin.jt808_sdk.sdk.jt808utils.HexUtil;
import cn.waitwalker.flutter_socket_plugin.jt808_sdk.utils.L;
import cn.waitwalker.flutter_socket_plugin.jt808_sdk.sdk.protocol.JT808ReaderProtocol;
import cn.waitwalker.flutter_socket_plugin.jt808_sdk.sdk.socketbean.PulseData;
import cn.waitwalker.flutter_socket_plugin.jt808_sdk.sdk.socketbean.SendDataBean;
import cn.waitwalker.flutter_socket_plugin.jt808_sdk.utils.ListUtils;
import cn.waitwalker.flutter_socket_plugin.jt808_sdk.utils.PreferenceUtil;
import cn.waitwalker.flutter_socket_plugin.jt808_sdk.oksocket.core.iocore.interfaces.IPulseSendable;
import cn.waitwalker.flutter_socket_plugin.jt808_sdk.oksocket.core.iocore.interfaces.ISendable;
import cn.waitwalker.flutter_socket_plugin.jt808_sdk.oksocket.core.pojo.OriginalData;
import cn.waitwalker.flutter_socket_plugin.jt808_sdk.oksocket.client.impl.client.action.ActionDispatcher;
import cn.waitwalker.flutter_socket_plugin.jt808_sdk.oksocket.client.sdk.client.ConnectionInfo;
import cn.waitwalker.flutter_socket_plugin.jt808_sdk.oksocket.client.sdk.client.OkSocketOptions;
import cn.waitwalker.flutter_socket_plugin.jt808_sdk.oksocket.client.sdk.client.action.SocketActionAdapter;
import cn.waitwalker.flutter_socket_plugin.jt808_sdk.oksocket.client.sdk.client.connection.IConnectionManager;

import java.util.ArrayList;
import java.util.List;

public class SocketManager {

    private static SocketManager INSTANCE;
    private static final Object SingleInstanceLocker = new Object();
    private ConnectionInfo info;
    private IConnectionManager mManager;
    private List<Generate808andSeqBean> mSendDatasIng = new ArrayList<>(); //????????????????????????????????????????????????

    public static SocketManager getInstance() {
        if (INSTANCE == null) {
            synchronized (SingleInstanceLocker) {
                if (INSTANCE == null) {
                    INSTANCE = new SocketManager();
                }
            }
        }

        return INSTANCE;
    }

    /*
     * ??????Socket????????????
     */

    private void initManager(String ip, int port) {
        info = new ConnectionInfo(ip, port);
        final Handler handler = new Handler(Looper.getMainLooper());
        OkSocketOptions.Builder builder = new OkSocketOptions.Builder();
//        builder.setReconnectionManager(new NoneReconnect());
//        builder.setReconnectionManager(new DefaultReconnectManager());
        builder.setPulseFrequency(5000L); //????????????
        builder.setCallbackThreadModeToken(new OkSocketOptions.ThreadModeToken() {
            @Override
            public void handleCallbackEvent(ActionDispatcher.ActionRunnable runnable) {
                handler.post(runnable);
            }
        });
        builder.setReaderProtocol(new JT808ReaderProtocol());
        mManager = OkSocket.open(info).option(builder.build());
    }

    /**
     * ?????????
     */
    public Application application;

    public void init(Application application) {
        this.application = application;
        initManager(SocketConfig.socketIp, Integer.parseInt(SocketConfig.socketPort));
    }

    private IConnectionManager getManager() {
        return mManager;
    }

    /**
     * ???????????????
     * ?????????????????? ??? ???????????????
     *
     * @param ip
     * @param prot
     * @param socketActionAdapter
     * @throws
     */
    SocketActionAdapter socketAdapter;

    private void connect(String ip, int port, SocketActionAdapter socketActionAdapter) throws Exception {
        if (mManager != null) {
            if (!mManager.isConnect()) {
                //????????????????????????
                initManager(ip, port);
                if (socketAdapter != null) mManager.unRegisterReceiver(socketAdapter);
                socketAdapter = socketActionAdapter;
                mManager.registerReceiver(socketActionAdapter);
                mManager.connect();
            } else {
                mManager.disconnect();
            }
        } else {
            throw new SocketManagerException("???????????????");
        }

    }

    /**
     * ??????????????????
     * @return ?????? true ????????? false
     */
    public boolean isConnect() {
        if (mManager == null) return false;
        return mManager.isConnect();
    }

    public void send(byte[] body) {
        mManager.send(new SendDataBean(body));
    }

    /**
     * ??????????????????
     * @return
     */
    private OkSocketOptions getOption() {
        return mManager.getOption();
    }

    /**
     * ????????????
     */
    private void openPulse() {
        OkSocket.open(info)
                .getPulseManager()
                .setPulseSendable(new PulseData(new SocketPulseListener() {
                    @Override
                    public void parse(byte[] bytes) {
                        L.cc("PulseSend: "+HexUtil.byte2HexStr(bytes));
                        if (socketActionListener != null) socketActionListener.onPulseSend(bytes);
                    }
                }))//?????????????????????,???????????????????????????pulse()
                .pulse();//????????????,???????????????,??????????????????????????????????????????
    }

    /**
     * ????????????
     */
    private void feedPulse() {
        if (mManager != null) mManager.getPulseManager().feed();
    }

    /**
     * ????????????
     */
    public void disconnect() {
        mManager.disconnect();
    }
    /**
     * ???????????? ???????????????????????????????????????????????????
     */
    public void unRegisterReceiver() {
        mManager.unRegisterReceiver(socketAdapter);
        Jt808StickDataUtil.clear();
    }

    /*
    APP???????????????????????????
     */

    private SocketManager socketManager;
    private StartLocationBackList startLocationBackList;

    public void setJt808Phont(String mPhont){
      SocketConfig.setmPhont(mPhont);
    }

    public void setJt808TerminalId(String mTerminalId){
      SocketConfig.setmTerminalId(mTerminalId);
    }

    public void setJt808OrderId(String mOrderId){
       SocketConfig.setmOrderId(mOrderId);
    }

    /**
     * ?????????????????????
     * ???????????? https://dev-cv.saicmotor.com/confluence/pages/viewpage.action?pageId=64193234
     *
     * @param startLocationBackList 0??????????????????APP??????????????????????????????????????????
     */
    public void startLocation(final StartLocationBackList startLocationBackList) {
        this.startLocationBackList = startLocationBackList;
        socketManager = INSTANCE;
        if (TextUtils.isEmpty(SocketConfig.getmPhont()) || TextUtils.isEmpty(SocketConfig.getmTerminalId())){
            startLocationBackList.onBack(1019,"??????????????????ID??????");
        }
        try {
            if (socketManager.isConnect()) {
//                goAuthCode();
                startLocationBackList.onBack(0, "???????????????????????????????????????^_^");
            } else {
                socketManager.connect(SocketConfig.socketIp, Integer.valueOf(SocketConfig.socketPort), new SocketActionAdapter() {
                    @Override
                    public void onSocketConnectionSuccess(ConnectionInfo info, String action) {
                        L.cc("Connection???????????????");
                        if (socketActionListener != null) socketActionListener.onSocketConnectionSuccess();
                        socketManager.openPulse();
                        goAuthCode();
                    }

                    @Override
                    public void onSocketConnectionFailed(ConnectionInfo info, String action, Exception e) {
                        L.cc("Connection???????????????");
                        if (socketActionListener != null) socketActionListener.onSocketConnectionFailed();
                        startLocationBackList.onBack(1003, "???????????????????????????");
                        Jt808StickDataUtil.clear();
                    }

                    @Override
                    public void onSocketDisconnection(ConnectionInfo info, String action, Exception e) {
                        L.cc("Connection??????????????????");
                        if (socketActionListener != null) socketActionListener.onSocketDisconnection();
                        startLocationBackList.onBack(1004, "???????????????????????????");
                        Jt808StickDataUtil.clear();
                    }

                    @Override
                    public void onSocketReadResponse(ConnectionInfo info, String action, OriginalData data) {
                        byte[] body = ByteUtil.byteMergerAll(data.getBodyBytes()); //?????????
                        if (socketActionListener != null) socketActionListener.onSocketReadResponse(body);
                        L.cc("?????????????????????:" + HexUtil.byte2HexStr(body));
                        List<byte[]> bodys = Jt808StickDataUtil.getStickData(body);
                        for (int i = 0; i < bodys.size(); i++) {
                            L.cc("?????????????????????:" + HexUtil.byte2HexStr(bodys.get(i)));
                            onReadResponse(bodys.get(i));
                        }
                    }

                    @Override
                    public void onSocketWriteResponse(ConnectionInfo info, String action, ISendable data) {
                        String s = HexUtil.byte2HexStrNoSpace(data.parse());
                        if (socketActionListener != null) socketActionListener.onSocketWriteResponse(data.parse());
                        L.cc("Write:" + s);
                    }

                    @Override
                    public void onPulseSend(ConnectionInfo info, IPulseSendable data) {

                    }
                });
            }
        } catch (Exception e) {
            e.printStackTrace();
            startLocationBackList.onBack(1021, e.getMessage());
        }
    }

    private void onReadResponse(byte[] body) {
        byte[] bytes = JTT808Coding.check808Data(body); //??????????????????7E??????????????????
        if (bytes == null) {
            startLocationBackList.onBack(1021, "?????????????????????");
            return;
        }
        L.jt808(bytes);
        JTT808Bean jt808data = JTT808Coding.resolve808(bytes);
        switch (jt808data.getMsgId()) {
            case 0x8100:
                //????????????????????????
                if (jt808data.getReplyResult() == 0x00) {
                    //??????????????? ?????????
                    byte[] authCode = jt808data.getAuthenticationCode();
                    PreferenceUtil.set(SocketConfig.JT808AuthCode, HexUtil.byte2HexStrNoSpace(authCode));
                    goAuthCode();
                } else if (jt808data.getReplyResult() == 0x03) { //?????????
                    if (onGetResetDeviceList != null)
                        onGetResetDeviceList.getResetDevice(isReset -> {
                            if (isReset) {
                                getAuthCode();
                            } else {
                                startLocationBackList.onBack(1008, "??????????????????");
                                stopLocation();
                            }
                        });
                } else {
                    startLocationBackList.onBack(1015, "???????????????" + jt808data.getReplyResult());
                }
                break;
            case 0x8001:
                if (jt808data.getReturnMsgId() == 0x0002) { //??????
                    if (socketManager != null) socketManager.feedPulse();
                } else if (0x0102 == jt808data.getReturnMsgId()) { //??????
                    if (jt808data.getReplyResult() == 0x00) {
                        startLocationBackList.onBack(0, "????????????????????????");
                    } else if (jt808data.getReplyResult() == 0x05) {
                        //???????????????
                        PreferenceUtil.clear(SocketConfig.JT808AuthCode); //?????????????????????
                        getAuthCode();
                    } else {
                        //????????????
                        stopLocation();
                        PreferenceUtil.clear(SocketConfig.JT808AuthCode); //?????????????????????
                        startLocationBackList.onBack(1012, "???????????? code:" + jt808data.getReplyResult());
                    }
                } else if (0x0200 == jt808data.getReturnMsgId()) { //??????????????????

                }else if (0x0704 == jt808data.getReturnMsgId()){ //??????????????????

                }
                break;
            case 0x8101:
                //?????????????????????
                if (jt808data.getReplyResult() == 0x00) {
                    //??????????????? ?????????
                    byte[] authCode = jt808data.getAuthenticationCode();
                    PreferenceUtil.set(SocketConfig.JT808AuthCode, HexUtil.byte2HexStrNoSpace(authCode));
                    goAuthCode();
                } else {
                    startLocationBackList.onBack(1008, "??????????????????????????????code" + jt808data.getReplyResult());
                }

                break;
        }
        for (int i = 0; i < mSendDatasIng.size(); i++) {
            if (mSendDatasIng.get(i).getSeqNo() == jt808data.getMsgFlowNumber()){
                mSendDatasIng.remove(i);
                break;
            }
        }
    }


    /*
     ????????????????????? ???????????????
                byte[] bytes = JTT808Coding.check808Data(body);
                JTT808Bean jt808data = JTT808Coding.resolve808(bytes);
                int MsgFlowNumber = jt808data.getMsgFlowNumber();
     */

    /**
     * ?????????
     */
    private void goRegister() {
        if (socketManager == null || !socketManager.isConnect()) {
            startLocationBackList.onBack(1004, "??????????????????");
        } else {
            byte[] register = JT808Directive.register(SocketConfig.mManufacturerId, SocketConfig.mTerminalModel, SocketConfig.getmTerminalId());
            byte[] body = JTT808Coding.generate808(0x0100, SocketConfig.getmPhont(), register);
            socketManager.send((body));
        }
    }

    /**
     * ?????????
     */
    private void goAuthCode() {
        if (socketManager == null || !socketManager.isConnect()) {
            startLocationBackList.onBack(1004, "??????????????????");
        } else {
            String stringAuthCode = PreferenceUtil.get(SocketConfig.JT808AuthCode);
            if (TextUtils.isEmpty(stringAuthCode)) {
                goRegister();
            } else {
                byte[] authCode = HexUtil.hexStringToByte(stringAuthCode);
                byte[] body = JTT808Coding.generate808(0x0102, SocketConfig.getmPhont(), authCode);
                socketManager.send((body));
            }
        }
    }

    /**
     * ????????????(???SDK??????)
     */
    public void goLogout() {
        if (socketManager == null || !socketManager.isConnect()) {
            startLocationBackList.onBack(1004, "??????????????????");
        } else {
            byte[] body = JTT808Coding.generate808(0x0003, SocketConfig.getmPhont(), new byte[]{});
            socketManager.send((body));
        }
    }


    /**
     * ?????????????????????
     */
    private void getAuthCode() {
        if (socketManager == null || !socketManager.isConnect()) {
            startLocationBackList.onBack(1004, "??????????????????");
        } else {
            byte[] body = JTT808Coding.generate808(0x0103, SocketConfig.getmPhont(), new byte[]{});
            socketManager.send((body));
        }
    }

    public void stopLocation() {
        if (socketManager != null) {
            socketManager.disconnect();
            Jt808StickDataUtil.clear();
        }
    }

    private OnGetResetDeviceList onGetResetDeviceList;
    /**
     * ?????????????????????Http??????
     *
     * @param onGetResetDeviceList ?????????????????????
     */
    public void setOnGetResetDeviceList(OnGetResetDeviceList onGetResetDeviceList) {
        if (onGetResetDeviceList != null) {
            this.onGetResetDeviceList = onGetResetDeviceList;
        }
    }

    /**
     * Socket?????????????????????????????????????????????
     */
    private SocketActionListener socketActionListener;
    public void setSocketActionListener(SocketActionListener socketActionListener){
        this.socketActionListener = socketActionListener;
    }


    /**
     * ????????????????????????
     * @param jt808MapLocation
     */
    public void sendReportLocation(Jt808MapLocation jt808MapLocation) {
        byte[] bytes = JT808Directive.reportLocation(jt808MapLocation);
        Generate808andSeqBean generate808orSeqBean = JTT808Coding.generate808orSeqNo(0x0200, SocketConfig.getmPhont(), bytes);
        byte[] body = generate808orSeqBean.getBytes();
        mManager.send(new SendDataBean(body));
        mSendDatasIng.add(generate808orSeqBean);
    }

    /**
     * ????????????????????????
     * @param jt808MapLocations
     */
    public void sendBatchReportLocation(List<Jt808MapLocation> jt808MapLocations) {
        if (ListUtils.isEmpty(jt808MapLocations))return;

        // ???????????????????????????????????????10??????
       List<List<Jt808MapLocation>> jt808MapLocations10 = ListUtils.split(jt808MapLocations,10);
        for (int i = 0; i < jt808MapLocations10.size(); i++) {
            goBatchReportLocation(jt808MapLocations10.get(i));
        }
    }

    private void goBatchReportLocation(List<Jt808MapLocation> jt808MapLocations){
        ArrayList<byte[]> locations = new ArrayList();
        //??????????????????Byte??????
        for (int i = 0; i < jt808MapLocations.size(); i++) {
            byte[] bytes = JT808Directive.reportLocation(jt808MapLocations.get(i));
            locations.add(bytes);
        }
        // ????????????????????????????????????
        byte[] batchBytes = JT808Directive.batchReportLocation(locations);
        Generate808andSeqBean generate808orSeqBean = JTT808Coding.generate808orSeqNo(0x0704, SocketConfig.getmPhont(), batchBytes);
        byte[] body = generate808orSeqBean.getBytes();
        mManager.send(new SendDataBean(body));
        mSendDatasIng.add(generate808orSeqBean);
    }

    /**
     * ????????????????????????
     * @return
     */
    public List<Generate808andSeqBean> getNoReplyDatas(){
        return mSendDatasIng;
    }
}
