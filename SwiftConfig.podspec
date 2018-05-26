#
# Be sure to run `pod lib lint SwiftConfig.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'SwiftConfig'
  s.version          = '0.1.0'
  s.summary          = 'A simple, object-oriented wrapper for SystemConfiguration.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
  SwiftConfig is simple, object-oriented wrapper for SystemConfiguration. Forget dealing with pointers, long function names without parameters, and countless type conversions: SwiftConfig provides a pure-Swift interface to almost all functions in the SystemConfiguration framework.
                       DESC

  s.homepage         = 'https://github.com/Coder-256/SwiftConfig'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Jacob Greenfield' => 'jacob@jacobgreenfield.me' }
  s.source           = { :git => 'https://github.com/Coder-256/SwiftConfig.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.platform = :osx
  s.osx.deployment_target = "10.12"
  s.swift_version = '4.1'

  s.source_files = 'SwiftConfig/Classes/**/*'

  # s.resource_bundles = {
  #   'SwiftConfig' => ['SwiftConfig/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'Cocoa'
  # s.dependency 'AFNetworking', '~> 2.3'
end
