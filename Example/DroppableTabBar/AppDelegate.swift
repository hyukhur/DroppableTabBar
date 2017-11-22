//
//  AppDelegate.swift
//  DroppableTabBar
//
//  Created by hyukhur on 10/11/2017.
//  Copyright (c) 2017 hyukhur. All rights reserved.
//

import UIKit

extension Array {
    public subscript (safe index: Array.Index) -> Element? {
        get {
            return indices ~= index ? self[index] : nil
        }
        set {
            guard let element = newValue,
                indices ~= index else { return }
            self[index] = element
        }
    }
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        NSSetUncaughtExceptionHandler { (exception) in
            print(exception)
            exit(EXIT_FAILURE)
        }
        return true
    }
}
