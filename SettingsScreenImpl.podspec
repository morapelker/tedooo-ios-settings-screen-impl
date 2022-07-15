#
# Be sure to run `pod lib lint SettingsScreenImpl.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'SettingsScreenImpl'
  s.version          = '1.0.1'
  s.summary          = 'SettingsScreenImpl'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
SettingsScreenImpl
                       DESC

  s.homepage         = 'https://github.com/morapelker/tedooo-ios-settings-screen-impl'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'morapelker' => 'morapelker@gmail.com' }
  s.source           = { :git => 'https://github.com/morapelker/tedooo-ios-settings-screen-impl.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '13.0'

  s.source_files = 'SettingsScreenImpl/Classes/**/*'
  s.swift_version = '5.0'
  # s.resource_bundles = {
  #   'SettingsScreenImpl' => ['SettingsScreenImpl/Assets/*.png']
  # }

  s.dependency 'Swinject'
  s.dependency 'TedoooCombine'
  s.dependency 'SettingsApi'
  s.dependency 'LoginProviderApi'
  s.dependency 'Kingfisher'
  s.dependency 'SettingsLegacyScreens'
  s.dependency 'TedoooStyling'
  s.dependency 'TedoooImagePicker'
  s.dependency 'TedoooRestApi'
  s.dependency 'TedoooFullScreenHud'
  
  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
