//
//  ViewController.swift
//  KRWebView
//
//  Created by Birapuram Kumar Reddy on 11/20/17.
//  Copyright © 2017 KRiOSApps. All rights reserved.
//

import UIKit
import WebKit
import Alamofire
import FlutterPluginRegistrant
import Flutter
import RxSwift
import RxCocoa
import flutter_boost

class ViewController: UIViewController,UIWebViewDelegate {

    var webview : UIWebView?
    var wkWebView : WKWebView?
    let disposeBag = DisposeBag()
   
    override func loadView() {
        super.loadView()
        if #available(iOS 11.0, *) {
            let configuration = WKWebViewConfiguration()
            configuration.allowsInlineMediaPlayback = true
            configuration.mediaTypesRequiringUserActionForPlayback = WKAudiovisualMediaTypes.all
            if configuration.urlSchemeHandler(forURLScheme: "http") == nil && configuration.urlSchemeHandler(forURLScheme: "https") == nil {
                configuration.setURLSchemeHandler(CustomeSchemeHandler(), forURLScheme: Constants.customURLScheme)
            }
    
            wkWebView = WKWebView(frame: .zero,configuration:configuration)
            view = wkWebView
        }else{
            webview = UIWebView(frame: .zero)
            view = webview
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let button = UIButton(type:UIButton.ButtonType.custom)
        button.addTarget(self, action: #selector(showFlutter), for: .touchUpInside)
        button.setTitle("Show Flutter!", for: UIControl.State.normal)
        button.frame = CGRect(x: (UIScreen.main.bounds.width - 160.0) / 2, y: 600, width: 160.0, height: 40.0)
        button.backgroundColor = UIColor.red
        button.layer.cornerRadius = 4
        button.contentEdgeInsets = .init(top: 10, left: 15, bottom: 10, right: 15)
        self.view.addSubview(button)
        
        loadHtmlIntoWebview()
    }
    var initialRoute = "splash"
    
    lazy var dismissPageButton: UIButton = {
        let button = UIButton()
        button.setTitle("Dismiss Flutter!", for: .normal)
        button.addTarget(self, action: #selector(self.onTapDismissButton), for: .touchUpInside)
        button.backgroundColor = UIColor.red
        button.contentEdgeInsets = .init(top: 10, left: 15, bottom: 10, right: 15)
        button.layer.cornerRadius = 4
        button.frame = CGRect(x: (UIScreen.main.bounds.width - 160.0) / 2, y: 600.0, width: 160.0, height: 40.0)
        return button
    }()
    
    @objc func onTapDismissButton() {
        let delegate = (UIApplication.shared.delegate as! AppDelegate)
        let vc = delegate.flutterEngine.viewController as? UmbrellaController
        vc?.dismiss(animated: false)
//        vc?.destroyFlutterApp()
    }
    
    @objc func showFlutter() {
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        let vc = storyboard.instantiateViewController(withIdentifier: "NativeViewCount")
//        self.navigationController!.pushViewController(vc, animated: true)
//        return
        
        let flutterViewController = UmbrellaController(withInitialRoute: initialRoute)
        flutterViewController.modalPresentationStyle = .overFullScreen
        flutterViewController.modalTransitionStyle = .coverVertical
        flutterViewController.view.addSubview(self.dismissPageButton)
        present(flutterViewController, animated: false)
        
        flutterViewController.rx.methodInvoked(#selector(FlutterViewController.dismiss(animated:completion:))).subscribe { [weak self] _ in
            if(self?.initialRoute == "splash"){
                self?.initialRoute = "register_module"
            }
            else if(self?.initialRoute == "register_module"){
                self?.initialRoute = "login_module"
            }else if (self?.initialRoute == "login_module"){
                self?.initialRoute = "splash"
            }
        }.disposed(by: disposeBag)
       
      }
    
    internal func loadHtmlIntoWebview() -> Void {
        if #available(iOS 11.0 , *){
            let fileURL = Bundle.main.url(forResource: "sample", withExtension: "html")
            wkWebView?.loadFileURL(fileURL!, allowingReadAccessTo: fileURL!)
        }else{
            do{
                let htmlFile = Bundle.main.url(forResource: "sample", withExtension: "html")
                let htmlText = try String(contentsOf: htmlFile!, encoding: String.Encoding.utf8)
                webview?.loadHTMLString(htmlText, baseURL: nil)
            }catch{
                print("error in parsing the file \(error.localizedDescription)")
            }
        }
    }
    deinit {
        
    }
}


extension WKWebView {
   
}

class UmbrellaController: Flutter.FlutterViewController {
    
    private var channel: FlutterMethodChannel?
    
    private var initialRoute: String?
    
    private lazy var runOnce: ()->Void = {
        [weak self] in
        self?.channel?.invokeMethod("entrypoint", arguments: self?.initialRoute)
        return {}
    }()
    
    init(withInitialRoute initialRoute: String?) {
        let delegate = (UIApplication.shared.delegate as! AppDelegate)
        self.initialRoute = initialRoute
        
        let newEngine = delegate.flutterEngine!
//        super.init(engine: newEngine, nibName: nil, bundle: nil)
        super.init(engine: newEngine, nibName: nil, bundle: nil)
        channel = FlutterMethodChannel(name: "io.flutter.update.entrypoint", binaryMessenger: newEngine.binaryMessenger)
        
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        runOnce();
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        runOnce();
    }
    
    func destroyFlutterApp() {
        channel?.invokeMethod("destroy.flutter.app", arguments: "destroy.flutter.app")
    }
    deinit {
        print("UmbrellaController deinit...")
        channel?.invokeMethod("destroy.flutter.app", arguments: "destroy.flutter.app")
        let delegate = (UIApplication.shared.delegate as! AppDelegate)
        delegate.flutterEngine.viewController = nil
    }
}
