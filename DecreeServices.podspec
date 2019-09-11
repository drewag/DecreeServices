Pod::Spec.new do |spec|
  spec.name          = 'DecreeServices'
  spec.version       = '4.2.0'
  spec.license       = { :type => 'MIT', :file => "LICENSE" }
  spec.homepage      = 'https://github.com/drewag/DecreeServices'
  spec.authors       = { 'Andrew J. Wagner' => 'https://drewag.me' }
  spec.summary       = 'Service Declarations for Decree'
  spec.source        = { :git => 'https://github.com/drewag/DecreeServices.git', :tag => spec.version.to_s }
  spec.swift_version = '5.0.1'

  spec.ios.deployment_target  = '9.0'
  spec.osx.deployment_target  = '10.11'
  spec.tvos.deployment_target  = '9.0'

  spec.source_files       = 'Sources/DecreeServices/**/*.swift'

  spec.dependency 'Decree', '= 4.2.0'
  spec.dependency 'CryptoSwift', '~> 1.0.0'
end
