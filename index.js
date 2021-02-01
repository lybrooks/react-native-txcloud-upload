import {
    NativeModules,
    NativeEventEmitter,
    Platform
  } from 'react-native'  
  const { RNTxcloudupload } = NativeModules
    
  /**
   * 
   * @param {*} file 文件uri
   * @param {*} name 文件名
   * @param {*} credent 临时签名
   * @param {*} bucketName 存储桶名称
   * @param {*} regionName 地区
   * @param {*} processCb 进度回调
   * @param {*} resultCb 上传结果回调
   */
  const uploadFile = async (file, name,credent,bucketName,regionName,processCb,resultCb) => {
    const { GeekUploadEmitter } = NativeModules
    try {
      const emitter = new NativeEventEmitter(GeekUploadEmitter)
      emitter.addListener('uploadProgress', (progressData) => {
       const  progress = Platform.OS ==='ios' ? progressData : JSON.parse(progressData)
       processCb && processCb({
           progress
        })
      })
      const { credentials, startTime, expiredTime, dir } = credent || {}
      const { tmpSecretId, tmpSecretKey, sessionToken } = credentials || {}
      let dirName = name
      if (Platform.OS === 'ios') {
        const config = {
          tmpSecretId,
          tmpSecretKey,
          sessionToken,
          startTime,
          expiredTime,
          bucketName: bucketName,
          dir,
          regionName: regionName
        }
        dirName = name
        RNTxcloudupload.config(config)
        RNTxcloudupload.uploadFile(file, dirName, (res, err) => {
          if (processCb) {
            processCb({
              res,
              error: err
            })
          }
        })
      } else {
        dirName = dir || '' + name || ''
        RNTxcloudupload.config(tmpSecretId, tmpSecretKey, sessionToken, startTime, expiredTime, regionName)
        RNTxcloudupload.uploadFile(file, dirName, bucketName, (res, err) => {
          if (resultCb) {
            resultCb({
              res,
              error: err
            })
          }
        })
      }
    } catch (error) {
      console.log(error)
      resultCb && resultCb({
        error
      })
    }
  }
  
  export default {
    RNTxcloudupload,
    uploadFile
  }
  