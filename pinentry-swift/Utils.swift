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

let keychain = KeychainSwift()

func ConfirmAccessWithBiometrics(reason: String) async -> Bool {
    let ctx = LAContext()
    let ret = try? await ctx.evaluatePolicy(LAPolicy.deviceOwnerAuthentication, localizedReason: reason)
    return ret ?? false
}

func defaultGetPinFunc(_ controller: PinentryController) async -> String? {
    return nil
}

func defaultGetPinFromCacheFunc(keyinfo: String) async -> String? {
    if let ret = keychain.get(keyinfo) {
        if await defaultConfirmFunc() {
            return ret
        }
    }
    return nil
}

func defaultDelPinFunc(keyinfo: String) {
    keychain.delete(keyinfo)
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
