package com.example.moodiesapp.colorsPic.controller;

import androidx.fragment.app.Fragment;
import androidx.swiperefreshlayout.widget.SwipeRefreshLayout;

/**
 * Created by Swifty.Wang on 2015/9/2.
 */
public class BaseFragment extends Fragment {
    protected SwipeRefreshLayout swipeRefreshLayout;

    @Override
    public void onResume() {
        super.onResume();
        if (getActivity() instanceof AppCompatBaseAcitivity) {
            ((AppCompatBaseAcitivity) getActivity()).setmSwipeRefreshLayout(swipeRefreshLayout);
        }
    }
}
