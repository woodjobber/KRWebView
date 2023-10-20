source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '11.0'
use_frameworks!

flutter_application_path = '../../FlutterDemo/flutter_module_umbrella'
load File.join(flutter_application_path, '.ios', 'Flutter', 'podhelper.rb')

# from ruby 3.2  File.exists is broken, we need compat function
def mmkv_file_exists(file)
  is_exist = false
  if File.methods.include?(:exists?)
    is_exist = File.exists? file
  else
    is_exist = File.exist? file
  end
  return is_exist
end

# to avoid conflict of the native lib name 'libMMKV.so' on iOS, we need to change the plugin name 'mmkv' to 'mmkvflutter'
def fix_mmkv_plugin_name(flutter_application_path)
  is_module = false
  plugin_deps_file = File.expand_path(File.join(flutter_application_path, '..', '.flutter-plugins-dependencies'))
  if not mmkv_file_exists(plugin_deps_file)
    is_module = true;
    plugin_deps_file = File.expand_path(File.join(flutter_application_path, '.flutter-plugins-dependencies'))
  end

  plugin_deps = JSON.parse(File.read(plugin_deps_file)).dig('plugins', 'ios') || []
  plugin_deps.each do |plugin|
    if plugin['name'] == 'mmkv' || plugin['name'] == 'mmkvflutter'
      require File.expand_path(File.join(plugin['path'], 'tool', 'mmkvpodhelper.rb'))
      mmkv_fix_plugin_name(flutter_application_path, is_module)
      return
    end
  end
  raise "Fail to find any mmkv plugin dependencies. If you're running pod install manually, make sure flutter pub get is executed first"
end

fix_mmkv_plugin_name(flutter_application_path)

target 'KRWebView' do
    install_all_flutter_pods(flutter_application_path)
    pod 'Alamofire', '~> 4.5'
    pod 'AppSwizzle'
    pod 'RxSwift', '6.6.0'
    pod 'RxCocoa', '6.6.0'
    pod 'SnapKit'
#    pod 'MMKV'
end
post_install do |installer|
  #flutter_post_install 方法（Flutter 3.1.0 中新增的）增加了原生 Apple Silicon arm64 iOS 模拟器的支持。它包括 if defined?(flutter_post_install) 的检查以确保你的 Podfile 在旧版本的没有该方法的 Flutter 上也能正常运行
  
    flutter_post_install(installer) if defined?(flutter_post_install)
    
    installer.generated_projects.each do |project|
        project.targets.each do |target|
            target.build_configurations.each do |config|
                config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '11.0'
                config.build_settings['ENABLE_BITCODE'] = 'NO'
            end
        end
    end
end
