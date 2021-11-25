//
//  AppDelegate.swift
//  demo
//
//  Created by Meng on 22/11/2021.
//

import Cocoa

// AppDelegate starts the pinentry controller when the NSApp is ready
class AppDelegate: NSObject, NSApplicationDelegate {

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        logger.log("App did finish launching")
        PinentryController.shared.run()
        logger.log("pinentry controller started")
        printStdout("OK Pleased to meet you")
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }

}

