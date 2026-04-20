Pod::Spec.new do |s|
  s.name             = 'Thunder'
  s.version          = '0.0.0'
  s.summary          = 'Thunder iOS SDK'
  s.description      = <<-DESC
    Native iOS SDK for Thunder identity management.
  DESC
  s.homepage         = 'https://thunderid.dev'
  s.license          = { :type => 'Apache License 2.0', :file => '../LICENSE' }
  s.author           = { 'Thunder' => 'dev@thunderid.dev' }
  s.source           = { :path => '.' }
  s.source_files     = 'Sources/Thunder/**/*.swift'
  s.platform         = :ios, '16.0'
  s.swift_version    = '5.9'
end
