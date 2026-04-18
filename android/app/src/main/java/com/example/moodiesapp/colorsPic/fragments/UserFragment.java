package com.example.moodiesapp.colorsPic.fragments;

import android.content.Intent;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewGroup;
import android.widget.LinearLayout;
import android.widget.RadioButton;
import android.widget.RadioGroup;
import android.widget.Toast;

import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;
import androidx.recyclerview.widget.StaggeredGridLayoutManager;
import androidx.swiperefreshlayout.widget.SwipeRefreshLayout;

import com.example.moodiesapp.R;
import com.example.moodiesapp.colorsPic.controller.BaseFragment;
import com.example.moodiesapp.colorsPic.controller.main.CacheImageAdapter;
import com.example.moodiesapp.colorsPic.controller.main.LocalPaintAdapter;
import com.example.moodiesapp.colorsPic.factory.MyDialogFactory;
import com.example.moodiesapp.colorsPic.listener.OnLoadCacheImageListener;
import com.example.moodiesapp.colorsPic.listener.OnLoadUserPaintListener;
import com.example.moodiesapp.colorsPic.listener.OnLoginSuccessListener;
import com.example.moodiesapp.colorsPic.model.UserFragmentModel;
import com.example.moodiesapp.colorsPic.model.bean.CacheImageBean;
import com.example.moodiesapp.colorsPic.model.bean.LocalImageBean;
import com.example.moodiesapp.colorsPic.model.bean.UserBean;
import com.example.moodiesapp.colorsPic.util.L;
import com.example.moodiesapp.colorsPic.util.ListAnimationUtil;
import com.example.moodiesapp.colorsPic.util.UmengLoginUtil;
import com.example.moodiesapp.colorsPic.view.EmptyRecyclerView;

import java.util.ArrayList;
import java.util.List;

/**
 * Created by Swifty.Wang on 2015/8/18.
 */
public class UserFragment extends BaseFragment implements OnLoginSuccessListener {
    private static UserFragment fragment;

    EmptyRecyclerView userpaintlist;
    SwipeRefreshLayout refreshLayout;

    RecyclerView.Adapter adapter;

    LinearLayout emptylayPaintlist;

    List<LocalImageBean> localImageBeans;

    RadioButton tab_imagecache;

    RadioButton tab_local;

    RadioButton tab_cloud;

    RadioGroup usertabs;

    MyDialogFactory myDialogFactory;

    public static UserFragment getInstance() {
        if (fragment == null) {
            fragment = new UserFragment();
        }
        fragment.setRetainInstance(true);
        return fragment;
    }


    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        View rootView = inflater.inflate(R.layout.fragment_user, container, false);

