package com.example.moodiesapp.colorsPic.receiver;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.drawable.BitmapDrawable;
import android.view.View;

import com.example.moodiesapp.R;
import com.example.moodiesapp.colorsPic.MyApplication;
import com.example.moodiesapp.colorsPic.controller.main.MainColorPicActivity;
import com.example.moodiesapp.colorsPic.util.DensityUtil;
import com.example.moodiesapp.colorsPic.util.ImageLoaderUtil;
import com.nostra13.universalimageloader.core.ImageLoader;
import com.nostra13.universalimageloader.core.assist.FailReason;
import com.nostra13.universalimageloader.core.assist.ImageSize;
import com.nostra13.universalimageloader.core.listener.ImageLoadingListener;

/**
 * Created by Swifty on 2015/10/3.
 */
public class UserLoginReceiver extends BroadcastReceiver {

    @Override
    public void onReceive(final Context context, Intent intent) {
        // TODO Auto-generated method stub
        String action = null;
        if (intent.hasExtra("msg")) {
            action = intent.getStringExtra("msg");
        }
        if (context instanceof MainColorPicActivity) {
            if ("loginsuccess".equals(action)) {
                if (MyApplication.user != null) {

                    ImageLoader.getInstance().loadImage(MyApplication.user.getUsericon(), new ImageSize(DensityUtil.dip2px(context, 32),DensityUtil.dip2px(context,32)),ImageLoaderUtil.getOpenAllCacheOptions(), new ImageLoadingListener() {
                        @Override
                        public void onLoadingStarted(String s, View view) {

                        }

                        @Override
                        public void onLoadingFailed(String s, View view, FailReason failReason) {

                        }

                        @Override
                        public void onLoadingComplete(String s, View view, Bitmap bitmap) {
                            ((MainColorPicActivity) context).getSupportActionBar().setIcon(new BitmapDrawable(context.getResources(), bitmap));
                        }

                        @Override
                        public void onLoadingCancelled(String s, View view) {

                        }
                    });
                    ((MainColorPicActivity) context).setTitle(MyApplication.user.getName());
                   //Mujju
                    if (MainColorPicActivity.logout != null) {
                        MainColorPicActivity.logout.setVisible(true);
                    }
                }
            } else if ("logoutsuccess".equals(action)) {
                ((MainColorPicActivity) context).getSupportActionBar().setIcon(0);
                ((MainColorPicActivity) context).setTitle(context.getString(R.string.app_name));
               //Mujju
                 if (MainColorPicActivity.logout != null) {
                    MainColorPicActivity.logout.setVisible(false);
                }
            }
        }
    }

}

