Pod::Spec.new do |s|
  s.name             = 'RxEndpoints'
  s.version          = '1.0.4'
	s.summary 				 = 'Reactive API library written in Swift'
  s.homepage         = 'https://github.com/martindaum/RxEndpoints'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'martindaum' => 'office@martindaum.com' }
  s.source           = { :git => 'https://github.com/martindaum/RxEndpoints.git', :tag => s.version.to_s }

  s.ios.deployment_target = '8.0'
  s.osx.deployment_target = '10.10'
  s.tvos.deployment_target = '9.0'
  s.watchos.deployment_target = '2.0'

  s.source_files = 'RxEndpoints/Classes/**/*'
  s.swift_version = '4.2'
  s.dependency 'Alamofire', '~> 4.0'
  s.dependency 'RxSwift', '~> 4.0'
end
