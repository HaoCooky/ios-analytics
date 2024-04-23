#
# Be sure to run `pod lib lint DIAnalyticsSDK.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'DIAnalyticsSDK'
  s.version          = '0.1.2'
  s.summary          = 'DI Analytics SDK for iOS.'

  s.description      = <<-DESC
  Data Insider Analytics SDK for IOS
                       DESC

  s.homepage         = 'https://gitlab.com/liemvouy/di-ios-analytics'
  s.license          = { :type => 'CC BY 4.0', :file => 'LICENSE' }
  s.author           = { 'liemvu' => 'liemvouy@gmail.com' }
  s.source           = { :git => 'https://gitlab.com/liemvouy/di-ios-analytics.git', :tag => s.version.to_s }
  

  s.ios.deployment_target = '9.0'

  s.source_files = 'DIAnalytics/Classes/**/*.{h,m,swift}'
  s.swift_versions = ['4.2', '5.0']
  s.framework        = 'SystemConfiguration', 'CoreTelephony'
  
  s.test_spec 'Tests' do |test_spec|
    test_spec.source_files = 'DIAnalytics/Tests/**/*.{swift}'
  end
end
