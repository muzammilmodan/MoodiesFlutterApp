package com.example.moodiesapp.colorsPic.util;

import androidx.recyclerview.widget.RecyclerView;

import jp.wasabeef.recyclerview.adapters.AlphaInAnimationAdapter;
import jp.wasabeef.recyclerview.adapters.ScaleInAnimationAdapter;
//
//import jp.wasabeef.recyclerview.animators.adapters.AlphaInAnimationAdapter;
//import jp.wasabeef.recyclerview.animators.adapters.ScaleInAnimationAdapter;

/**
 * Created by Swifty.Wang on 2015/9/11.
 */
public class ListAnimationUtil {

    public static RecyclerView.Adapter addScaleandAlphaAnim(RecyclerView.Adapter adapter) {
        AlphaInAnimationAdapter alphaAdapter = new AlphaInAnimationAdapter(adapter);
        ScaleInAnimationAdapter scaleAdapter = new ScaleInAnimationAdapter(alphaAdapter);
        return scaleAdapter;
    }

    public static AlphaInAnimationAdapter addAlphaAnim(RecyclerView.Adapter adapter) {
        AlphaInAnimationAdapter alphaAdapter = new AlphaInAnimationAdapter(adapter);
        return alphaAdapter;
    }
}
