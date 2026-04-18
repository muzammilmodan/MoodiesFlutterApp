package com.example.moodiesapp.colorsPic.controller.paint;

import android.graphics.BitmapFactory;
import android.os.Bundle;
import android.view.View;
import android.view.ViewGroup;
import android.view.WindowManager;
import android.widget.Button;
import android.widget.Toast;

import com.example.moodiesapp.R;
import com.example.moodiesapp.colorsPic.MyApplication;
import com.example.moodiesapp.colorsPic.controller.BaseActivity;
import com.example.moodiesapp.colorsPic.factory.MyDialogFactory;
import com.example.moodiesapp.colorsPic.listener.OnAddWordsSuccessListener;
import com.example.moodiesapp.colorsPic.listener.OnChangeBorderListener;
import com.example.moodiesapp.colorsPic.model.SaveImageAsyn;
import com.example.moodiesapp.colorsPic.util.ShareImageUtil;
import com.example.moodiesapp.colorsPic.util.UmengUtil;
import com.example.moodiesapp.colorsPic.view.DragedTextView;
import com.example.moodiesapp.colorsPic.view.MyProgressDialog;
import com.example.moodiesapp.databinding.ActivityPaintAdvanceBinding;

/**
 * Created by macpro001 on 20/8/15.
 */
public class AdvancePaintActivity extends BaseActivity {

    public static int Offest = MyApplication.screenWidth / 40;
    String imageUri;
    MyDialogFactory myDialogFactory;

    Button cancel;



    ActivityPaintAdvanceBinding binding;
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        initWindows();
        setContentView(R.layout.activity_paint_advance);

        binding = ActivityPaintAdvanceBinding.inflate(getLayoutInflater());
        setContentView(binding.getRoot());

        myDialogFactory = new MyDialogFactory(AdvancePaintActivity.this);
        imageUri = getIntent().getStringExtra("imagepath");
        binding.currentImage.setImageBitmap(BitmapFactory.decodeFile(imageUri));

        cancel = binding.cancel;

        binding.addwords.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                addwordsDialog();
            }
        });
        binding.addborder.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                addBorderDialog();
            }
        });
        binding.share.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                shareDrawable();
            }
        });
        binding.repaint.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                repaintPictureDialog();
            }
        });
        binding.cloudgallery.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                uploadImage();
            }
        });
        cancel.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                finish();
            }
        });
    }

    private void uploadImage() {
        Toast.makeText(AdvancePaintActivity.this, getString(R.string.comingsoon), Toast.LENGTH_SHORT).show();
    }

    private void initWindows() {

        WindowManager.LayoutParams params = getWindow().getAttributes();
        params.width = MyApplication.screenWidth;
        this.getWindow().setAttributes(params);
    }

    private void repaintPictureDialog() {
        View.OnClickListener onClickListener = new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                myDialogFactory.dismissDialog();
                setResult(MyApplication.RepaintResult);
                finish();
            }
        };
        myDialogFactory.showRepaintDialog(onClickListener);
    }

    private void shareDrawable() {
        binding.paintview.setDrawingCacheEnabled(true);
        UmengUtil.analysitic(AdvancePaintActivity.this, UmengUtil.SHAREIMAGE, imageUri);
        binding.paintview.destroyDrawingCache();
        binding.paintview.buildDrawingCache();
        MyProgressDialog.show(AdvancePaintActivity.this, null, getString(R.string.savingimage));
        SaveImageAsyn saveImageAsyn = new SaveImageAsyn(this);
        saveImageAsyn.execute(binding.paintview.getDrawingCache(), MyApplication.SHAREWORK);
        saveImageAsyn.setOnSaveSuccessListener(new SaveImageAsyn.OnSaveFinishListener() {
            @Override
            public void onSaveFinish(String path) {
                MyProgressDialog.DismissDialog();
                if (path == null) {
                    Toast.makeText(AdvancePaintActivity.this, "Advance Paint save Image Filed", Toast.LENGTH_SHORT).show();
                } else {
                    Toast.makeText(AdvancePaintActivity.this, "Your Save image successfully " + path, Toast.LENGTH_SHORT).show();
                    ShareImageUtil.getInstance(AdvancePaintActivity.this).shareImg(path);
                }
            }
        });
    }

    private void addwordsDialog() {
        OnAddWordsSuccessListener addwordssuccess = new OnAddWordsSuccessListener() {
            @Override
            public void addWordsSuccess(DragedTextView dragedTextView) {
                ((ViewGroup)  binding.currentImage.getParent()).addView(dragedTextView);
            }
        };
        myDialogFactory.showAddWordsDialog(addwordssuccess);
    }

    private void addBorderDialog() {
        OnChangeBorderListener addborderlistener = new OnChangeBorderListener() {
            @Override
            public void changeBorder(int drawableid, int pt, int pd, int pl, int pr) {
                if (drawableid != 0) {
                    binding.border.setBackgroundResource(drawableid);
                    binding.currentImage.setPadding(pl, pt, pr, pd);
                    binding.currentImage.requestLayout();
                }
                binding.paintview.requestLayout();
            }
        };
        myDialogFactory.showAddBorderDialog(addborderlistener);
    }
}
