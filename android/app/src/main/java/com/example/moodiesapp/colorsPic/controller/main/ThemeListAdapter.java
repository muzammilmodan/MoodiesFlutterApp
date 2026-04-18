package com.example.moodiesapp.colorsPic.controller.main;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;

import androidx.recyclerview.widget.RecyclerView;

import com.example.moodiesapp.R;
import com.example.moodiesapp.colorsPic.MyApplication;
import com.example.moodiesapp.colorsPic.model.AsynImageLoader;
import com.example.moodiesapp.colorsPic.model.OnRecycleViewItemClickListener;
import com.example.moodiesapp.colorsPic.model.bean.ThemeBean;

import java.util.List;

/**
 * Created by Swifty.Wang on 2015/8/14.
 */
public class ThemeListAdapter extends RecyclerView.Adapter<RecyclerView.ViewHolder> {
    Context context;
    List<ThemeBean.Theme> themelist;
    private final int TYPE_ITEM = 1;

    public void setOnRecycleViewItemClickListener(OnRecycleViewItemClickListener onRecycleViewItemClickListener) {
        this.onRecycleViewItemClickListener = onRecycleViewItemClickListener;
    }

    private OnRecycleViewItemClickListener onRecycleViewItemClickListener;

    public ThemeListAdapter(Context context, List<ThemeBean.Theme> themelist) {
        this.context = context;
        this.themelist = themelist;
    }

    @Override
    public int getItemViewType(int position) {
        return TYPE_ITEM;
    }

    @Override
    public RecyclerView.ViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {
        View v = LayoutInflater.from(context)
                    .inflate(R.layout.view_list_item, parent, false);
            return new VHItem(v);
    }

    @Override
    public void onBindViewHolder(final RecyclerView.ViewHolder holder, final int position) {
        if (holder instanceof VHItem) {
            if (themelist.get(position) != null) {
                ((VHItem) holder).name.setText(themelist.get(position).getN());
                if (themelist.get(position).getC() == -1) {
                    ((VHItem) holder).image.setImageResource(R.mipmap.secretgraden);
                } else {
                    AsynImageLoader.showImageAsyn(((VHItem) holder).image, String.format(MyApplication.ThemeThumbUrl, themelist.get(position).getC()));
                }
                ((VHItem) holder).parent.setOnClickListener(new View.OnClickListener() {
                    @Override
                    public void onClick(View view) {
                        if (onRecycleViewItemClickListener != null)
                            onRecycleViewItemClickListener.recycleViewItemClickListener(((VHItem) holder).parent, position);
                    }
                });
            }
        }

    }

    @Override
    public int getItemCount() {
        return themelist.size();
    }

    public List<ThemeBean.Theme> getList() {
        return themelist;
    }


    static class VHItem extends RecyclerView.ViewHolder {

        public ImageView image;
        public TextView name;
        public View parent;

        public VHItem(View itemView) {
            super(itemView);
            image = (ImageView) itemView.findViewById(R.id.image);
            name = (TextView) itemView.findViewById(R.id.name);
            parent = itemView;
        }

    }


    public void updateListView(List<ThemeBean.Theme> list) {
        this.themelist = list;
        notifyDataSetChanged();
    }
}
