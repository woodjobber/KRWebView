//
//  DataModel.swift
//  KRWebView
//
//  Created by chengbin on 2023/10/19.
//  Copyright © 2023 KRiOSApps. All rights reserved.
//

import Foundation


/// A protocol that receives updates when the datamodel is changed.
protocol DataModelObserver: AnyObject {
  func onCountUpdate(newCount: Int64)
}

/// A wrapper object around a weak reference to an object that implements DataModelObserver.
///
/// This is required since you can't directly hold weak references to protocols in data structures.
private struct DataModelObserverWrapper {
  weak var wrapped: DataModelObserver?

  init(_ wrapped: DataModelObserver) {
    self.wrapped = wrapped
  }
}

class DataModel {
  private var _count: Int64 = 0
  var count: Int64 {
    get {
      return self._count
    }
    set {
      self._count = newValue
      for observer in observers {
        if let wrapped = observer.wrapped {
          wrapped.onCountUpdate(newCount: self._count)
        }
      }
    }
  }
  private var observers: [DataModelObserverWrapper] = []
  static let shared = DataModel()

  func addObserver(observer: DataModelObserver) {
    observers.append(DataModelObserverWrapper(observer))
  }

  func removeObserver(observer: DataModelObserver) {
    observers.removeAll { (element: DataModelObserverWrapper) -> Bool in
      if let wrapped = element.wrapped {
        return wrapped === observer
      } else {
        // Handle observers who dealloc'd without removing themselves.
        return true
      }
    }
  }
}
