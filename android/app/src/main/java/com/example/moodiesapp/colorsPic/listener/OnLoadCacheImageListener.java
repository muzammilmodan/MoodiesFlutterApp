package com.example.moodiesapp.colorsPic.listener;

import com.example.moodiesapp.colorsPic.model.bean.CacheImageBean;

import java.util.List;

/**
 * Created by Swifty.Wang on 2015/9/9.
 */
public interface OnLoadCacheImageListener {
    void loadCacheImageSuccess(List<CacheImageBean> cacheImageBeans);
}
