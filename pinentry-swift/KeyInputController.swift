//
//  MainViewController.swift
//  demo
//
//  Created by Meng on 23/11/2021.
//

import Cocoa

class KeyInputController: NSViewController {
    
    @IBOutlet weak var titleTextField: NSTextField!
    
    @IBOutlet weak var descTextField: NSTextField!
    
    @IBOutlet weak var psdInput: NSSecureTextField!
    
    @IBOutlet weak var okButton: NSButton!
    
    @IBOutlet weak var cancelButton: NSButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        okButton.action = #selector(onOk)
        cancelButton.action = #selector(onCancel)
        psdInput.placeholderString = "Password"
    }
    
    var action = 0 // 1: ok, 2: cancel
    let actionCondition = NSCondition()
    
    @objc func onOk() {
        actionCondition.lock()
        action = 1
        actionCondition.signal()
        actionCondition.unlock()
    }
    
    @objc func onCancel() {
        actionCondition.lock()
        action = 2
        actionCondition.signal()
        actionCondition.unlock()
    }
    
    func waitForPin() async -> String {
        return await withCheckedContinuation() { continuation in
            DispatchQueue.global(qos: .background).async { [weak self] in
                self!.actionCondition.lock()
                self!.actionCondition.wait()
                DispatchQueue.main.async { [weak self] in
                    self!.action = 0
                    continuation.resume(returning: self!.psdInput.stringValue)
                    self!.actionCondition.unlock()
                }
            }
        }
    }
    
}
