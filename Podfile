# Uncomment the next line to define a global platform for your project
platform :ios, '15.0'



target 'MeloMeter' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for MeloMeter
  pod 'NMapsMap'
  pod 'AnyFormatKit'
  pod 'RxSwift'
  pod 'RxCocoa'
  pod 'RxGesture'
  pod 'KakaoSDK'
  pod 'Kingfisher', '~> 5.0'

post_install do |installer|
    installer.pods_project.targets.each do |target|
      target.build_configurations.each do |config|
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '15.0'  // <- 맞추고자 하는 버전
      end
    end
  end

end