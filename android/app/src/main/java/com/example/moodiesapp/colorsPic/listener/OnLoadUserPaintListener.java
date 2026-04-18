package com.example.moodiesapp.colorsPic.listener;

import com.example.moodiesapp.colorsPic.model.bean.LocalImageBean;

import java.util.List;

/**
 * Created by Swifty.Wang on 2015/9/1.
 */
public interface OnLoadUserPaintListener {
    void loadUserPaintFinished(List<LocalImageBean> list);
}
