
package com.geek.txcloudupload;

import android.net.Uri;
import android.util.Log;

import androidx.annotation.Nullable;

import com.facebook.react.bridge.Callback;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.modules.core.DeviceEventManagerModule;
import com.tencent.cos.xml.CosXmlService;
import com.tencent.cos.xml.CosXmlServiceConfig;
import com.tencent.cos.xml.exception.CosXmlClientException;
import com.tencent.cos.xml.exception.CosXmlServiceException;
import com.tencent.cos.xml.listener.CosXmlProgressListener;
import com.tencent.cos.xml.listener.CosXmlResultListener;
import com.tencent.cos.xml.model.CosXmlRequest;
import com.tencent.cos.xml.model.CosXmlResult;
import com.tencent.cos.xml.transfer.COSXMLUploadTask;
import com.tencent.cos.xml.transfer.TransferConfig;
import com.tencent.cos.xml.transfer.TransferManager;
import com.tencent.cos.xml.transfer.TransferState;
import com.tencent.cos.xml.transfer.TransferStateListener;
import com.tencent.qcloud.core.auth.BasicLifecycleCredentialProvider;
import com.tencent.qcloud.core.auth.QCloudCredentialProvider;
import com.tencent.qcloud.core.auth.QCloudLifecycleCredentials;
import com.tencent.qcloud.core.auth.SessionQCloudCredentials;
import com.tencent.qcloud.core.common.QCloudClientException;

import java.io.BufferedInputStream;
import java.io.BufferedOutputStream;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;

public class RNTxclouduploadModule extends ReactContextBaseJavaModule {


    private final ReactApplicationContext reactContext;
    private CosXmlService cosXmlService;

    public RNTxclouduploadModule(ReactApplicationContext reactContext) {
        super(reactContext);
        this.reactContext = reactContext;
    }

    @Override
    public String getName() {
        return "RNTxcloudupload";
    }

    @ReactMethod
    public void config(String tmpSecretId, String tmpSecretKey, String sessionToken, int startTime, int expiredTime, String regionName) {
        QCloudCredentialProvider myCredentialProvider = new MySessionCredentialProvider(tmpSecretId, tmpSecretKey,
                sessionToken, Long.valueOf(expiredTime), Long.valueOf(startTime));
        // 创建 CosXmlServiceConfig 对象，根据需要修改默认的配置参数
        CosXmlServiceConfig serviceConfig = new CosXmlServiceConfig.Builder()
                .setRegion(regionName)
                .isHttps(true) // 使用 HTTPS 请求, 默认为 HTTP 请求
                .builder();
        // 初始化 COS Service，获取实例
        cosXmlService = new CosXmlService(reactContext,
                serviceConfig, myCredentialProvider);

    }

