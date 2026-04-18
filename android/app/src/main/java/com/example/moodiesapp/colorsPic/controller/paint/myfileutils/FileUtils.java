package com.example.moodiesapp.colorsPic.controller.paint.myfileutils;



import android.content.Context;
import android.database.Cursor;
import android.net.Uri;
import android.os.Build;
import android.os.Environment;
import android.provider.MediaStore;
import android.util.Log;

import com.example.moodiesapp.colorsPic.model.bean.LocalImageBean;

import java.io.File;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.Locale;

public class FileUtils {

    // ── Context needed for Android 10+ ────────────────────────────
    private static Context appContext;

    public static void init(Context context) {
        appContext = context.getApplicationContext();
    }

    // ── Main method called by UserFragmentModel ────────────────────
    public static List<LocalImageBean> obtainLocalImages() {
        if (appContext == null) {
            Log.e("FileUtils","FileUtils context is null!");
            return new ArrayList<>();
        }

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            // Android 10+
            return obtainLocalImagesAndroid10(appContext);
        } else {
            // Android 9 and below
            return obtainLocalImagesLegacy();
        }
    }

    // ── Android 10+ read via MediaStore ───────────────────────────
    private static List<LocalImageBean> obtainLocalImagesAndroid10(
            Context context) {

        List<LocalImageBean> list = new ArrayList<>();

        try {
            Uri collection =
                    MediaStore.Images.Media.EXTERNAL_CONTENT_URI;

            String[] projection = {
                    MediaStore.Images.Media._ID,
                    MediaStore.Images.Media.DISPLAY_NAME,
                    MediaStore.Images.Media.DATA,
                    MediaStore.Images.Media.WIDTH,
                    MediaStore.Images.Media.HEIGHT,
                    MediaStore.Images.Media.DATE_MODIFIED
            };

            // Filter only MyGallaryWorks folder images
            String selection =
                    MediaStore.Images.Media.RELATIVE_PATH
                            + " LIKE ?";
            String[] selectionArgs = {"%MyGallaryWorks%"};

            String sortOrder =
                    MediaStore.Images.Media.DATE_MODIFIED
                            + " DESC";

            Cursor cursor = context.getContentResolver().query(
                    collection,
                    projection,
                    selection,
                    selectionArgs,
                    sortOrder
            );

            if (cursor != null && cursor.moveToFirst()) {
                int nameCol = cursor.getColumnIndexOrThrow(
                        MediaStore.Images.Media.DISPLAY_NAME);
                int dataCol = cursor.getColumnIndexOrThrow(
                        MediaStore.Images.Media.DATA);
                int widthCol = cursor.getColumnIndexOrThrow(
                        MediaStore.Images.Media.WIDTH);
                int heightCol = cursor.getColumnIndexOrThrow(
                        MediaStore.Images.Media.HEIGHT);
                int dateCol = cursor.getColumnIndexOrThrow(
                        MediaStore.Images.Media.DATE_MODIFIED);

                do {
                    String name     = cursor.getString(nameCol);
                    String filePath = cursor.getString(dataCol);
                    int width       = cursor.getInt(widthCol);
                    int height      = cursor.getInt(heightCol);
                    long dateMs     = cursor.getLong(dateCol) * 1000L;

                    if (filePath == null) continue;

                    // Build bean
                    LocalImageBean bean = new LocalImageBean();
                    bean.setImageUrl(filePath);
                    bean.setImageName(name);

                    // width/height ratio
                    float ratio = (height > 0)
                            ? (float) width / height
                            : 1.0f;
                    bean.setWvHRadio(ratio);

                    // Format date
                    String dateStr = new SimpleDateFormat(
                            "yyyy-MM-dd HH:mm",
                            Locale.getDefault())
                            .format(new Date(dateMs));
                    bean.setLastModDate(dateStr);

                    list.add(bean);

                } while (cursor.moveToNext());

                cursor.close();
            } else {
                Log.e("FileUtils","MediaStore cursor is null or empty");
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        Log.e("FileUtils","Android10 local images count: " + list.size());
        return list;
    }

    // ── Android 9 and below read via File ──────────────────────────
    private static List<LocalImageBean> obtainLocalImagesLegacy() {
        List<LocalImageBean> list = new ArrayList<>();

        try {
            String root =
                    Environment.getExternalStorageDirectory()
                            .getPath() + "/MyGallaryWorks/";
            File dir = new File(root);

            Log.e("FileUtils","Legacy path: " + root);
            Log.e("FileUtils","Dir exists: " + dir.exists());

            if (!dir.exists()) {
                Log.e("FileUtils","MyGallaryWorks directory not found!");
                return list;
            }

            File[] files = dir.listFiles();
            if (files == null || files.length == 0) {
                Log.e("FileUtils","No files in MyGallaryWorks!");
                return list;
            }

            SimpleDateFormat sdf = new SimpleDateFormat(
                    "yyyy-MM-dd HH:mm", Locale.getDefault());

            for (File file : files) {
                if (file.isFile()
                        && file.getName().endsWith(".png")) {

                    LocalImageBean bean = new LocalImageBean();
                    bean.setImageUrl(file.getAbsolutePath());
                    bean.setImageName(file.getName());
                    bean.setLastModDate(
                            sdf.format(new Date(
                                    file.lastModified())));

                    // Get width/height ratio
                    android.graphics.BitmapFactory.Options opts =
                            new android.graphics.BitmapFactory
                                    .Options();
                    opts.inJustDecodeBounds = true;
                    android.graphics.BitmapFactory.decodeFile(
                            file.getAbsolutePath(), opts);

                    float ratio = (opts.outHeight > 0)
                            ? (float) opts.outWidth / opts.outHeight
                            : 1.0f;
                    bean.setWvHRadio(ratio);

                    list.add(bean);
                    Log.e("FileUtils","Found file: " + file.getName());
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        Log.e("FileUtils","Legacy local images count: " + list.size());
        return list;
    }

    // ── Delete file ────────────────────────────────────────────────
    public static boolean deleteFile(String path) {
        try {
            File file = new File(path);
            if (file.exists()) {
                return file.delete();
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }
}