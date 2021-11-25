//
//  main.swift
//  demo
//
//  Created by Meng on 23/11/2021.
//

import Foundation
import Cocoa
import LocalAuthentication
import os

let logger = Logger()

func printStdoutPrivate(_ str: String) {
    var newStr = str
    newStr.append("\n")
    logger.log("STDOUT <PRIVATE>")
    FileHandle.standardOutput.write(newStr.data(using: .utf8)!)
}

func printStdout(_ str: String) {
    var newStr = str
    newStr.append("\n")
    logger.log("STDOUT \(str, privacy: .public)")
    FileHandle.standardOutput.write(newStr.data(using: .utf8)!)
}

logger.log("Process started")

var app = NSApplication.shared
logger.log("NSApplication initialized")

var delegate = AppDelegate()
logger.log("AppDelegate initialized")

app.delegate = delegate
logger.log("AppDelegate assigned")

let menu = AppMenu()
NSApplication.shared.mainMenu = menu

let _ = NSApplicationMain(CommandLine.argc, CommandLine.unsafeArgv)
