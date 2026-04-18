package com.example.moodiesapp.colorsPic.controller.main;

import android.content.Context;
import android.content.Intent;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.LinearLayout;

import androidx.recyclerview.widget.RecyclerView;

import com.example.moodiesapp.R;
import com.example.moodiesapp.colorsPic.MyApplication;
import com.example.moodiesapp.colorsPic.controller.paint.PaintActivity;
import com.example.moodiesapp.colorsPic.model.AsynImageLoader;
import com.example.moodiesapp.colorsPic.model.bean.CacheImageBean;
import com.example.moodiesapp.colorsPic.util.UmengUtil;

import java.util.ArrayList;
import java.util.List;

/**
 * Created by Swifty.Wang on 2015/9/9.
 */
public class CacheImageAdapter extends RecyclerView.Adapter<CacheImageAdapter.ViewHolder> {
    List<CacheImageBean> cacheImageBeans;
    Context context;

    public CacheImageAdapter(Context context, List<CacheImageBean> cacheImageBeans) {
        if (cacheImageBeans == null) {
            cacheImageBeans = new ArrayList<>();
        }
        this.cacheImageBeans = cacheImageBeans;
        this.context = context;
    }


    @Override
    public ViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {
        View v = LayoutInflater.from(context)
                .inflate(R.layout.view_cacheimage_item, parent, false);
        return new ViewHolder(v);
    }

    @Override
    public void onBindViewHolder(final ViewHolder holder, int position) {

        CacheImageBean item = cacheImageBeans.get(position);

        if (item.getWvHRadio() != 0) {
            holder.image.setLayoutParams(
                    new LinearLayout.LayoutParams(
                            MyApplication.getScreenWidth(context) / 2,
                            (int) (MyApplication.getScreenWidth(context) / 2 / item.getWvHRadio())
                    )
            );
        } else {
            holder.image.setLayoutParams(
                    new LinearLayout.LayoutParams(
                            MyApplication.getScreenWidth(context) / 2,
                            (int) (MyApplication.getScreenWidth(context) / 2 / 0.71)
                    )
            );
        }

        AsynImageLoader.showImageAsynWithoutCache(holder.image, item.getUrl());

        // ✅ FIX: do NOT use "position" here
        holder.image.setOnClickListener(v -> {
            int adapterPosition = holder.getAdapterPosition();

            if (adapterPosition != RecyclerView.NO_POSITION) {
                CacheImageBean clickedItem = cacheImageBeans.get(adapterPosition);
                gotoPaintActivity(clickedItem.getUrl());
            }
        });
    }

    private void gotoPaintActivity(String s) {
        UmengUtil.analysitic(context, UmengUtil.MODELNUMBER, s);
        Intent intent = new Intent(context, PaintActivity.class);
        intent.putExtra(MyApplication.BIGPIC, s);
        context.startActivity(intent);
    }

    @Override
    public int getItemCount() {
        return cacheImageBeans.size();
    }

    static class ViewHolder extends RecyclerView.ViewHolder {

        ImageView image;

        public ViewHolder(View itemView) {
            super(itemView);
            image = (ImageView) itemView.findViewById(R.id.image);
        }

    }
}
