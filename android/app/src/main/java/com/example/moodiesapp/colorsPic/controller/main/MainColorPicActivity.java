package com.example.moodiesapp.colorsPic.controller.main;

import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.os.Build;
import android.os.Bundle;
import android.view.MenuItem;
import android.view.View;
import android.view.WindowManager;
import android.widget.ImageView;
import android.widget.Toast;

import androidx.viewpager.widget.ViewPager;


import com.example.moodiesapp.MainActivity;
import com.google.android.material.tabs.TabLayout;
import com.example.moodiesapp.R;
import com.example.moodiesapp.colorsPic.MyApplication;
import com.example.moodiesapp.colorsPic.broadcast.LoginSuccessBroadcast;
import com.example.moodiesapp.colorsPic.controller.AppCompatBaseAcitivity;
import com.example.moodiesapp.colorsPic.factory.MyDialogFactory;
import com.example.moodiesapp.colorsPic.factory.SharedPreferencesFactory;
import com.example.moodiesapp.colorsPic.listener.OnLoginSuccessListener;
import com.example.moodiesapp.colorsPic.model.bean.UserBean;
import com.example.moodiesapp.colorsPic.receiver.UserLoginReceiver;
import com.example.moodiesapp.colorsPic.util.L;
import com.example.moodiesapp.colorsPic.util.UmengLoginUtil;

import java.util.ArrayList;
import java.util.List;

/**
 * Created by Swifty.Wang on 2015/7/31.
 */
public class MainColorPicActivity extends AppCompatBaseAcitivity {

    //private Toolbar toolbar;
    private TabLayout tabLayout;
    private ViewPager viewPager;
    private SectionsPagerAdapter sectionsPagerAdapter;
    private long exitTime;
    UserLoginReceiver receiver;
    IntentFilter filter;
    public static MenuItem logout;
    MyDialogFactory myDialogFactory;

    ImageView ivBackPaint;

