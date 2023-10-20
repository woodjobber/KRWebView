//
//  WKWebView+Ext.swift
//  KRWebView
//
//  Created by chengbin on 2023/10/17.
//  Copyright © 2023 KRiOSApps. All rights reserved.
//

import Foundation
import WebKit
import AppSwizzle

class Once: NSObject {
    
    static let token = {() ->Once in
        let originalSelector = #selector(WKWebView.handlesURLScheme(_:))
        let swizzledSelector = #selector(WKWebView.swizzlehandlesURLScheme(_:))
        
        let cls: AnyClass = WKWebView.self
        
        let originalMethod = class_getClassMethod(WKWebView.self, originalSelector)!
        let swizzledMethod = class_getClassMethod(WKWebView.self, swizzledSelector)!
        
        let c: AnyClass = object_getClass(cls)!
        
        let didAddMethod  = class_addMethod(c, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod))
        
        if(didAddMethod){
            class_replaceMethod(c, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod))
        }else {
            method_exchangeImplementations(originalMethod, swizzledMethod)
        }
        return Once()
    }()
    
}

extension WKWebView {
    @objc class func swizzlehandlesURLScheme(_ urlScheme: String) -> Bool{
        if urlScheme == "http" || urlScheme == "https" {
            return false
        }
        if #available(iOS 11.0,*) {
            return swizzlehandlesURLScheme(urlScheme)
        }
        return false
       
    }
}


public struct Swizzler {

  public enum Kind {
    case instance
    case `class`
  }

    public static func swizzle(_ originalSelector: Selector, swizzledSelector: Selector, cls: AnyClass!, kind: Kind = .instance) {

    let originalMethod = kind == .instance
      ? class_getInstanceMethod(cls, originalSelector)
      : class_getClassMethod(cls, originalSelector)

    let swizzledMethod = kind == .instance
      ? class_getInstanceMethod(cls, swizzledSelector)
      : class_getClassMethod(cls, swizzledSelector)

    let didAddMethod = class_addMethod(cls, originalSelector,
      method_getImplementation(swizzledMethod!),
      method_getTypeEncoding(swizzledMethod!))

    if didAddMethod {
      class_replaceMethod(cls, swizzledSelector,
        method_getImplementation(originalMethod!),
        method_getTypeEncoding(originalMethod!))
    } else {
      method_exchangeImplementations(originalMethod!, swizzledMethod!)
    }
  }
}
