package com.example.moodiesapp.colorsPic.controller.main;

import com.example.moodiesapp.colorsPic.model.bean.LocalImageBean;

import java.util.Comparator;

/**
 * Created by Swifty.Wang on 2015/9/4.
 */
public class TimestampComparator implements Comparator<LocalImageBean> {
    @Override
    public int compare(LocalImageBean localImageBean, LocalImageBean t1) {
//        long diff = t1.getLastModTimeStamp() - localImageBean.getLastModTimeStamp();
//        if (diff > 0)
//            return 1;
//        if (diff < 0)
//            return -1;
//        else
           return 0;
    }
}