    private void sendEvent(String eventName, @Nullable String params) {
        reactContext.getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class)
                .emit(eventName, params);
    }

    @ReactMethod
    public void uploadFile(String file, String name, String bucketName, final Callback callback) {
        Uri localUri = Uri.parse(file);

        String fileName = getFileName(localUri);
        File rootDataDir = reactContext.getExternalFilesDir(null);
        final File copyFile = new File(rootDataDir + File.separator + fileName);
        copyFile(reactContext, localUri, copyFile);
        //        String srcPath = new File(reactContext.getCacheDir(), "exampleobject")
        //       ;          .toString()
        String abSolutePath = copyFile.getAbsolutePath();//本地文件的绝对路径

        TransferConfig transferConfig = new TransferConfig.Builder().build();
        // 初始化 TransferManager
        TransferManager transferManager = new TransferManager(cosXmlService,
                transferConfig);
        String bucket = bucketName; //存储桶，格式：BucketName-APPID
        String cosPath = name; //对象在存储桶中的位置标识符，即称对象键

        //若存在初始化分块上传的 UploadId，则赋值对应的 uploadId 值用于续传；否则，赋值 null
        String uploadId = null;
        // 上传文件
        COSXMLUploadTask cosxmlUploadTask = transferManager.upload(bucket, cosPath,
                abSolutePath, uploadId);
        //设置上传进度回调
        cosxmlUploadTask.setCosXmlProgressListener(new CosXmlProgressListener() {
            @Override
            public void onProgress(long complete, long target) {
                // todo Do something to update progress...
                Log.e("main", "onProgress" + complete + "===" + target);
                String progressData = "{" +
                        "\"complete\":" + complete +
                        ",\"target\":" + target +
                        '}';
                sendEvent("uploadProgress", progressData);
            }
        });
        //设置返回结果回调
        cosxmlUploadTask.setCosXmlResultListener(new CosXmlResultListener() {
            @Override
            public void onSuccess(CosXmlRequest request, CosXmlResult result) {
                COSXMLUploadTask.COSXMLUploadTaskResult cOSXMLUploadTaskResult =
                        (COSXMLUploadTask.COSXMLUploadTaskResult) result;
                Log.e("main", "accessUrl:" + cOSXMLUploadTaskResult.accessUrl);
                callback.invoke(cOSXMLUploadTaskResult.accessUrl);
                deleteFile(copyFile);

            }

            @Override
            public void onFail(CosXmlRequest request,
                               CosXmlClientException clientException,
                               CosXmlServiceException serviceException) {
                deleteFile(copyFile);
                if (clientException != null) {
                    clientException.printStackTrace();
                } else {
                    serviceException.printStackTrace();
                }
            }
        });
        //设置任务状态回调, 可以查看任务过程
        cosxmlUploadTask.setTransferStateListener(new TransferStateListener() {
            @Override
            public void onStateChanged(TransferState state) {
                // todo notify transfer state
                Log.e("main", "----------------state" + state.toString());
            }
        });

    }

    public  boolean deleteFile(File file) {
        if (file.exists() && file.isFile()) {
            if (file.delete()) {
                System.out.println("删除成功！");
                return true;
            } else {
                System.out.println("删除失败！");
                return false;
            }
        } else {
            System.out.println("文件不存在！");
            return false;
        }
    }


    public static class MySessionCredentialProvider
            extends BasicLifecycleCredentialProvider {

        String tmpSecretId = "COS_SECRETID"; // 临时密钥 SecretId
        String tmpSecretKey = "COS_SECRETKEY"; // 临时密钥 SecretKey
        String sessionToken = "COS_SESSIONTOKEN"; // 临时密钥 Token
        long expiredTime = 1556183496L;//临时密钥有效截止时间戳，单位是秒
        //建议返回服务器时间作为签名的开始时间，避免由于用户手机本地时间偏差过大导致请求过期
        // 返回服务器时间作为签名的起始时间
        long startTime = 1556182000L; //临时密钥有效起始时间，单位是秒

        public MySessionCredentialProvider(String tmpSecretId, String tmpSecretKey, String sessionToken, long expiredTime, long startTime) {
            this.tmpSecretId = tmpSecretId;
            this.tmpSecretKey = tmpSecretKey;
            this.sessionToken = sessionToken;
            this.expiredTime = expiredTime;
            this.startTime = startTime;
        }

        @Override
        protected QCloudLifecycleCredentials fetchNewCredentials()
                throws QCloudClientException {
            // 最后返回临时密钥信息对象
            return new SessionQCloudCredentials(tmpSecretId, tmpSecretKey,
                    sessionToken, startTime, expiredTime);
        }
    }


    private void copyFile(ReactApplicationContext reactContext, Uri srcUri, File dstFile) {
        try {
            InputStream inputStream = reactContext.getContentResolver().openInputStream(srcUri);
            if (inputStream == null) return;
            OutputStream outputStream = new FileOutputStream(dstFile);
            copyStream(inputStream, outputStream);
            inputStream.close();
            outputStream.close();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private int copyStream(InputStream input, OutputStream output) throws IOException {
        final int BUFFER_SIZE = 1024 * 2;
        byte[] buffer = new byte[BUFFER_SIZE];
        BufferedInputStream in = new BufferedInputStream(input, BUFFER_SIZE);
        BufferedOutputStream out = new BufferedOutputStream(output, BUFFER_SIZE);
        int count = 0, n = 0;
        try {
            while ((n = in.read(buffer, 0, BUFFER_SIZE)) != -1) {
                out.write(buffer, 0, n);
                count += n;
            }
            out.flush();
        } finally {
            try {
                out.close();
            } catch (IOException e) {
            }
            try {
                in.close();
            } catch (IOException e) {
            }
        }
        return count;
    }

    private String getFileName(Uri uri) {
        if (uri == null) return null;
        String fileName = null;
        String path = uri.getPath();
        int cut = path.lastIndexOf('/');
        if (cut != -1) {
            fileName = path.substring(cut + 1);
        }
        return fileName;
    }
}