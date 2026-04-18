//package com.example.moodiesapp.colorsPic.model;
package com.example.moodiesapp.colorsPic.model;

import android.content.ContentValues;
import android.content.Context;
import android.graphics.Bitmap;
import android.net.Uri;
import android.os.AsyncTask;
import android.os.Build;
import android.os.Environment;
import android.provider.MediaStore;

import com.example.moodiesapp.colorsPic.util.L;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.OutputStream;

public class SaveImageAsyn extends AsyncTask {

    private OnSaveFinishListener onSaveFinishListener;
    private String path;
    private String name;
    private Context context; // ADD context

    // ADD context parameter
    public SaveImageAsyn(Context context) {
        this.context = context;
    }

    @Override
    protected Object doInBackground(Object[] objects) {
        Bitmap bmp = (Bitmap) objects[0];
        name = objects[1] + ".png";

        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                // Android 10+ use MediaStore
                return saveImageAndroid10(bmp);
            } else {
                // Android 9 and below
                return saveImageLegacy(bmp);
            }
        } catch (Exception e) {
            L.e(e.getMessage());
            return "FAILED";
        }
    }

    // ── Android 10+ ───────────────────────────────────────────────

    // ── Android 9 and below ───────────────────────────────────────
    private String saveImageLegacy(Bitmap bmp) {
        path = Environment.getExternalStorageDirectory().getPath()
                + "/MyGallaryWorks/";
        File dir = new File(path);
        if (!dir.exists()) dir.mkdirs();

        File file = new File(dir, name);
        FileOutputStream out = null;
        try {
            out = new FileOutputStream(file);
            bmp.compress(Bitmap.CompressFormat.PNG, 100, out);
            out.close();
            return "SUCCESS";
        } catch (Exception e) {
            if (out != null) {
                try { out.close(); }
                catch (IOException e1) { L.e(e1.getMessage()); }
            }
            L.e(e.getMessage());
            return "FAILED";
        }
    }

    @Override
    protected void onPostExecute(Object o) {
        super.onPostExecute(o);
        if ("SUCCESS".equals(o)) {
            if (onSaveFinishListener != null) {
                onSaveFinishListener.onSaveFinish(path + name);
            }
        } else {
            if (onSaveFinishListener != null) {
                onSaveFinishListener.onSaveFinish(null);
            }
        }
    }

    public interface OnSaveFinishListener {
        void onSaveFinish(String path);
    }

    public void setOnSaveSuccessListener(
            OnSaveFinishListener onSaveFinishListener) {
        this.onSaveFinishListener = onSaveFinishListener;
    }


    //
    private String saveImageAndroid10(Bitmap bmp) {
        try {
            // ✅ DELETE old entry first to avoid (1), (2) duplicates
            Uri existingUri = findExistingImageUri(name);
            if (existingUri != null) {
                context.getContentResolver().delete(existingUri, null, null);
            }

            ContentValues values = new ContentValues();
            values.put(MediaStore.Images.Media.DISPLAY_NAME, name);
            values.put(MediaStore.Images.Media.MIME_TYPE, "image/png");
            values.put(MediaStore.Images.Media.RELATIVE_PATH,
                    Environment.DIRECTORY_PICTURES + "/MyGallaryWorks");

            Uri uri = context.getContentResolver()
                    .insert(MediaStore.Images.Media.EXTERNAL_CONTENT_URI, values);

            if (uri == null) return "FAILED";

            OutputStream out = context.getContentResolver().openOutputStream(uri);
            if (out == null) return "FAILED";

            bmp.compress(Bitmap.CompressFormat.PNG, 100, out);
            out.close();

            path = Environment.getExternalStoragePublicDirectory(
                    Environment.DIRECTORY_PICTURES).getPath() + "/MyGallaryWorks/";

            return "SUCCESS";

        } catch (Exception e) {
            L.e(e.getMessage());
            return "FAILED";
        }
    }

    // ✅ Find existing MediaStore entry by filename
    private Uri findExistingImageUri(String fileName) {
        Uri collection = MediaStore.Images.Media.EXTERNAL_CONTENT_URI;
        String[] projection = {MediaStore.Images.Media._ID};
        String selection = MediaStore.Images.Media.DISPLAY_NAME + " = ? AND "
                + MediaStore.Images.Media.RELATIVE_PATH + " = ?";
        String[] selectionArgs = {
                fileName,
                Environment.DIRECTORY_PICTURES + "/MyGallaryWorks/"
        };

        try (android.database.Cursor cursor = context.getContentResolver().query(
                collection, projection, selection, selectionArgs, null)) {
            if (cursor != null && cursor.moveToFirst()) {
                long id = cursor.getLong(
                        cursor.getColumnIndexOrThrow(MediaStore.Images.Media._ID));
                return Uri.withAppendedPath(collection, String.valueOf(id));
            }
        } catch (Exception e) {
            L.e(e.getMessage());
        }
        return null;
    }
}