package com.example.moodiesapp.colorsPic.listener;

import com.example.moodiesapp.colorsPic.model.bean.ThemeBean;

import java.util.List;

/**
 * Created by Swifty.Wang on 2015/8/18.
 */
public interface OnThemeListLoadListener {
    void onLoadFinish(List<ThemeBean.Theme> names);
}
