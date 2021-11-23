//
//  PinentryController.swift
//  demo
//
//  Created by Meng on 23/11/2021.
//

import Foundation
import Cocoa
import KeychainSwift
import os

let keychain = KeychainSwift()

func defaultGetPinFunc() async -> String {
    return ""
}

func defaultGetPinFromCacheFunc(keyinfo: String) async -> String? {
    if(await defaultConfirmFunc()) {
        return keychain.get(keyinfo)
    } else {
        return nil
    }
}

func defaultConfirmFunc() async -> Bool {
    return await ConfirmAccessWithBiometrics(reason: "Confirm")
}

func defaultSavePinFunc(keyinfo: String, pin: String) {
    keychain.set(pin, forKey: keyinfo)
}

func defaultByeFunc() {
    DispatchQueue.main.async {
        NSApp.terminate(nil)
    }
}

class PinentryController {
    
    static let shared = PinentryController()
    
    var cacheEnabled = false
    var keyInfo = ""
    
    var OkFunc: () -> () = {}
    var CancelFunc: () -> () = {}
    var GetPinFunc: () async -> String = defaultGetPinFunc
    var GetPinFromCacheFunc: (_ keyinfo: String) async -> String? = defaultGetPinFromCacheFunc
    var GetConfirmFunc: () async -> Bool = defaultConfirmFunc
    var SavePinFunc: (_ keyinfo: String, _ pin: String) -> () = defaultSavePinFunc
    var ByeFunc: () -> () = defaultByeFunc
    
    var timeout: Int = 0
    var description: String = ""
    var prompt: String = ""
    var title: String = ""
    
    var buttonOkText: String = ""
    var buttonCancelText: String = ""
    
    
    init(){
        
    }
    
    static func getStrTail(str: String) -> String {
        guard let x = str.firstIndex(of: " ") else {
            return ""
        }
        let substr = str[str.index(after: x)...]
        return String(substr)
    }
    
    // run the controller in the background
    func run() {
        DispatchQueue.global(qos: .background).async { [weak self] in
            Task.init { [weak self] in
                while let str = readLine(strippingNewline: true)  {
                    logger.log("STDIN \(str, privacy: .public)")
                    guard let self = self else {
                        return
                    }
                    let cmd = str.split(separator: " ")
                    if(cmd.isEmpty) {
                        continue
                    }
                    switch cmd[0] {
                    case "SETTIMEOUT":
                        let timeout = Int(cmd[1])
                        self.timeout = timeout!
                        printStdout("OK")
                    case "SETDESC":
                        let desc = PinentryController.getStrTail(str: str)
                        self.description = desc
                        printStdout("OK")
                    case "SETPROMPT":
                        let prompt = PinentryController.getStrTail(str: str)
                        self.prompt = prompt
                        printStdout("OK")
                    case "SETTITLE":
                        let title = PinentryController.getStrTail(str: str)
                        self.title = title
                        printStdout("OK")
                    case "SETOK":
                        let text = PinentryController.getStrTail(str: str)
                        self.buttonOkText = text
                        printStdout("OK")
                    case "SETCANCEL":
                        let text = PinentryController.getStrTail(str: str)
                        self.buttonCancelText = text
                        printStdout("OK")
                    case "GETPIN":
                        var pin: String?
                        if(self.cacheEnabled) {
                            pin = await self.GetPinFromCacheFunc(self.keyInfo)
                            if pin == nil {
                                pin = await self.GetPinFunc()
                                self.SavePinFunc(self.keyInfo, pin!)
                            } else {
                                printStdout("S PASSWORD_FROM_CACHE")
                            }
                        } else {
                            pin = await self.GetPinFunc()
                        }
                        printStdout("D \(pin!)")
                        printStdout("OK")
                    case "CONFIRM":
                        if await self.GetConfirmFunc() {
                            printStdout("OK")
                        } else {
                            printStdout("ERR ASSUAN_Not_Confirmed")
                        }
                    case "SETKEYINFO":
                        let key = PinentryController.getStrTail(str: str)
                        self.keyInfo = key
                        printStdout("OK")
                    case "OPTION":
                        let option = String(cmd[1])
                        switch option {
                        case "allow-external-password-cache":
                            self.cacheEnabled = true
                            printStdout("OK")
                        default:
                            printStdout("OK")
                        }
                    case "GETINFO":
                        printStdout("ERR")
                    case "SETNOTOK", "SETERROR", "SETQUALITYBAR", "SETQUALITYBAR_TT", "MESSAGE":
                        printStdout("OK")
                    case "BYE":
                        self.ByeFunc()
                    default:
                        printStdout("ERR")
                    }
                }
                self?.ByeFunc()
            }
        }
    }
}
