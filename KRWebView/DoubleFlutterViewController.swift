//
//  DoubleFlutterViewController.swift
//  KRWebView
//
//  Created by chengbin on 2023/10/19.
//  Copyright © 2023 KRiOSApps. All rights reserved.
//

import UIKit

class DoubleFlutterViewController: UIViewController {
    private let topFlutter: SingleFlutterViewController = .init(
        withEntrypoint: "topMain")
    private let bottomFlutter: SingleFlutterViewController = .init(
        withEntrypoint: "bottomMain")

    override func viewDidLoad() {
        view.backgroundColor = .white
        addChildViewController(topFlutter)
        addChildViewController(bottomFlutter)
        let safeFrame = view.safeAreaLayoutGuide.layoutFrame
        let halfHeight = safeFrame.height / 2.0
        topFlutter.view.frame = CGRect(
            x: safeFrame.minX, y: safeFrame.minY, width: safeFrame.width, height: halfHeight)
        bottomFlutter.view.frame = CGRect(
            x: safeFrame.minX, y: topFlutter.view.frame.maxY, width: safeFrame.width, height: halfHeight)
        view.addSubview(topFlutter.view)
        view.addSubview(bottomFlutter.view)
        topFlutter.didMove(toParentViewController: self)
        bottomFlutter.didMove(toParentViewController: self)
    }
}
