
Pod::Spec.new do |s|
  s.name         = "RNTxcloudupload"
  s.version      = "1.0.0"
  s.summary      = "RNTxcloudupload"
  s.description  = <<-DESC
                  RNTxcloudupload
                   DESC
  s.homepage     = "https://dev.jiuaoedu.com/liuyang/react-native-txcloudupload"
  s.license      = "MIT"
  # s.license      = { :type => "MIT", :file => "FILE_LICENSE" }
  s.author             = { "author" => "author@domain.cn" }
  s.platform     = :ios, "7.0"
  s.source       = { :git => "https://github.com/author/RNTxcloudupload.git", :tag => "master" }
  s.source_files  = "*.{h,m}"
  s.requires_arc = true


  s.dependency "React"
  s.dependency "QCloudCOSXML/Transfer"
  #s.dependency "others"

end

  