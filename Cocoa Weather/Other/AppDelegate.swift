//
//  AppDelegate.swift
//  Cocoa Weather
//
//  Created by zhs852 on 2018/9/22.
//  Copyright © 2018 zhs852. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        UserDefaults.standard.removeObject(forKey: "responseCode")
    }
    
}

