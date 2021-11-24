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

class PinentryController {
    
    static let shared = PinentryController()
    
    var cacheEnabled = false
    var keyInfo: String? = nil
    
    var OkFunc = {}
    var CancelFunc = {}
    var GetPinFunc = defaultGetPinFunc
    var GetPinFromCacheFunc: (_ keyinfo: String) async -> String? = defaultGetPinFromCacheFunc
    var GetConfirmFunc = defaultConfirmFunc
    var SavePinFunc: (_ keyinfo: String, _ pin: String) -> () = defaultSavePinFunc
    var DelPinFunc = defaultDelPinFunc
    var ByeFunc: () -> () = defaultByeFunc
    
    var timeout: Int? = nil
    var description: String? = nil
    var prompt: String? = nil
    var title: String? = nil
    var errorText: String? = nil
    var pinCache: String? = nil
    var confirmMode = false
    var repeatText: String? = nil
    var repeatErrText: String? = nil
    
    var buttonOkText: String? = nil
    var buttonCancelText: String? = nil
    
    init(){
        
    }
    
    static func getStrTail(str: String) -> String {
        guard let x = str.firstIndex(of: " ") else {
            return ""
        }
        let substr = String(str[str.index(after: x)...])
        return substr.removingPercentEncoding!
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
                        var isFromCache = false
                        // get from cache if possible
                        if(self.cacheEnabled && self.keyInfo != nil) {
                            pin = await self.GetPinFromCacheFunc(self.keyInfo!)
                            if pin != nil {
                                isFromCache = true
                            }
                        }
                        // get from prompt
                        if pin == nil {
                            pin = await self.GetPinFunc(self)
                        }
                        // report
                        if pin != nil {
                            if isFromCache {
                                printStdout("S PASSWORD_FROM_CACHE")
                            } else if self.repeatText != nil {
                                printStdout("S PIN_REPEATED")
                            }
                            if self.cacheEnabled && self.keyInfo != nil {
                                self.SavePinFunc(self.keyInfo!, pin!)
                            }
                            printStdout("D \(pin!)")
                            printStdout("OK")
                        } else {
                            printStdout("ERR 83886179 Operation cancelled <Pinentry>")
                        }
                    case "CONFIRM":
                        if await self.GetConfirmFunc(self) {
                            printStdout("OK")
                        } else {
                            printStdout("ERR 83886179 Operation cancelled <Pinentry>")
                        }
                    case "SETKEYINFO":
                        let key = PinentryController.getStrTail(str: str)
                        if(key.starts(with: "--clear")) {
                            self.keyInfo = nil
                        } else {
                            self.keyInfo = key
                        }
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
                    case "SETERROR":
                        self.errorText = PinentryController.getStrTail(str: str)
                        // on errer, clear the cache
                        if(self.keyInfo != nil) {
                            self.DelPinFunc(self.keyInfo!)
                        }
                        printStdout("OK")
                    case "SETNOTOK", "SETQUALITYBAR", "SETQUALITYBAR_TT", "MESSAGE":
                        printStdout("OK")
                    case "SETREPEAT":
                        self.repeatText = PinentryController.getStrTail(str: str)
                        printStdout("OK")
                    case "SETREPEATERROR":
                        self.repeatErrText = PinentryController.getStrTail(str: str)
                        printStdout("OK")
                    case "BYE":
                        self.ByeFunc()
                    default:
                        printStdout("ERR Not Implemented")
                    }
                }
                // say goodbye when EOF
                self?.ByeFunc()
            }
        }
    }
}
