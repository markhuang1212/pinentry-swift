//
//  GetPinController.swift
//  pinentry-swift
//
//  Created by Meng on 24/11/2021.
//

import Foundation
import Cocoa

class GetPinController {
    
    class TextFieldDelegate: NSObject, NSTextFieldDelegate {
        init(checkFunc: @escaping () -> ()) {
            self.checkFunc = checkFunc
        }
        var checkFunc = {}
        public func controlTextDidChange(_ obj: Notification) {
            checkFunc()
        }
    }

    var delegate1: TextFieldDelegate?
    var delegate2: TextFieldDelegate?
    var textBox1: NSTextField?
    var textBox2: NSTextField?
    var okButton: NSButton?
    
    func GetPin(_ controller: PinentryController) async -> String? {
        return await withCheckedContinuation() { continuation in
            DispatchQueue.main.async { [weak self] in
                guard let self = self else {
                    continuation.resume(returning: nil)
                    return
                }
                let alert = NSAlert()
                alert.messageText = controller.title ?? "Pin Entry"
                alert.informativeText = controller.description ?? "No Description Provided"
                alert.addButton(withTitle: controller.buttonOkText ?? "OK")
                alert.addButton(withTitle: controller.buttonCancelText ?? "Cancel")
                
                self.textBox1 = NSSecureTextField(frame: NSRect(x: 0, y: 0, width: 200, height: 24))
                self.textBox1!.placeholderString = controller.prompt ?? "Passpharse"
                alert.accessoryView = self.textBox1!
//                self.alertDelegate = AlertDelegate()
//                self.alertDelegate?.firstResponder = self.textBox1
                
                if(controller.repeatText != nil) {
                    let stack = NSStackView(frame: NSRect(x: 0, y: 0, width: 200, height: 58))
                    stack.orientation = .vertical
                    self.textBox2 = NSSecureTextField(frame: NSRect(x: 0, y: 0, width: 200, height: 24))
                    self.textBox2!.placeholderString = controller.repeatText ?? "Repeat Passphrase"
                    stack.addSubview(self.textBox1!)
                    self.textBox1!.frame = NSRect(x: 0, y: 24, width: 200, height: 24)
                    stack.addSubview(self.textBox2!)
                    alert.accessoryView = stack
                    
                    self.delegate1 = TextFieldDelegate(checkFunc: self.onInputValueChanged)
                    self.textBox1!.delegate = self.delegate1
                    self.textBox1!.nextKeyView = self.textBox2!
                    self.delegate2 = TextFieldDelegate(checkFunc: self.onInputValueChanged)
                    self.textBox2!.delegate = self.delegate2
                    
                    self.okButton = alert.buttons[0]
                }
                alert.window.initialFirstResponder = self.textBox1!
                NSApp.activate(ignoringOtherApps: true)
//                self.textBox1?.becomeFirstResponder()
                let ret = alert.runModal()
                
                if(ret.rawValue == 1000) {
                    continuation.resume(returning: self.textBox1!.stringValue)
                } else {
                    continuation.resume(returning: nil)
                }
            }
            
        }
    }
    
    func onInputValueChanged() {
        guard let textBox1 = textBox1 else {
            return
        }
        guard let textBox2 = textBox2 else {
            return
        }
        guard let okButton = okButton else {
            return
        }
        print("ValueChanged!!!")
        if(textBox1.stringValue != textBox2.stringValue) {
            okButton.isEnabled = false
        } else {
            okButton.isEnabled = true
        }
    }
    
}
