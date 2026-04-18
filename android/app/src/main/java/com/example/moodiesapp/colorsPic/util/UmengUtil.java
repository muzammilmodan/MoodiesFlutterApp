package com.example.moodiesapp.colorsPic.util;

import android.content.Context;
import android.widget.Toast;

import com.example.moodiesapp.R;
import com.example.moodiesapp.colorsPic.MyApplication;
import com.example.moodiesapp.colorsPic.factory.SharedPreferencesFactory;
import com.example.moodiesapp.colorsPic.view.MyProgressDialog;
import com.umeng.analytics.MobclickAgent;


/**
 * Created by macpro001 on 4/8/15.
 */
public class UmengUtil {

    public static final String SAVEIMAGE = "save_image";
    public static final String THEMENAME = "theme_name";
    public static final String MODELNUMBER = "model_number";
    public static final String SHAREIMAGE = "share_image";
    public static final String UPDATELOG = "update_log";
    private static String currentVersionDetail;

    public static void autoUpdate(final Context context) {
        //MM CLOSED
//        UmengUpdateAgent.setUpdateOnlyWifi(false);
//        UmengUpdateAgent.update(context);
//        UmengUpdateAgent.setUpdateListener(new UmengUpdateListener() {
//            @Override
//            public void onUpdateReturned(int i, UpdateResponse updateResponse) {
//                if (updateResponse != null && updateResponse.updateLog != null && !updateResponse.updateLog.isEmpty()) {
//                    SharedPreferencesFactory.saveString(context, UPDATELOG, updateResponse.updateLog);
//                }
//            }
//        });
    }

    public static void analysitic(Context context, String string, String string2) {
        MobclickAgent.onEvent(context, string, string2);
    }

    //MM CLOSED
    public static void pushNotification(Context context) {
//        PushAgent mPushAgent = PushAgent.getInstance(context);
//        mPushAgent.enable();
//        PushAgent.getInstance(context).onAppStart();
    }

    public static void analysisOnResume(Context context) {
        MobclickAgent.onResume(context);
    }

    public static void analysisOnPause(Context context) {
        MobclickAgent.onPause(context);
    }

    public static String getCurrentVersionDetail(Context context) {
        String log = SharedPreferencesFactory.grabString(context, UPDATELOG);
        if (log != null && log.contains(MyApplication.getVersion(context))) {
            return SharedPreferencesFactory.grabString(context, UPDATELOG);
        } else {
            return context.getString(R.string.noupdatelog);
        }
    }

    public static void checkUpdate(final Context context) {
        MyProgressDialog.show(context, null, context.getString(R.string.checkupdateing));
        //MM CLOSED
//        UmengUpdateAgent.setUpdateListener(new UmengUpdateListener() {
//            @Override
//            public void onUpdateReturned(int updateStatus, UpdateResponse updateInfo) {
//                MyProgressDialog.DismissDialog();
//                switch (updateStatus) {
//                    case UpdateStatus.Yes: // has update
//                        UmengUpdateAgent.showUpdateDialog(context, updateInfo);
//                        break;
//                    case UpdateStatus.No: // has no update
//                        Toast.makeText(context, context.getString(R.string.noupdate), Toast.LENGTH_SHORT).show();
//                        break;
//                    case UpdateStatus.NoneWifi: // none wifi
//                        Toast.makeText(context, context.getString(R.string.onlyupdateinwifi), Toast.LENGTH_SHORT).show();
//                        break;
//                    case UpdateStatus.Timeout: // time out
//                        Toast.makeText(context, context.getString(R.string.timeout), Toast.LENGTH_SHORT).show();
//                        break;
//                }
//            }
//        });
//        UmengUpdateAgent.forceUpdate(context);
    }

}
