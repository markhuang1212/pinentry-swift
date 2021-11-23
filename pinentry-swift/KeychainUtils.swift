//
//  KeychainController.swift
//
//  Created by Meng on 23/11/2021.
//

import Foundation
import Security
import LocalAuthentication

func ConfirmAccessWithBiometrics(reason: String) async -> Bool {
    let ctx = LAContext()
    let ret = try? await ctx.evaluatePolicy(LAPolicy.deviceOwnerAuthentication, localizedReason: reason)
    return ret ?? false
}
