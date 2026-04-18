package com.example.moodiesapp.colorsPic.controller.categorylist;

import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.widget.TextView;
import android.widget.Toast;

import androidx.recyclerview.widget.GridLayoutManager;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.swiperefreshlayout.widget.SwipeRefreshLayout;

import com.example.moodiesapp.R;
import com.example.moodiesapp.colorsPic.MyApplication;
import com.example.moodiesapp.colorsPic.controller.BaseActivity;
import com.example.moodiesapp.colorsPic.controller.paint.PaintActivity;
import com.example.moodiesapp.colorsPic.model.GridViewActivityModel;
import com.example.moodiesapp.colorsPic.model.OnRecycleViewItemClickListener;
import com.example.moodiesapp.colorsPic.model.bean.PictureBean;
import com.example.moodiesapp.colorsPic.util.L;
import com.example.moodiesapp.colorsPic.util.ListAnimationUtil;
import com.example.moodiesapp.colorsPic.util.NetWorkUtil;
import com.example.moodiesapp.colorsPic.util.UmengUtil;
import com.example.moodiesapp.colorsPic.view.EmptyRecyclerView;

import java.io.IOException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.Objects;

/**
 * Created by Swifty.Wang on 2015/7/31.
 */
public class GridViewActivity extends BaseActivity {
    private int categoryId;
    private EmptyRecyclerView gridView;
    List<PictureBean.Picture> pictureBeans;
    GirdRecyclerViewAdapter gridViewAdapter;
    private TextView titleView;
    private SwipeRefreshLayout swipeView;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        try {
            categoryId = Objects.requireNonNull(getIntent().getExtras()).getInt(MyApplication.THEMEID);
            initViews();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private void loadLocaldata() {
        try {
            pictureBeans = getSecretGardenBean(new ArrayList<>(Arrays.asList(getAssets().list("SecretGarden"))));
            L.e(pictureBeans.size() + "");
            if (pictureBeans == null) {
                Toast.makeText(GridViewActivity.this, getString(R.string.loadfailed), Toast.LENGTH_SHORT).show();
            } else {
                showGrid(true);
            }
        } catch (IOException e) {
            L.e(e.toString());
            e.printStackTrace();
        }
    }

    /**
     * put sercet garden uri into PictureBean
     *
     * @param secretGarden
     * @return
     */
    private List<PictureBean.Picture> getSecretGardenBean(ArrayList<String> secretGarden) {
        List<PictureBean.Picture> pictureBeans = new ArrayList<>();
        for (String s : secretGarden) {
            pictureBeans.add(new PictureBean.Picture(s));
        }
        return pictureBeans;
    }

    private void loadPicsInthisTheme(int anInt) {

        try {
            swipeView.post(new Runnable() {
                @Override
                public void run() {
                    swipeView.setRefreshing(true);
                }
            });
            GridViewActivityModel.getInstance().loadPictureData(this, anInt, new GridViewActivityModel.OnLoadPicFinishListener() {
                @Override
                public void LoadPicFinish(List<PictureBean.Picture> pictures) {
                    swipeView.post(new Runnable() {
                        @Override
                        public void run() {
                            swipeView.setRefreshing(false);
                        }
                    });
                    if (pictures != null && !pictures.isEmpty()) {
                        pictureBeans = pictures;
                        showGrid(false);
                    } else {
                        Toast.makeText(GridViewActivity.this, getString(R.string.loadfailed), Toast.LENGTH_SHORT).show();
                    }
                }

                @Override
                public void LoadPicFailed(String error) {
                    swipeView.post(new Runnable() {
                        @Override
                        public void run() {
                            swipeView.setRefreshing(false);
                        }
                    });
                    Toast.makeText(GridViewActivity.this, getString(R.string.loadfailed), Toast.LENGTH_SHORT).show();
                }
            });
        } catch (Exception e) {
            e.printStackTrace();
        }
//        } else {
//            showGrid(false);
//        }
    }

    @Override
    public void onBackPressed() {
        finish(); // ✅ just pop back to MainColorPicActivity
    }

    private void initViews() {
        try {
            setContentView(R.layout.activity_gridview);
            titleView = (TextView) findViewById(R.id.toolbar_title);
            swipeView = (SwipeRefreshLayout) findViewById(R.id.swiperefresh);
            gridView = (EmptyRecyclerView) findViewById(R.id.detail_gird);

            GridLayoutManager layoutManager = new GridLayoutManager(this, 2);
            layoutManager.setOrientation(LinearLayoutManager.VERTICAL);
            gridView.setLayoutManager(layoutManager);
            titleView.setText(getIntent().getStringExtra(MyApplication.THEMENAME));
            swipeView.setColorSchemeResources(R.color.red, R.color.orange, R.color.green, R.color.maincolor);
            swipeView.setOnRefreshListener(new SwipeRefreshLayout.OnRefreshListener() {
                @Override
                public void onRefresh() {
                    if (NetWorkUtil.isNetworkConnected(GridViewActivity.this)) {
                        GridViewActivityModel.getInstance().refreshPictureData(GridViewActivity.this, categoryId, new GridViewActivityModel.OnLoadPicFinishListener() {
                            @Override
                            public void LoadPicFinish(List<PictureBean.Picture> pictureBeans) {
                                swipeView.setRefreshing(false);
                                showGrid(false);
                            }

                            @Override
                            public void LoadPicFailed(String error) {
                                swipeView.setRefreshing(false);
                                Toast.makeText(GridViewActivity.this, getString(R.string.loadfailed), Toast.LENGTH_SHORT).show();
                            }
                        });
                    } else {
                        swipeView.setRefreshing(false);
                        Toast.makeText(GridViewActivity.this, getString(R.string.network_notconnet), Toast.LENGTH_SHORT).show();
                    }
                }
            });
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private void gotoPaintActivity(String s) {
        try {
            Toast.makeText(this, "Grid View call", Toast.LENGTH_SHORT).show();

            UmengUtil.analysitic(this, UmengUtil.MODELNUMBER,
                    getIntent().getStringExtra(MyApplication.THEMENAME) + categoryId);
            Intent intent = new Intent(this, PaintActivity.class);
            intent.putExtra(MyApplication.BIGPIC, MyApplication.SECRETGARDENLOCATION + s);

//            if (s.contains(MyApplication.MainUrl)) {
//                intent.putExtra(MyApplication.BIGPIC, s);
//            } else {
//                intent.putExtra(MyApplication.BIGPIC, MyApplication.SECRETGARDENLOCATION + s);
//            }
            startActivity(intent);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }


    private void showGrid(final boolean isLocal) {
        try {
            gridViewAdapter = new GirdRecyclerViewAdapter(this, pictureBeans, categoryId, isLocal);
            gridViewAdapter.setOnRecycleViewItemClickListener(new OnRecycleViewItemClickListener() {
                @Override
                public void recycleViewItemClickListener(View view, int i) {
                    if (isLocal) {
                        gotoPaintActivity(pictureBeans.get(i).getUri());
                    } else {
                        gotoPaintActivity(String.format(MyApplication.ImageLageUrl, categoryId, pictureBeans.get(i).getId()));
                    }
                }
            });
            gridView.setAdapter(ListAnimationUtil.addScaleandAlphaAnim(gridViewAdapter));
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    @Override
    protected void onResume() {
        super.onResume();
        if (categoryId == -1) {
            loadLocaldata();
        } else {
            loadPicsInthisTheme(categoryId);
        }
    }

}
