package com.example.moodiesapp.colorsPic.controller.paint;

import android.content.Context;
import android.database.Cursor;
import android.net.Uri;
import android.os.Build;
import android.os.Environment;
import android.provider.MediaStore;

import java.io.File;
import java.util.ArrayList;
import java.util.List;

public class MyPaintsLoader {

    // ── Get all saved paint images ─────────────────────────────────
    public static List<String> loadSavedPaints(Context context) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            // Android 10+ use MediaStore
            return loadFromMediaStore(context);
        } else {
            // Android 9 and below use File path
            return loadFromFileSystem();
        }
    }

    // ── Android 10+ ───────────────────────────────────────────────
    private static List<String> loadFromMediaStore(Context context) {
        List<String> imageList = new ArrayList<>();

        try {
            Uri collection = MediaStore.Images.Media.EXTERNAL_CONTENT_URI;

            String[] projection = {
                    MediaStore.Images.Media._ID,
                    MediaStore.Images.Media.DISPLAY_NAME,
                    MediaStore.Images.Media.RELATIVE_PATH,
                    MediaStore.Images.Media.DATA  // real file path
            };

            // Filter only MyGallaryWorks folder
            String selection = MediaStore.Images.Media.RELATIVE_PATH
                    + " LIKE ?";
            String[] selectionArgs = {
                    "%MyGallaryWorks%"
            };

            String sortOrder = MediaStore.Images.Media.DATE_ADDED
                    + " DESC";

            Cursor cursor = context.getContentResolver().query(
                    collection,
                    projection,
                    selection,
                    selectionArgs,
                    sortOrder
            );

            if (cursor != null) {
                int dataColumn = cursor.getColumnIndexOrThrow(
                        MediaStore.Images.Media.DATA);

                while (cursor.moveToNext()) {
                    String filePath = cursor.getString(dataColumn);
                    if (filePath != null) {
                        imageList.add(filePath);
                    }
                }
                cursor.close();
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return imageList;
    }

    // ── Android 9 and below ───────────────────────────────────────
    private static List<String> loadFromFileSystem() {
        List<String> imageList = new ArrayList<>();

        try {
            String root = Environment.getExternalStorageDirectory()
                    .getPath() + "/MyGallaryWorks/";
            File dir = new File(root);

            if (!dir.exists()) {
                return imageList; // empty list
            }

            File[] files = dir.listFiles();
            if (files == null) return imageList;

            for (File file : files) {
                if (file.isFile()
                        && file.getName().endsWith(".png")) {
                    imageList.add(file.getAbsolutePath());
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return imageList;
    }

    // ── Delete a paint image ───────────────────────────────────────
    public static boolean deletePaint(Context context, String filePath) {
        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                // Android 10+ delete via MediaStore
                Uri collection =
                        MediaStore.Images.Media.EXTERNAL_CONTENT_URI;
                String selection =
                        MediaStore.Images.Media.DATA + " = ?";
                String[] selectionArgs = {filePath};

                int deleted = context.getContentResolver().delete(
                        collection, selection, selectionArgs);
                return deleted > 0;
            } else {
                // Android 9 and below
                File file = new File(filePath);
                return file.exists() && file.delete();
            }
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }
}