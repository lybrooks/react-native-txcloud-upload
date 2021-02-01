
# react-native-txcloudupload

## Getting started

`$ npm install react-native-txcloudupload --save`

### Mostly automatic installation

`$ react-native link react-native-txcloudupload`(reactnative version< 0.60)

### Manual installation


#### iOS

1. In XCode, in the project navigator, right click `Libraries` ➜ `Add Files to [your project's name]`
2. Go to `node_modules` ➜ `react-native-txcloudupload` and add `RNTxcloudupload.xcodeproj`
3. In XCode, in the project navigator, select your project. Add `libRNTxcloudupload.a` to your project's `Build Phases` ➜ `Link Binary With Libraries`
4. Run your project (`Cmd+R`)

#### Android

1. Open up `android/app/src/main/java/[...]/MainActivity.java`
  - Add `import com.geek.txcloudupload.RNTxclouduploadPackage;` to the imports at the top of the file
  - Add `new RNTxclouduploadPackage()` to the list returned by the `getPackages()` method
2. Append the following lines to `android/settings.gradle`:
  	```
  	include ':react-native-txcloudupload'
  	project(':react-native-txcloudupload').projectDir = new File(rootProject.projectDir, 	'../node_modules/react-native-txcloudupload/android')
  	```
3. Insert the following lines inside the dependencies block in `android/app/build.gradle`:
  	```
      compile project(':react-native-txcloudupload')
  	```


## Usage
```javascript
import RNTxcloudupload from 'react-native-txcloudupload';
1. 获取临时签名文件

2. 
/**
  * @param {*} file 文件uri
  * @param {*} name 文件名
  * @param {*} credent 临时签名
  * @param {*} bucketName 存储桶名称
  * @param {*} regionName 地区
  * @param {*} processCb 进度回调
  * @param {*} resultCb 上传结果回调
*/
 RNTxcloudupload.uploadFile(file, name, credent, bucketName, regionName, processCb, resultCb)

// TODO: What to do with the module?
RNTxcloudupload;
```
  