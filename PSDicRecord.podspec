#
# Be sure to run `pod lib lint PSDicRecord.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "PSDicRecord"
  s.version          = "1.0.2"
  s.summary          = "PSDicRecord."

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
  Objective-C 极速ORM
                       DESC

  s.homepage         = "https://github.com/alan-yeh/PSDicRecord"
  s.license          = 'MIT'
  s.author           = { "Alan Yeh" => "git@yerl.cn" }
  s.source           = { :git => "https://github.com/alan-yeh/PSDicRecord.git", :tag => s.version.to_s }

  s.ios.deployment_target = '8.0'

  s.source_files = 'PSDicRecord/Classes/**/*'
  s.public_header_files = 'PSDicRecord/Classes/*.h', 'PSDicRecord/Classes/Container/*.h'
  s.libraries = 'sqlite3'
end
