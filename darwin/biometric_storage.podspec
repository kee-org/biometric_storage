#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint biometric_storage.podspec' to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'biometric_storage'
  s.version          = '0.0.1'
  s.summary          = 'Secure Storage: Encrypted data store optionally secured by biometric lock.'
  s.description      = <<-DESC
Secure Storage: Encrypted data store optionally secured by biometric lock with support
for iOS, Android, MacOS.
                       DESC
  s.homepage         = 'https://github.com/authpass/biometric_storage/'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'design.codeux' => 'info@codeux.design' }
  s.source           = { :path => '.' }
  s.source_files = 'biometric_storage/Sources/biometric_storage/**/*.swift'

  s.ios.dependency 'Flutter'
  s.osx.dependency 'FlutterMacOS'
  s.ios.deployment_target = '13.0'
  s.osx.deployment_target = '10.14'

  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
  s.swift_version = '5.0'
end
