/*
 * @file AppDelegate.swift
 * @description Define AppDelegate class
 * @par Copyright
 *   Copyright (C) 2025 Steel Wheels Project
 */

import MultiUIKit
import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate
{
        func applicationDidFinishLaunching(_ aNotification: Notification) {
                // Insert code here to initialize your application
        }

        func applicationWillTerminate(_ aNotification: Notification) {
                // Insert code here to tear down your application
        }

        func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
                return true
        }

        #if os(OSX)
        private var mToolWindowOpened:  Bool      = false
        private var mToolWindow:        MIWindow? = nil

        @IBAction func openSettingWindow(_ sender: NSMenuItem) {
                guard !mToolWindowOpened else {
                        return
                }

                let controller = ToolViewController()

                let config = MIWindow.WindowConfig(size: NSSize(width: 640, height: 480), title: "Tool", closeable: true, resizable: false)
                let window = MIWindow.open(viewController: controller, condfig: config)
                window.setCallback(windowWillClose: {
                        () -> Void in
                        NSLog("the preference window will be closed")
                        self.mToolWindowOpened = false
                })
                mToolWindowOpened = true
                mToolWindow = window
        }
        #endif
}

