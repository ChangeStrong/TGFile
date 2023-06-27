#
# Be sure to run `pod lib lint TGFile.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'TGFile'
  s.version          = '0.1.0'
  s.summary          = 'A short description of TGFile.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/ChangeStrong/TGFile'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'ChangeStrong' => '491337430@qq.com' }
  s.source           = { :git => 'https://github.com/ChangeStrong/TGFile.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'
  s.swift_version           = '5.0'
  s.ios.deployment_target = '13.0'

  s.source_files = 'TGFile/Classes/**/*.{h,m,mm,swift,c}'
  
  # s.resource_bundles = {
  #   'TGFile' => ['TGFile/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
  s.dependency 'TGSPublic'
  s.dependency 'SSZipArchive'
  s.dependency 'UnrarKit'
  s.dependency 'LzmaSDK-ObjC'
  
  
end
