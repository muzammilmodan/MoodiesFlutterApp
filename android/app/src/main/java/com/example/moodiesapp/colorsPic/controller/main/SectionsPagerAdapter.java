package com.example.moodiesapp.colorsPic.controller.main;

import android.os.Parcelable;

import androidx.fragment.app.Fragment;
import androidx.fragment.app.FragmentManager;
import androidx.fragment.app.FragmentStatePagerAdapter;

import com.example.moodiesapp.colorsPic.fragments.ThemeListFragment;
import com.example.moodiesapp.colorsPic.fragments.UserFragment;

import java.util.ArrayList;
import java.util.List;

/**
 * Created by Swifty.Wang on 2015/8/14.
 */
public class SectionsPagerAdapter extends FragmentStatePagerAdapter {
    List<String> tabs = new ArrayList<String>();

    public SectionsPagerAdapter(FragmentManager fragmentManager, List<String> tabs) {
        super(fragmentManager);
        this.tabs = tabs;
    }

    @Override
    public Fragment getItem(int position) {
        if (position == 0) {
            return ThemeListFragment.getInstance();
//        } else if (position == 1) {
//            return ImageWallFragment.getInstance();
//        } else {
        } else {
            return UserFragment.getInstance();
        }
    }

    @Override
    public int getCount() {
        return tabs.size();
    }

    @Override
    public CharSequence getPageTitle(int position) {
        return tabs.get(position);
    }

    @Override
    public Parcelable saveState() {
        return null;
    }

    public void destroyAllFragment() {
        ThemeListFragment.getInstance().finish();
        UserFragment.getInstance().finish();
    }
}