    // ✅ Track whether receiver is currently registered to avoid
    //    IllegalArgumentException on double-unregister
    private boolean receiverRegistered = false;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        try {
            setTitle(R.string.app_name);

            if (getSupportActionBar() != null) {
                getSupportActionBar().hide();
            }

            getWindow().setFlags(
                    WindowManager.LayoutParams.FLAG_FULLSCREEN,
                    WindowManager.LayoutParams.FLAG_FULLSCREEN
            );
            //Todo: Mujju hide notification
            //UmengUtil.pushNotification(this);


            //autoLogin();
            initViews();
            showMarketCommentDialog();
            receiver = new UserLoginReceiver();
            filter = new IntentFilter();
            filter.addAction("userLoginAction");
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private void autoLogin() {
        MyApplication.userToken = SharedPreferencesFactory.grabString(this, SharedPreferencesFactory.USERSESSION);
        L.e(MyApplication.userToken);
        if (MyApplication.userToken != null && !MyApplication.userToken.isEmpty()) {

            UmengLoginUtil.getInstance().serverBackgroundLogin(new OnLoginSuccessListener() {
                @Override
                public void onLoginSuccess(UserBean userBean) {
                    if (userBean != null && userBean.getUsers() != null)
                        LoginSuccessBroadcast.getInstance().sendBroadcast(MainColorPicActivity.this);
                }
            });
        }
    }

    private void showMarketCommentDialog() {
        if (Math.random() < 0.15 && SharedPreferencesFactory.getBoolean(this, SharedPreferencesFactory.CommentEnableKey)) {
            //myDialogFactory.showCommentDialog();
        } else if (Math.random() > 0.15 && Math.random() < 0.25 && SharedPreferencesFactory.getBoolean(this, SharedPreferencesFactory.AddQQGroupEnable)) {
            //myDialogFactory.showAddQQgroup();
        }
    }

    private void initViews() {
        setContentView(R.layout.activity_main_paint);
        myDialogFactory = new MyDialogFactory(this);
        //  appBarLayout = (AppBarLayout) findViewById(R.id.appBarLayout);
        ivBackPaint = (ImageView) findViewById(R.id.ivBackPaint);
        tabLayout = (TabLayout) findViewById(R.id.tabs);
        viewPager = (ViewPager) findViewById(R.id.viewpager);

        ivBackPaint.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
               finish();
            }
        });

        // toolbar = (Toolbar) findViewById(R.id.toolbar);
        List<String> tabs = new ArrayList<String>();
        tabs.add(getString(R.string.themelist));
        //       tabs.add(getString(R.string.imagewall));
        tabs.add(getString(R.string.userlogin));
        sectionsPagerAdapter = new SectionsPagerAdapter(getSupportFragmentManager(), tabs);
        //initial all fragment
        sectionsPagerAdapter.destroyAllFragment();
        viewPager.setAdapter(sectionsPagerAdapter);
        viewPager.setOnPageChangeListener(new ViewPager.OnPageChangeListener() {
            @Override
            public void onPageScrolled(int position, float positionOffset, int positionOffsetPixels) {

            }

            @Override
            public void onPageSelected(int position) {
                if (position == 1) {
                    //showFirstTimeLoginDialog();
                }
            }

            @Override
            public void onPageScrollStateChanged(int state) {

            }
        });
        tabLayout.setupWithViewPager(viewPager);
        tabLayout.getTabAt(0).setIcon(R.drawable.ic_collections_white_24dp);
        //      tabLayout.getTabAt(1).setIcon(R.drawable.ic_wallpaper_white_24dp);
        tabLayout.getTabAt(1).setIcon(R.drawable.ic_face_white_24dp);
       /* toolbar = (Toolbar) findViewById(R.id.toolbar);
        if (toolbar != null) {
            setSupportActionBar(toolbar);
        }*/
    }

    private void showFirstTimeLoginDialog() {
        if (MyApplication.user == null && SharedPreferencesFactory.getBoolean(this, SharedPreferencesFactory.IsFirstTimeShowLoginDialog, true)) {
            myDialogFactory.showFirstTimeLoginDialog(new OnLoginSuccessListener() {
                @Override
                public void onLoginSuccess(UserBean userBean) {
                    UmengLoginUtil.getInstance().loginSuccessEvent(MainColorPicActivity.this, userBean, myDialogFactory);
                }
            });
            SharedPreferencesFactory.saveBoolean(this, SharedPreferencesFactory.IsFirstTimeShowLoginDialog, false);
        }
    }


    @Override
    public void onBackPressed() {
        finish();
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        UmengLoginUtil.getInstance().onActivityResult(requestCode, resultCode, data);
    }


    @Override
    protected void onDestroy() {
        super.onDestroy();
    }


    @Override
    protected void onResume() {
        super.onResume();
        // ✅ FIX: Android 13+ (API 33+) requires an explicit export flag when
        //   registering a receiver dynamically. Without it the OS throws:
        //   SecurityException: One of RECEIVER_EXPORTED or RECEIVER_NOT_EXPORTED
        //   should be specified when a receiver isn't being registered
        //   exclusively for system broadcasts.
        //
        //   "userLoginAction" is a private internal action, so we use
        //   RECEIVER_NOT_EXPORTED — no other app can send this broadcast.
        if (!receiverRegistered) {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) { // API 33
                registerReceiver(receiver, filter, Context.RECEIVER_NOT_EXPORTED);
            } else {
                registerReceiver(receiver, filter);
            }
            receiverRegistered = true;
        }
    }

    @Override
    protected void onPause() {
        super.onPause();
        // ✅ FIX: Always unregister in onPause to match the onResume registration.
        //   The original code had this commented out, causing a receiver leak
        //   (and a possible "leaked IntentReceiver" warning on activity destroy).
        if (receiverRegistered) {
            unregisterReceiver(receiver);
            receiverRegistered = false;
        }
    }
}
