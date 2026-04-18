package com.example.moodiesapp.colorsPic.controller.paint;

import android.Manifest;
import android.annotation.SuppressLint;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.content.res.Resources;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Canvas;
import android.graphics.drawable.ColorDrawable;
import android.os.AsyncTask;
import android.os.Build;
import android.os.Bundle;
import android.os.Environment;
import android.util.Log;
import android.view.Menu;
import android.view.MenuItem;
import android.view.MotionEvent;
import android.view.View;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TableLayout;
import android.widget.TableRow;
import android.widget.Toast;

import androidx.core.app.ActivityCompat;
import androidx.core.content.ContextCompat;

import com.example.moodiesapp.R;
import com.example.moodiesapp.colorsPic.MyApplication;
import com.example.moodiesapp.colorsPic.controller.BaseActivity;
import com.example.moodiesapp.colorsPic.factory.AnimateFactory;
import com.example.moodiesapp.colorsPic.factory.MyDialogFactory;
import com.example.moodiesapp.colorsPic.factory.SharedPreferencesFactory;
import com.example.moodiesapp.colorsPic.model.AsynImageLoader;
import com.example.moodiesapp.colorsPic.model.SaveImageAsyn;
import com.example.moodiesapp.colorsPic.util.*;
import com.example.moodiesapp.colorsPic.view.*;

import com.example.moodiesapp.photoslibrary.ColourImageView;
import com.example.moodiesapp.photoslibrary.OnDrawLineListener;
import com.example.moodiesapp.photoslibrary.PhotoViewAttacher;
import com.nostra13.universalimageloader.core.assist.FailReason;
import com.nostra13.universalimageloader.core.listener.ImageLoadingListener;

import java.io.File;
import java.util.List;

import okhttp3.MultipartBody;
//import com.example.moodiesapp.photoslibrary.ColourImageView;
//import com.example.moodiesapp.photoslibrary.OnDrawLineListener;
//import com.example.moodiesapp.photoslibrary.PhotoViewAttacher;


public class PaintActivity extends BaseActivity implements View.OnClickListener {
    ColourImageView colourImageView;
    PhotoViewAttacher mAttacher;
    TableLayout tableLayout;
    ImageView currentColor, cColor1, cColor2, cColor3, cColor4;
    ColorPicker colorPickerSeekBar, largecolorpicker;
    ImageView advanceColor;
    ImageButton_define paintImageSave, share, open, more, delete;
    ImageButton_define_secondLay undo, redo;
    ImageCheckBox_define pick, drawLine, jianbian_color;
    String URL;
    int PAINTNAME;
    LinearLayout advanceLay, largecolorpickerlay;
    private Bitmap cachedBitmap;
    private int isShowing = 2;
    private boolean fromSDcard = false;
    MyDialogFactory myDialogFactory;

    private static final int STORAGE_PERMISSION_CODE = 101;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        //ActivityUtil.hideStatusBar(this);
        setContentView(R.layout.activity_paint);

