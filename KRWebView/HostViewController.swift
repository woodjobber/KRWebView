//
//  HostViewController.swift
//  KRWebView
//
//  Created by chengbin on 2023/10/19.
//  Copyright © 2023 KRiOSApps. All rights reserved.
//

import UIKit

import Flutter


class HostViewController:
    UIViewController,DataModelObserver {
    
    @IBOutlet weak var labelView: UILabel!
    
    var defaultViewController = SingleFlutterViewController(withEntrypoint: nil)
    
    func onCountUpdate(newCount: Int64) {
        self.labelView.text = String(format: "%d", newCount)

    }
    
    deinit {
      DataModel.shared.removeObserver(observer: self)
    }

    @IBAction func next(_ sender: UIButton) {
        let navController = self.navigationController!
        // Based on the number of view controllers in the stack we push a
        // SingleFlutterViewController or DoubleFlutterViewController to alternatve
        // between the two.
        if (navController.viewControllers.count - 1) % 4 == 1 {
          let vc = defaultViewController
          navController.pushViewController(vc, animated: true)
        } else {
          let vc = DoubleFlutterViewController()
          navController.pushViewController(vc, animated: true)
        }
    }
    
    @IBAction func add(_ sender: UIButton) {
        DataModel.shared.count = DataModel.shared.count + 1

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        DataModel.shared.addObserver(observer: self)
        onCountUpdate(newCount: DataModel.shared.count)
    }

}
