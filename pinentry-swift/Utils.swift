//
//  KeychainController.swift
//
//  Created by Meng on 23/11/2021.
//

import Foundation
import Security
import LocalAuthentication
import KeychainSwift
import Cocoa

let keychain = KeychainSwift(keyPrefix: "PinentrySwift_")

func ConfirmAccessWithBiometrics(reason: String) async -> Bool {
    let ctx = LAContext()
    let ret = try? await ctx.evaluatePolicy(LAPolicy.deviceOwnerAuthentication, localizedReason: reason)
    return ret ?? false
}

func defaultGetPinFunc(_ controller: PinentryController) async -> String? {
    let ctrl = GetPinController()
    return await ctrl.GetPin(controller)
}

func defaultGetPinFromCacheFunc(keyinfo: String) async -> String? {
    if let ret = keychain.get(keyinfo) {
        if await ConfirmAccessWithBiometrics(reason: "Confirm Access to key \(keyinfo)") {
            return ret
        }
    }
    return nil
}

func defaultDelPinFunc(keyinfo: String) {
    keychain.delete(keyinfo)
}

func defaultConfirmFunc(_ controller: PinentryController) async -> Bool {
    return await withCheckedContinuation() { continuation in
        DispatchQueue.main.async {
            let alert = NSAlert()
            alert.icon = NSImage(systemSymbolName: "exclamationmark.triangle", accessibilityDescription: nil)
            alert.addButton(withTitle: controller.buttonOkText ?? "Ok")
            alert.addButton(withTitle: controller.buttonCancelText ?? "Cancel")
            alert.messageText = controller.title ?? "Confirm"
            alert.informativeText = controller.description ?? ""
            NSApp.activate(ignoringOtherApps: true)
            let ret = alert.runModal()
            if(ret.rawValue == 1000) {
                continuation.resume(returning: true)
            } else {
                continuation.resume(returning: false)
            }
            
        }
    }
}

func defaultSavePinFunc(keyinfo: String, pin: String) {
    keychain.set(pin, forKey: keyinfo)
}

func defaultByeFunc() {
    DispatchQueue.main.async {
        NSApp.terminate(nil)
    }
}
