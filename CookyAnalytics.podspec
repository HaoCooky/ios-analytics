#
# Be sure to run `pod lib lint DIAnalyticsSDK.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'CookyAnalytics'
  s.version          = '0.1.0'
  s.summary          = 'Cooky Analytics SDK for iOS test test.'

  s.description      = <<-DESC
  Cooky Analytics SDK for IOS
                       DESC

  s.homepage         = 'https://github.com/HaoCooky/ios-analytics'
  s.license          = { :type => 'CC BY 4.0', :file => 'LICENSE' }
  s.author           = { 'haonn' => 'haonguyennhat97@gmail.com' }
  s.source           = { :git => 'https://github.com/HaoCooky/ios-analytics.git', :tag => s.version.to_s }
  

  s.ios.deployment_target = '9.0'

  s.source_files = 'CookyAnalytics/Classes/**/*.{h,m,swift}'
  s.swift_versions = ['4.2', '5.0']
  s.framework        = 'SystemConfiguration', 'CoreTelephony'
  
  s.test_spec 'Tests' do |test_spec|
    test_spec.source_files = 'CookyAnalytics/Tests/**/*.{swift}'
  end
end