        try {
            getIds(rootView);
            initViews();
            addEvents();
        } catch (Exception e) {
            e.printStackTrace();
        }
        return rootView;
    }

    private void getIds(View rootView) {
        userpaintlist = rootView.findViewById(R.id.userpaintlist);
        refreshLayout = rootView.findViewById(R.id.swiperefresh);
        emptylayPaintlist = rootView.findViewById(R.id.emptylay_paintlist);
        tab_imagecache = rootView.findViewById(R.id.tab_imagecache);
        tab_local = rootView.findViewById(R.id.tab_local);
        tab_cloud = rootView.findViewById(R.id.tab_cloud);
        usertabs = rootView.findViewById(R.id.usertabs);
    }

    private void initViews() {
        try {
            myDialogFactory = new MyDialogFactory(getContext());
            userpaintlist.setEmptyView(emptylayPaintlist);
            refreshLayout.setColorSchemeResources(R.color.red, R.color.orange, R.color.green, R.color.maincolor);
            loadLocalPaints();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private void showUserLoginxDialog() {
        myDialogFactory.showLoginDialog(this);
    }

    private void addEvents() {

        try {

            swipeRefreshLayout = refreshLayout;
            refreshLayout.setOnRefreshListener(new SwipeRefreshLayout.OnRefreshListener() {
                @Override
                public void onRefresh() {
                    L.e("load");
                    if (usertabs.getCheckedRadioButtonId() == R.id.tab_local) {
                        //change vertical recycleview to listview
                        userpaintlist.setLayoutManager(
                                new androidx.recyclerview.widget.GridLayoutManager(getActivity(), 2)
                        );
                        //clear recycleview
                        userpaintlist.setAdapter(new LocalPaintAdapter(getActivity(), localImageBeans));
                        OnLoadUserPaintListener onLoadUserPaintListener = new OnLoadUserPaintListener() {
                            @Override
                            public void loadUserPaintFinished(List<LocalImageBean> list) {
                                if (list != null) {
                                    localImageBeans = list;
                                    adapter = new LocalPaintAdapter(getActivity(), localImageBeans);
                                    userpaintlist.setAdapter(ListAnimationUtil.addScaleandAlphaAnim(adapter));
                                }
                                //Todo: Mujju
                                if (refreshLayout != null) {
                                    refreshLayout.setRefreshing(false);
                                }
                                //refreshLayout.setRefreshing(false);
                            }
                        };
                        UserFragmentModel.getInstance(getActivity()).obtainLocalPaintList(onLoadUserPaintListener);
                    } else if (usertabs.getCheckedRadioButtonId() == R.id.tab_imagecache) {
                        loadCacheImages();
                    } else if (usertabs.getCheckedRadioButtonId() == R.id.tab_cloud) {
                        //load cloud paints
                    }

                }
            });
            usertabs.setOnCheckedChangeListener(new RadioGroup.OnCheckedChangeListener() {
                @Override
                public void onCheckedChanged(RadioGroup radioGroup, int i) {
                    if (i == R.id.tab_local) {
                        loadLocalPaints();
                    } else if (i == R.id.tab_imagecache) {
                        loadCacheImages();
                    } else {
                        //load cloud paints
                    }
                }
            });
            tab_cloud.setOnTouchListener(new View.OnTouchListener() {
                @Override
                public boolean onTouch(View view, MotionEvent motionEvent) {
    //                if (motionEvent.getAction() == MotionEvent.ACTION_DOWN) {
    //                    if (MyApplication.user != null) {
    //                        return false;
    //                    } else {
    //                        myDialogFactory.showLoginDialog(UserFragment.this);
    //                        return true;
    //                    }
    //                }
    //                return false;
                    Toast.makeText(getActivity(), getString(R.string.comingsoon), Toast.LENGTH_SHORT).show();
                    return true;
                }
            });
        } catch (Exception e) {
            e.printStackTrace();
        }


    }

    private void loadCacheImages() {

        try {
            refreshLayout.post(new Runnable() {
                @Override
                public void run() {
                    refreshLayout.setRefreshing(true);
                }
            });
            //change vertical recycleview to gridview
            StaggeredGridLayoutManager layoutManager = new StaggeredGridLayoutManager(2, StaggeredGridLayoutManager.VERTICAL);
            userpaintlist.setLayoutManager(layoutManager);
            //clear recycleview
            userpaintlist.scrollToPosition(0);
            userpaintlist.setAdapter(new CacheImageAdapter(getActivity(), new ArrayList<CacheImageBean>()));
            //load cache paints
            OnLoadCacheImageListener loadUserPaintListener = new OnLoadCacheImageListener() {
                @Override
                public void loadCacheImageSuccess(List<CacheImageBean> cacheImageBeans) {
                    //Todo: Mujju
                    //refreshLayout.setRefreshing(false);
                    if (refreshLayout != null) {
                        refreshLayout.setRefreshing(false);
                    }
                    if (cacheImageBeans != null) {
                        adapter = new CacheImageAdapter(getActivity(), cacheImageBeans);
                        userpaintlist.setAdapter(ListAnimationUtil.addScaleandAlphaAnim(adapter));
                    }
                }

            };
            UserFragmentModel.getInstance(getActivity()).obtainCacheImageList(getActivity(), loadUserPaintListener);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private void loadLocalPaints() {
        try {
            //change vertical recycleview to listview
            //userpaintlist.setLayoutManager(new LinearLayoutManager(getActivity()));
            userpaintlist.setLayoutManager(
                    new androidx.recyclerview.widget.GridLayoutManager(getActivity(), 2)
            );

            //clear recycleview
            userpaintlist.setAdapter(new LocalPaintAdapter(getActivity(), localImageBeans));
            //load local paints
            OnLoadUserPaintListener onLoadUserPaintListener = new OnLoadUserPaintListener() {
                @Override
                public void loadUserPaintFinished(List<LocalImageBean> list) {
                    if (list != null) {
                        adapter = new LocalPaintAdapter(getActivity(), list);

//                        StaggeredGridLayoutManager layoutManager =
//                                new StaggeredGridLayoutManager(2, StaggeredGridLayoutManager.VERTICAL);
//
//                        userpaintlist.setLayoutManager(layoutManager);
                        userpaintlist.setAdapter(adapter);
                    }
                }
            };
            UserFragmentModel.getInstance(getActivity()).obtainLocalPaintList(onLoadUserPaintListener);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }


    @Override
    public void onResume() {
        super.onResume();
        L.e("resume  " + isAdded());
        //awlays refreshlist when resume
        try {
            if (isAdded()) {
                if (tab_local.isChecked()) {
                    if (adapter != null)
                        adapter.notifyDataSetChanged();
                } else {
                    if (adapter != null)
                        adapter.notifyDataSetChanged();
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    @Override
    public void onDestroyView() {
        super.onDestroyView();
       // ButterKnife.bind(this);
    }

    @Override
    public void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        UmengLoginUtil.getInstance().onActivityResult(requestCode, resultCode, data);
    }

    public void finish() {
        L.e("Userfinish");
        fragment = null;
    }

    @Override
    public void onLoginSuccess(UserBean userBean) {
        UmengLoginUtil.getInstance().loginSuccessEvent(getActivity(), userBean, myDialogFactory);
    }
}