        try {
            initViews();
            addEvents();

            //loadPaints();

            if (getIntent().hasExtra(MyApplication.BIGPIC)) {
                Log.e("1","======>");
                fromSDcard = false;
                URL = getIntent().getExtras().getString(MyApplication.BIGPIC);
                loadLargeImage();
            } else if (getIntent().hasExtra(MyApplication.BIGPICFROMUSER)) {
                Log.e("2","======>");
                fromSDcard = true;
                URL = getIntent().getExtras().getString(MyApplication.BIGPICFROMUSER);
                PAINTNAME = getIntent().getExtras().getInt(MyApplication.BIGPICFROMUSERPAINTNAME);
                loadLargeImageFromSDcard();
            } else {
                finish();
            }

            Log.e("main urls ==============>",URL);
           // lastSavedPath = URL;
        } catch (Exception e) {
            e.printStackTrace();
        }
    }


    // Call this before saveToLocal()
    private boolean checkStoragePermission() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            // Android 13+
            if (ContextCompat.checkSelfPermission(this,
                    Manifest.permission.READ_MEDIA_IMAGES)
                    != PackageManager.PERMISSION_GRANTED) {

                ActivityCompat.requestPermissions(this,
                        new String[]{Manifest.permission.READ_MEDIA_IMAGES},
                        STORAGE_PERMISSION_CODE);
                return false;
            }
        } else if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            // Android 6 - 12
            if (ContextCompat.checkSelfPermission(this,
                    Manifest.permission.WRITE_EXTERNAL_STORAGE)
                    != PackageManager.PERMISSION_GRANTED) {

                ActivityCompat.requestPermissions(this,
                        new String[]{
                                Manifest.permission.WRITE_EXTERNAL_STORAGE,
                                Manifest.permission.READ_EXTERNAL_STORAGE
                        },
                        STORAGE_PERMISSION_CODE);
                return false;
            }
        }
        return true;
    }

    // Handle permission result
    @Override
    public void onRequestPermissionsResult(int requestCode,
                                           String[] permissions, int[] grantResults) {
        super.onRequestPermissionsResult(requestCode,
                permissions, grantResults);

        if (requestCode == STORAGE_PERMISSION_CODE) {
            if (grantResults.length > 0
                    && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                // Permission granted - now save
                saveToLocal();
            } else {
                Toast.makeText(this,
                        "Storage permission required to save image",
                        Toast.LENGTH_SHORT).show();
            }
        }
    }

    private void loadLargeImageFromSDcard() {
        try {
            MyProgressDialog.show(this, null, getString(R.string.loadpicture));
            new AsyncTask() {
                @Override
                protected Object doInBackground(Object[] objects) {
                    try {
                        Thread.sleep(2000);
                    } catch (InterruptedException e) {
                        e.printStackTrace();
                    }
                    return null;
                }

                @Override
                protected void onPostExecute(Object o) {
                    super.onPostExecute(o);
                    Log.e("loadLargeImageFromSDcard","==========>>>>>" + URL);
                    AsynImageLoader.showLagreImageAsynWithNoCacheOpen(colourImageView, URL, new ImageLoadingListener() {
                        @Override
                        public void onLoadingStarted(String s, View view) {
                            Log.e("4","======>");
                        }

                        @Override
                        public void onLoadingFailed(String s, View view, FailReason failReason) {
                            MyProgressDialog.DismissDialog();
                            Toast.makeText(PaintActivity.this, getString(R.string.loadpicturefailed), Toast.LENGTH_SHORT).show();
                            finish();
                        }

                        @Override
                        public void onLoadingComplete(String s, View view, Bitmap bitmap) {
                            Log.e("5","======>");
                            mAttacher = new PhotoViewAttacher(colourImageView, bitmap);
                            //rotate screen load bitmap saved in the savestates
                            if (cachedBitmap != null) {
                                colourImageView.setImageBT(cachedBitmap);
                            }
                            MyProgressDialog.DismissDialog();
                            //show advancelay
                            advanceLaytoggle();

                        }

                        @Override
                        public void onLoadingCancelled(String s, View view) {
                            MyProgressDialog.DismissDialog();
                            Toast.makeText(PaintActivity.this, getString(R.string.loadpicturefailed), Toast.LENGTH_SHORT).show();
                            finish();
                        }
                    });
                }
            }.execute();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private void loadLargeImage() {

        try {
            MyProgressDialog.show(this, null, getString(R.string.loadpicture));
            new AsyncTask() {@Override
                protected Object doInBackground(Object[] objects) {
                    try {
                        Thread.sleep(2000);
                    } catch (InterruptedException e) {
                        e.printStackTrace();
                    }
                    return null;
                }

                @Override
                protected void onPostExecute(Object o) {
                    super.onPostExecute(o);

                    Log.e("loadLargeImage","==========>>>>>" + URL);

                    AsynImageLoader.showLagreImageAsynWithAllCacheOpen(colourImageView, URL, new ImageLoadingListener() {
                        @Override
                        public void onLoadingStarted(String s, View view) {
                            Log.e("8","======>");
                        }

                        @Override
                        public void onLoadingFailed(String s, View view, FailReason failReason) {
                            MyProgressDialog.DismissDialog();
                            Toast.makeText(PaintActivity.this, getString(R.string.loadpicturefailed), Toast.LENGTH_SHORT).show();
                            finish();
                        }

                        @Override
                        public void onLoadingComplete(String s, View view, Bitmap bitmap) {
                            Log.e("9","======>");
                            mAttacher = new PhotoViewAttacher(colourImageView, bitmap);
                            //rotate screen load bitmap saved in the savestates
                            if (cachedBitmap != null) {
                                colourImageView.setImageBT(cachedBitmap);
                            } else {
                                openSaveImage(ImageSaveUtil.convertImageLageUrl(URL).hashCode());
                                Log.e("10","======>");
                                showHintDialog();
                            }
                            MyProgressDialog.DismissDialog();
                            //show advancelay
                            advanceLaytoggle();

                        }

                        @Override
                        public void onLoadingCancelled(String s, View view) {
                            MyProgressDialog.DismissDialog();
                            Toast.makeText(PaintActivity.this, getString(R.string.loadpicturefailed), Toast.LENGTH_SHORT).show();
                            finish();
                        }
                    });
                }
            }.execute();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    // ── Load paints ───────────────────────────────────────────────
    private List<String> paintList;
    private void loadPaints() {
        paintList = MyPaintsLoader.loadSavedPaints(this);

        if (paintList == null || paintList.isEmpty()) {
            //showEmpty();
            Log.e("paintList"," ==========>>>>> loadPaints");
        }

        Log.e("paintList ==========>>>>> ",paintList.toString());

        // Show list
//        emptyText.setVisibility(View.GONE);
//        recyclerView.setVisibility(View.VISIBLE);

       /* adapter = new MyPaintsAdapter(this, paintList,
                new MyPaintsAdapter.OnItemClickListener() {

                    @Override
                    public void onItemClick(String filePath, int position) {
                        // Open in PaintActivity
                        Intent intent = new Intent(
                                MyPaintsActivity.this,
                                PaintActivity.class);
                        intent.putExtra(
                                MyApplication.BIGPICFROMUSER, filePath);
                        intent.putExtra(
                                MyApplication.BIGPICFROMUSERPAINTNAME,
                                filePath.hashCode());
                        startActivity(intent);
                    }

                    @Override
                    public void onItemLongClick(String filePath,
                                                int position) {
                        // Show delete dialog
                        showDeleteDialog(filePath, position);
                    }
                });

        recyclerView.setAdapter(adapter);*/
    }

    private void showHintDialog() {
        myDialogFactory.showPaintHintDialog();
    }

    private void initViews() {
        try {
            myDialogFactory = new MyDialogFactory(this);
            advanceLay = (LinearLayout) findViewById(R.id.topfirstlay);
            colourImageView = (ColourImageView) findViewById(R.id.fillImageview);
            cColor1 = (ImageView) findViewById(R.id.current_pen1);
            cColor2 = (ImageView) findViewById(R.id.current_pen2);
            cColor3 = (ImageView) findViewById(R.id.current_pen3);
            cColor4 = (ImageView) findViewById(R.id.current_pen4);
            tableLayout = (TableLayout) findViewById(R.id.colortable);
            colorPickerSeekBar = (ColorPicker) findViewById(R.id.seekcolorpicker);
            largecolorpicker = (ColorPicker) findViewById(R.id.largepicker);
            largecolorpickerlay = (LinearLayout) findViewById(R.id.largepickerlay);
            advanceColor = (ImageView) findViewById(R.id.advance_color);
            undo = (ImageButton_define_secondLay) findViewById(R.id.undo);
            redo = (ImageButton_define_secondLay) findViewById(R.id.redo);
            paintImageSave = (ImageButton_define) findViewById(R.id.save);
            open = (ImageButton_define) findViewById(R.id.open);
            share = (ImageButton_define) findViewById(R.id.share);
            more = (ImageButton_define) findViewById(R.id.more);
            delete = (ImageButton_define) findViewById(R.id.delete);
            pick = (ImageCheckBox_define) findViewById(R.id.pickcolor);
            drawLine = (ImageCheckBox_define) findViewById(R.id.drawline);
            jianbian_color = (ImageCheckBox_define) findViewById(R.id.jianbian_color);
        } catch (Exception e) {
            e.printStackTrace();
        }

    }

    private void addEvents() {
        try {
            advanceColor.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View view) {
                    Log.e("11","======>");
                    advanceLaytoggle();
                }
            });
            undo.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View view) {
                    colourImageView.undo();
                }
            });
            redo.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View view) {
                    colourImageView.redo();
                }
            });
            currentColor = cColor1;
            getSavedColors(cColor1, cColor2, cColor3, cColor4);
            cColor1.setOnClickListener(checkCurrentColor);
            cColor2.setOnClickListener(checkCurrentColor);
            cColor3.setOnClickListener(checkCurrentColor);
            cColor4.setOnClickListener(checkCurrentColor);
            changeCurrentColor(currentColor);
            colorPickerSeekBar.setOnChangedListener(new ColorPicker.OnColorChangedListener() {
                @Override
                public void colorChangedListener(int color) {
                    changeCurrentColor(color);
                }
            });
            colorPickerSeekBar.setOnTouchListener(new View.OnTouchListener() {
                @Override
                public boolean onTouch(View view, MotionEvent motionEvent) {
                    int action = motionEvent.getAction();
                    switch (action) {
                        case MotionEvent.ACTION_DOWN:
                            largecolorpickerlay.setVisibility(View.VISIBLE);
                            largecolorpickerlay.startAnimation(AnimateFactory.getInstance().popupAnimation(PaintActivity.this));
                        case MotionEvent.ACTION_MOVE:
                            largecolorpicker.setColor(colorPickerSeekBar.getColor());
                            break;
                        case MotionEvent.ACTION_CANCEL:
                        case MotionEvent.ACTION_UP:
                            largecolorpickerlay.setVisibility(View.GONE);
                            break;
                    }
                    return false;
                }
            });

            colorPickerSeekBar.setColor(getResources().getColor(R.color.maincolor));
            colourImageView.setOnRedoUndoListener(new ColourImageView.OnRedoUndoListener() {
                @Override
                public void onRedoUndo(int undoSize, int redoSize) {
                    if (undoSize != 0) {
                        undo.setEnabled(true);
                        undo.setImageSrc(R.drawable.blueundo);
                    } else {
                        undo.setEnabled(false);
                        undo.setImageSrc(R.drawable.greyundo);
                    }
                    if (redoSize != 0) {
                        redo.setEnabled(true);
                        redo.setImageSrc(R.drawable.blueredo);
                    } else {
                        redo.setEnabled(false);
                        redo.setImageSrc(R.drawable.greyredo);
                    }
                }
            });
            paintImageSave.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View view) {
                    Log.e("12","======>");
                    saveToLocal();
                }
            });
            open.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View view) {
                    Log.e("13","======>");
                    if (fromSDcard) {
                        openSaveImage(PAINTNAME);
                    } else {
                        openSaveImage(ImageSaveUtil.convertImageLageUrl(URL).hashCode());
                    }
                }
            });
            share.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View view) {
                    shareImage();
                }
            });
            for (int i = 0; i < tableLayout.getChildCount(); i++) {
                for (int j = 0; j < ((TableRow) tableLayout.getChildAt(i)).getChildCount(); j++) {
                    if (((TableRow) tableLayout.getChildAt(i)).getChildAt(j) instanceof Button) {
                        ((TableRow) tableLayout.getChildAt(i)).getChildAt(j).setOnClickListener(this);
                    }
                }
            }
            pick.setOnCheckedChangeListener(new OnCheckedChangeListener() {
                @Override
                public void onCheckedChanged(View buttonView, boolean isChecked) {
                    Log.e("14","======>");
                    if (isChecked) {
                        drawLine.setChecked(false);
                        myDialogFactory.showPickColorHintDialog();
                        colourImageView.setModel(ColourImageView.Model.PICKCOLOR);
                        colourImageView.setOnColorPickListener(new ColourImageView.OnColorPickListener() {
                            @Override
                            public void onColorPick(boolean status, int color) {
                                if (status == true) {
                                    changeCurrentColor(color);
                                    pick.setChecked(false);
                                } else {
                                    Toast.makeText(PaintActivity.this, getString(R.string.pickcolorerror), Toast.LENGTH_SHORT).show();
                                }
                            }
                        });
                    } else {
                        backToColorModel();
                    }
                }
            });
            drawLine.setOnCheckedChangeListener(new OnCheckedChangeListener() {
                @Override
                public void onCheckedChanged(View buttonView, boolean isChecked) {
                    Log.e("15","======>");
                    if (isChecked) {
                        pick.setChecked(false);
                        myDialogFactory.showBuxianButtonClickDialog();
                        colourImageView.setModel(ColourImageView.Model.DRAW_LINE);
                        colourImageView.setOnDrawLineListener(new OnDrawLineListener() {
                            @Override
                            public void OnDrawFinishedListener(boolean drawed, int startX, int startY, int endX, int endY) {
                                if (!drawed) {
                                    Toast.makeText(PaintActivity.this, getString(R.string.drawLineHint_finish), Toast.LENGTH_SHORT).show();
                                } else {
                                    myDialogFactory.showBuxianNextPointSetDialog();
                                }
                            }

                            @Override
                            public void OnGivenFirstPointListener(int startX, int startY) {
                                myDialogFactory.showBuxianFirstPointSetDialog();
                            }

                            @Override
                            public void OnGivenNextPointListener(int endX, int endY) {

                            }
                        });
                    } else {
                        colourImageView.clearPoints();
                        backToColorModel();
                    }
                }
            });
            delete.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    View.OnClickListener listener = new View.OnClickListener() {
                        @Override
                        public void onClick(View v) {
                            myDialogFactory.dismissDialog();
                            repaint();
                        }
                    };
                    myDialogFactory.showRepaintDialog(listener);
                }
            });
            more.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    gotoAdvancePaintActivity();
                }
            });

            jianbian_color.setOnCheckedChangeListener(new OnCheckedChangeListener() {
                @Override
                public void onCheckedChanged(View view, boolean checked) {
                    if (checked) {
                        myDialogFactory.showGradualHintDialog();
                        colourImageView.setModel(ColourImageView.Model.FILLGRADUALCOLOR);
                        jianbian_color.setText(R.string.jianbian_color);
                    } else {
                        colourImageView.setModel(ColourImageView.Model.FILLCOLOR);
                        jianbian_color.setText(R.string.normal_color);
                    }
                }
            });
        } catch (Resources.NotFoundException e) {
            e.printStackTrace();
        }
    }

    private void backToColorModel() {
        colourImageView.setModel(ColourImageView.Model.FILLCOLOR);
        jianbian_color.setChecked(false);
    }

    View.OnClickListener checkCurrentColor = new View.OnClickListener() {
        @Override
        public void onClick(View view) {
            int id = view.getId();
            if (id == R.id.current_pen1)
            {
                //change background
                view.setBackgroundResource(R.drawable.main_bg);
                setWhiteRoundBg(R.id.current_pen2, R.id.current_pen3, R.id.current_pen4);
                //set currentimageview
                currentColor = (ImageView) view;
                //change colourImageview color
                changeCurrentColor((ImageView) view);

            }
            if (id == R.id.current_pen2) {
                //change background
                view.setBackgroundResource(R.drawable.main_bg);
                setWhiteRoundBg(R.id.current_pen1, R.id.current_pen3, R.id.current_pen4);
                //set currentimageview
                currentColor = (ImageView) view;
                //change colourImageview color
                changeCurrentColor((ImageView) view);
            }
            if (id == R.id.current_pen3) {
                //change background
                view.setBackgroundResource(R.drawable.main_bg);
                setWhiteRoundBg(R.id.current_pen2, R.id.current_pen1, R.id.current_pen4);
                //set currentimageview
                currentColor = (ImageView) view;
                //change colourImageview color
                changeCurrentColor((ImageView) view);
            }
            if (id == R.id.current_pen4) {
                //change background
                view.setBackgroundResource(R.drawable.main_bg);
                setWhiteRoundBg(R.id.current_pen2, R.id.current_pen3, R.id.current_pen1);
                //set currentimageview
                currentColor = (ImageView) view;
                //change colourImageview color
                changeCurrentColor((ImageView) view);
            }

        }
    };

    private void setWhiteRoundBg(int view1, int view2, int view3) {
        findViewById(view1).setBackgroundResource(R.drawable.white_bg);
        findViewById(view2).setBackgroundResource(R.drawable.white_bg);
        findViewById(view3).setBackgroundResource(R.drawable.white_bg);
    }


    private void gotoAdvancePaintActivity() {

        try {
            L.e("advancepaint");
            Log.e("13","======>");
            SaveImageAsyn.OnSaveFinishListener finishlistener = new SaveImageAsyn.OnSaveFinishListener() {
                @Override
                public void onSaveFinish(String path) {
                    MyProgressDialog.DismissDialog();
                    Intent intent = new Intent(PaintActivity.this, AdvancePaintActivity.class);
                    intent.putExtra("imagepath", path);
                    startActivityForResult(intent, MyApplication.PaintActivityRequest);
                }
            };
            saveToLocal(finishlistener);
        } catch (Exception e) {
            e.printStackTrace();
        }

    }

    private void advanceLaytoggle() {
        Log.e("15","======>");
        if (isShowing == 2) {
            advanceColor.setImageResource(R.drawable.hidebutton);
            AnimateFactory.getInstance().BounceInDownAnimation(advanceLay, findViewById(R.id.advancelay2), findViewById(R.id.colorpicklay));
            isShowing = 1;
        } else if (isShowing == 1) {
            if (advanceLay.getVisibility() == View.VISIBLE) {
                advanceColor.setImageResource(R.drawable.hidebutton);
                AnimateFactory.getInstance().SlideOutUpAnimation(advanceLay);
                isShowing = 0;
            } else {
                advanceColor.setImageResource(R.drawable.hidebutton);
                AnimateFactory.getInstance().BounceInDownAnimation(findViewById(R.id.advancelay2), findViewById(R.id.colorpicklay));
                isShowing = 0;
            }
        } else {
            advanceColor.setImageResource(R.drawable.showbutton);
            AnimateFactory.getInstance().SlideOutUpAnimation(advanceLay, findViewById(R.id.advancelay2), findViewById(R.id.colorpicklay));
            isShowing = 2;
        }
    }

    private boolean isSaved = false;
    private void shareImage() {
        try {
            UmengUtil.analysitic(PaintActivity.this, UmengUtil.SHAREIMAGE, URL);
            MyProgressDialog.show(PaintActivity.this, null, getString(R.string.savingimage));
            SaveImageAsyn saveImageAsyn = new SaveImageAsyn(this);
            if (fromSDcard) {
                saveImageAsyn.execute(colourImageView.getmBitmap(), PAINTNAME);
            } else {
                saveImageAsyn.execute(colourImageView.getmBitmap(), ImageSaveUtil.convertImageLageUrl(URL).hashCode());
            }
            saveImageAsyn.setOnSaveSuccessListener(new SaveImageAsyn.OnSaveFinishListener() {
                @Override
                public void onSaveFinish(String path) {
                    MyProgressDialog.DismissDialog();
                    if (path == null) {
                        Toast.makeText(PaintActivity.this, "Paint save image failed. shareImage", Toast.LENGTH_SHORT).show();
                    } else {
                        isSaved = true;
                        lastSavedPath = path;
                        Log.e("main urls 111111==============>",lastSavedPath);
                        Toast.makeText(PaintActivity.this, "Your Save image successfully " + path, Toast.LENGTH_SHORT).show();
                        ShareImageUtil.getInstance(PaintActivity.this).shareImg(path);
                    }
                }
            });
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private String lastSavedPath = null; // Add this field

    private void saveToLocal() {
        Log.e("16","======>");
        // CHECK PERMISSION FIRST
        if (!checkStoragePermission()) {
            return; // wait for permission result
        }

        // ✅ Delete the previously saved file to avoid duplicates
        deleteOldSavedFile();


        UmengUtil.analysitic(PaintActivity.this, UmengUtil.SAVEIMAGE, URL);
        MyProgressDialog.show(PaintActivity.this, null, getString(R.string.savingimage));
        SaveImageAsyn saveImageAsyn = new SaveImageAsyn(this);

        if (fromSDcard) {
            saveImageAsyn.execute(colourImageView.getmBitmap(), PAINTNAME);
        } else {
            saveImageAsyn.execute(colourImageView.getmBitmap(), ImageSaveUtil.convertImageLageUrl(URL).hashCode());

        }

        saveImageAsyn.setOnSaveSuccessListener(new SaveImageAsyn.OnSaveFinishListener() {
            @Override
            public void onSaveFinish(String path) {
                MyProgressDialog.DismissDialog();
                if (path == null) {
                    Toast.makeText(PaintActivity.this, "Paint save image failed. Save To Local", Toast.LENGTH_SHORT).show();
                } else {
                    lastSavedPath = path;
                    isSaved = true;
                    Log.e("main urls 22222==============>",lastSavedPath);
                    Toast.makeText(PaintActivity.this, "Your Save image successfully " + path, Toast.LENGTH_SHORT).show();
                }
            }
        });
    }
    private void saveToLocal(SaveImageAsyn.OnSaveFinishListener onSaveFinishListener) {

        // CHECK PERMISSION FIRST
        if (!checkStoragePermission()) {
            return; // wait for permission result
        }

        // ✅ Delete the previously saved file to avoid duplicates
        deleteOldSavedFile();

        try {
            Log.e("17","======>");
            UmengUtil.analysitic(PaintActivity.this, UmengUtil.SAVEIMAGE, URL);
            MyProgressDialog.show(PaintActivity.this, null, getString(R.string.savingimage));
            SaveImageAsyn saveImageAsyn = new SaveImageAsyn(this);
            if (fromSDcard) {
                saveImageAsyn.execute(colourImageView.getmBitmap(), PAINTNAME);
            } else {
                saveImageAsyn.execute(colourImageView.getmBitmap(), ImageSaveUtil.convertImageLageUrl(URL).hashCode());
            }
            saveImageAsyn.setOnSaveSuccessListener(onSaveFinishListener);
        } catch (Exception e) {
            e.printStackTrace();
        }

    }

    private void openSaveImage(int hashCode) {
        try {
            Log.e("18", "======>");
            // ✅ Use Pictures/MyGallaryWorks for Android 10+, MyGallaryWorks for older
            String root;
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                root = Environment.getExternalStoragePublicDirectory(
                        Environment.DIRECTORY_PICTURES).getPath() + "/MyGallaryWorks/";
            } else {
                root = Environment.getExternalStorageDirectory().getPath()
                        + "/MyGallaryWorks/";
            }
            String path = root + hashCode + ".png";
            File file = new File(path);
            if (!file.exists()) {
                throw new Exception("open image failed: " + path);
            }
            Bitmap bMap = BitmapFactory.decodeFile(path);
            colourImageView.setImageBT(bMap);
            Toast.makeText(this, getString(R.string.opensuccess), Toast.LENGTH_SHORT).show();
        } catch (Exception e) {
            L.e(e.toString());
            Toast.makeText(this, getString(R.string.openfailed), Toast.LENGTH_SHORT).show();
        }
    }

    private void deleteOldSavedFile() {
        try {
            int hashCode = fromSDcard
                    ? PAINTNAME
                    : ImageSaveUtil.convertImageLageUrl(URL).hashCode();

            String root;
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                root = Environment.getExternalStoragePublicDirectory(
                        Environment.DIRECTORY_PICTURES).getPath() + "/MyGallaryWorks/";
            } else {
                root = Environment.getExternalStorageDirectory().getPath()
                        + "/MyGallaryWorks/";
            }

            File file = new File(root + hashCode + ".png");
            if (file.exists()) {
                file.delete();
                Log.e("deleteOldSavedFile", "Deleted: " + file.getPath());
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        // Inflate the menu; this adds items to the action bar if it is present.
        return true;
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        // Handle action bar item clicks here. The action bar will
        // automatically handle clicks on the Home/Up button, so long
        // as you specify a parent activity in AndroidManifest.xml.
        int id = item.getItemId();
        return super.onOptionsItemSelected(item);
    }

    @Override
    public void onClick(View view) {
        int color;
        if (Build.VERSION.SDK_INT >= 11) {
            color = ((ColorDrawable) view.getBackground()).getColor();
        } else {
            Bitmap bitmap = Bitmap.createBitmap(1, 1, Bitmap.Config.ARGB_4444);
            Canvas canvas = new Canvas(bitmap);
            view.getBackground().draw(canvas);
            int pix = bitmap.getPixel(0, 0);
            bitmap.recycle();
            color = pix;
        }
        L.e(color + "");
        colorPickerSeekBar.setColor(color);
        changeCurrentColor(color);
    }

    private void changeCurrentColor(int color) {
        setFillColorModel();
        colourImageView.setColor(color);
        currentColor.setImageDrawable(new ColorDrawable(color));
    }

    private void setFillColorModel() {
        pick.setChecked(false);
        drawLine.setChecked(false);
    }


    private void changeCurrentColor(ImageView currentColor) {
        setFillColorModel();
        colorPickerSeekBar.setColor(((ColorDrawable) currentColor.getDrawable()).getColor());
        colourImageView.setColor(((ColorDrawable) currentColor.getDrawable()).getColor());
        isSaved = false;
    }

    @Override
    public void onBackPressed() {
        if (isSaved) {
            finish(); // ✅ Already saved, just exit
            return;
        }
        View.OnClickListener savelistener = new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                DialogInterface.OnDismissListener onCancelListener = new DialogInterface.OnDismissListener() {
                    @Override
                    public void onDismiss(DialogInterface dialogInterface) {
                        saveToLocalandFinish();
                    }
                };
                myDialogFactory.dismissDialog(onCancelListener);
            }
        };
        View.OnClickListener quitlistener = new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                myDialogFactory.dismissDialog();
                finish();
            }
        };
        myDialogFactory.FinishSaveImageDialog(savelistener, quitlistener);
    }

    private void saveToLocalandFinish() {
        try {
            if (!checkStoragePermission()) {
                return; // wait for permission result
            }

            // ✅ Delete the previously saved file to avoid duplicates
            deleteOldSavedFile();

            UmengUtil.analysitic(PaintActivity.this, UmengUtil.SAVEIMAGE, URL);
            MyProgressDialog.show(PaintActivity.this, null, getString(R.string.savingimage));
            SaveImageAsyn saveImageAsyn = new SaveImageAsyn(this);
            if (fromSDcard) {
                saveImageAsyn.execute(colourImageView.getmBitmap(), PAINTNAME);
            } else {
                saveImageAsyn.execute(colourImageView.getmBitmap(), ImageSaveUtil.convertImageLageUrl(URL).hashCode());
            }
            Log.e("20","======>");
            saveImageAsyn.setOnSaveSuccessListener(new SaveImageAsyn.OnSaveFinishListener() {
                @Override
                public void onSaveFinish(String path) {
                    MyProgressDialog.DismissDialog();
                    if (path == null) {
                        Log.e("19","======>");
                        Toast.makeText(PaintActivity.this, "Paint save image failed, save To Local and Finish", Toast.LENGTH_SHORT).show();
                    } else {
                        lastSavedPath = path;
                        isSaved = true;
                        Log.e("main urls 333333==============>",lastSavedPath);
                        Toast.makeText(PaintActivity.this, "" + path, Toast.LENGTH_SHORT).show();
                        finish();
                    }
                }
            });
        } catch (Exception e) {
            e.printStackTrace();
        }
    }


    @Override
    public void onSaveInstanceState(Bundle outState) {
        if (colourImageView != null && colourImageView.getmBitmap() != null) {
            outState.putParcelable("bitmap", (colourImageView.getmBitmap().copy(colourImageView.getmBitmap().getConfig(), true)));
        }
        super.onSaveInstanceState(outState);
    }

    @Override
    protected void onRestoreInstanceState(Bundle savedInstanceState) {
        if (savedInstanceState.getParcelable("bitmap") != null)
            cachedBitmap = savedInstanceState.getParcelable("bitmap");
        super.onRestoreInstanceState(savedInstanceState);
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        if (requestCode == MyApplication.PaintActivityRequest) {
            if (resultCode == MyApplication.RepaintResult) {
                repaint();
            }
        }

    }

    private void repaint() {
        try {
            Log.e("21","======>");
            if (fromSDcard) {
                if (FileUtils.deleteFile(URL)) {
                    finish();
                } else {
                    Toast.makeText(this, getString(R.string.deletePaintFailed), Toast.LENGTH_SHORT).show();
                }
            } else {
                MyProgressDialog.show(this, null, getString(R.string.loadpicture));
                colourImageView.clearStack();
                AsynImageLoader.showLagreImageAsynWithAllCacheOpen(colourImageView, URL, new ImageLoadingListener() {
                    @Override
                    public void onLoadingStarted(String s, View view) {
                        Log.e("22","======>");
                    }

                    @Override
                    public void onLoadingFailed(String s, View view, FailReason failReason) {
                        MyProgressDialog.DismissDialog();
                        Toast.makeText(PaintActivity.this, getString(R.string.loadpicturefailed), Toast.LENGTH_SHORT).show();
                        finish();
                    }

                    @Override
                    public void onLoadingComplete(String s, View view, Bitmap bitmap) {
                        mAttacher = new PhotoViewAttacher(colourImageView, bitmap);
                        MyProgressDialog.DismissDialog();
                    }

                    @Override
                    public void onLoadingCancelled(String s, View view) {
                        MyProgressDialog.DismissDialog();
                        Toast.makeText(PaintActivity.this, getString(R.string.loadpicturefailed), Toast.LENGTH_SHORT).show();
                        finish();
                    }
                });
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    @Override
    protected void onPause() {
        super.onPause();
        setSavedColors(cColor1, cColor2, cColor3, cColor4);
    }

    private void setSavedColors(ImageView cColor1, ImageView cColor2, ImageView cColor3, ImageView cColor4) {
        try {
            SharedPreferencesFactory.saveInteger(this, SharedPreferencesFactory.SavedColor1, ((ColorDrawable) cColor1.getDrawable()).getColor());
            SharedPreferencesFactory.saveInteger(this, SharedPreferencesFactory.SavedColor2, ((ColorDrawable) cColor2.getDrawable()).getColor());
            SharedPreferencesFactory.saveInteger(this, SharedPreferencesFactory.SavedColor3, ((ColorDrawable) cColor3.getDrawable()).getColor());
            SharedPreferencesFactory.saveInteger(this, SharedPreferencesFactory.SavedColor4, ((ColorDrawable) cColor4.getDrawable()).getColor());
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private void getSavedColors(ImageView cColor1, ImageView cColor2, ImageView cColor3, ImageView cColor4) {
        try {
            cColor1.setImageDrawable(new ColorDrawable(SharedPreferencesFactory.getInteger(this, SharedPreferencesFactory.SavedColor1, getResources().getColor(R.color.red))));
            cColor2.setImageDrawable(new ColorDrawable(SharedPreferencesFactory.getInteger(this, SharedPreferencesFactory.SavedColor2, getResources().getColor(R.color.yellow))));
            cColor3.setImageDrawable(new ColorDrawable(SharedPreferencesFactory.getInteger(this, SharedPreferencesFactory.SavedColor3, getResources().getColor(R.color.skyblue))));
            cColor4.setImageDrawable(new ColorDrawable(SharedPreferencesFactory.getInteger(this, SharedPreferencesFactory.SavedColor4, getResources().getColor(R.color.green))));
        } catch (Resources.NotFoundException e) {
            e.printStackTrace();
        }

    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        colourImageView.onRecycleBitmaps();
    }
}