//
//  AppDelegate.swift
//  demo
//
//  Created by Meng on 22/11/2021.
//

import Cocoa
import os

class WindowDelegate: NSObject, NSWindowDelegate {
    func windowWillClose(_ notification: Notification) {
        print("Window Closed!")
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {

    var window: NSWindow!
    var contentViewController: KeyInputController!
    var windowDelegate: NSWindowDelegate!
    
    func showPasswordInputWindow() {
        window = NSWindow()
        window.styleMask = [.titled, .miniaturizable, .closable, .resizable]
        windowDelegate = WindowDelegate()
        window.title = "Pinentry Swift"
        window.delegate = windowDelegate
        contentViewController = KeyInputController()
        window.contentViewController = contentViewController
        window.center()
        window.makeKeyAndOrderFront(self)
        NSApp.activate(ignoringOtherApps: true)
    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        logger.log("App did finish launching")
        
        PinentryController.shared.GetPinFunc = {
            DispatchQueue.main.sync { [weak self] in
                guard let self = self else {return}
                self.showPasswordInputWindow()
            }
            return await self.contentViewController.waitForPin()
        }
        
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

