//
//  SingleFlutterViewController.swift
//  KRWebView
//
//  Created by chengbin on 2023/10/19.
//  Copyright © 2023 KRiOSApps. All rights reserved.
//

import Flutter
import FlutterPluginRegistrant
import UIKit

class SingleFlutterViewController: FlutterViewController, DataModelObserver {
    private var channel: FlutterMethodChannel?

    init(withEntrypoint entryPoint: String?) {
        let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let newEngine = appDelegate.engines.makeEngine(withEntrypoint: entryPoint, libraryURI: nil)
        
        newEngine.run(withEntrypoint: entryPoint, libraryURI: nil)
        GeneratedPluginRegistrant.register(with: newEngine)
        super.init(engine: newEngine, nibName: nil, bundle: nil)
        DataModel.shared.addObserver(observer: self)
    }

    deinit {
        DataModel.shared.removeObserver(observer: self)
    }

    @available(*, unavailable)
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func onCountUpdate(newCount: Int64) {
        if let channel = channel {
            channel.invokeMethod("setCount", arguments: newCount)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        channel = FlutterMethodChannel(
            name: "multiple-flutters", binaryMessenger: engine!.binaryMessenger)
        channel!.invokeMethod("setCount", arguments: DataModel.shared.count)
        let navController = navigationController!

        channel!.setMethodCallHandler { (call: FlutterMethodCall, result: @escaping FlutterResult) in
            if call.method == "incrementCount" {
                DataModel.shared.count = DataModel.shared.count + 1
                result(nil)
            } else if call.method == "next" {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "NativeViewCount")
                navController.pushViewController(vc, animated: true)
                result(nil)
            } else {
                result(FlutterMethodNotImplemented)
            }
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print(self.engine as Any)
    }
}
