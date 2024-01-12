#
# Be sure to run `pod lib lint RSTwitterKit.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'RSTwitterKit'
  s.version          = '0.1.0'
  s.summary          = 'RSTwitterKit.'
  
  s.description      = <<-DESC
SDK for Twitter API.
                       DESC

  s.homepage         = 'https://github.com/Ron-Samkulami/RSTwitterKit'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Ron-Samkulami' => 'ronsamkulami95@gmail.com' }
  s.source           = { :git => 'https://github.com/Ron-Samkulami/RSTwitterKit.git', :tag => s.version.to_s }

  s.ios.deployment_target = '12.0'

  s.source_files = 'RSTwitterKit/RSTwitterKit_Products/*.framework/Headers/*'
  s.public_header_files = 'RSTwitterKit/RSTwitterKit_Products/*.framework/Headers/*'
  s.ios.vendored_frameworks = 'RSTwitterKit/RSTwitterKit_Products/*.framework'
end
