package com.example.moodiesapp.colorsPic.model;

import android.content.Context;
import android.os.AsyncTask;
import android.util.Log;

import com.example.moodiesapp.colorsPic.controller.main.UserFragment;
import com.example.moodiesapp.colorsPic.controller.paint.myfileutils.FileUtils;
import com.example.moodiesapp.colorsPic.listener.OnLoadCacheImageListener;
import com.example.moodiesapp.colorsPic.listener.OnLoadUserPaintListener;
import com.example.moodiesapp.colorsPic.model.bean.CacheImageBean;
import com.example.moodiesapp.colorsPic.model.bean.LocalImageBean;
import com.example.moodiesapp.colorsPic.util.L;

import java.util.ArrayList;
import java.util.List;

/**
 * Created by Swifty.Wang on 2015/9/1.
 */
public class UserFragmentModel {
    private static UserFragmentModel ourInstance;
    Context context;
    AsyncTask asyncTask;

    public static UserFragmentModel getInstance(Context context) {
        if (ourInstance == null) {
            ourInstance = new UserFragmentModel(context);
        }
        return ourInstance;
    }

    private UserFragmentModel(Context context) {
        this.context = context;

        // ── IMPORTANT: Init FileUtils with context ─────────────────
        FileUtils.init(context);
    }

    public void obtainLocalPaintList(OnLoadUserPaintListener onLoadUserPaintListener) {
        asyncTask = new LoadLocalPaintsAsyn();
        asyncTask.execute(onLoadUserPaintListener);
    }

    public void obtainCacheImageList(Context context, OnLoadCacheImageListener onLoadCacheImageListener) {
        asyncTask = new LoadCacheImagesAsyn();
        asyncTask.execute(onLoadCacheImageListener, context);
    }

    private class LoadLocalPaintsAsyn extends AsyncTask {
        OnLoadUserPaintListener onLoadUserPaintListener;

        @Override
        protected Object doInBackground(Object[] objects) {
            L.e("load local data");
            onLoadUserPaintListener = (OnLoadUserPaintListener) objects[0];
            List<LocalImageBean> result =
                    FileUtils.obtainLocalImages();

            // Never return null
            if (result == null) {
                result = new ArrayList<>();
            }

            Log.e("","local images found: " + result.size());
            return result;
        }

        @Override
        protected void onPostExecute(Object o) {
            super.onPostExecute(o);
            L.e(o.toString());
            List<LocalImageBean> list =
                    (List<LocalImageBean>) o;

            L.e("onPostExecute list size: "
                    + (list != null ? list.size() : "null"));

            if (UserFragment.getInstance().isAdded()
                    && onLoadUserPaintListener != null) {
                onLoadUserPaintListener
                        .loadUserPaintFinished(list);
            }
//
//            if (UserFragment.getInstance().isAdded() && onLoadUserPaintListener != null) {
//                onLoadUserPaintListener.loadUserPaintFinished((List<LocalImageBean>) o);
//            }
        }
    }

    private class LoadCacheImagesAsyn extends AsyncTask {
        OnLoadCacheImageListener onLoadCacheImageListener;
        Context context;

        @Override
        protected Object doInBackground(Object[] params) {
            onLoadCacheImageListener = (OnLoadCacheImageListener) params[0];
            context = (Context) params[1];
            List<CacheImageBean> cacheImageBeans;
            cacheImageBeans = FCDBModel.getInstance().readHaveCacheImages(context);
            if (cacheImageBeans == null) {
                cacheImageBeans = new ArrayList<>();
            }

            return cacheImageBeans;
        }

        @Override
        protected void onPostExecute(Object o) {
            super.onPostExecute(o);
            if (UserFragment.getInstance().isAdded() && onLoadCacheImageListener != null) {
                onLoadCacheImageListener.loadCacheImageSuccess((List<CacheImageBean>) o);
            }
        }
    }


}
