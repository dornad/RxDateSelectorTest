# Uncomment this line to define a global platform for your project
platform :ios, '8.0'
use_frameworks!

def rx_swift_fork
	fork_url = 'https://github.com/dornad/RxSwift.git'
	fork_branch = 'UIPickerView_Rx'
	pod 'RxSwift', :git => fork_url, :branch => fork_branch
	pod 'RxCocoa', :git => fork_url, :branch => fork_branch
	pod 'RxBlocking', :git => fork_url, :branch => fork_branch
end

def rx_swift_development
	path_pod = '~/Projects/RxSwift'
	pod 'RxSwift', :path => path_pod
	pod 'RxCocoa', :path => path_pod
	pod 'RxBlocking', :path => path_pod
end

def rx_swift_official
	latest_version = '~> 2.0.0-beta'
	pod 'RxSwift', latest_version
	pod 'RxCocoa', latest_version
	pod 'RxBlocking', latest_version
end

target 'Test' do	
	rx_swift_official	
	pod 'SnapKit', '~> 0.17.0'
end

