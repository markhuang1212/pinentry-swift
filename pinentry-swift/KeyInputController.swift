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
    
    @IBOutlet weak var timeoutTextField: NSTextField!
    
    @IBOutlet weak var psdInput: NSSecureTextField!
    
    @IBOutlet weak var okButton: NSButton!
    
    @IBOutlet weak var cancelButton: NSButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        view.wantsLayer = true
//        view.layer?.backgroundColor = NSColor.red.cgColor
        okButton.action = #selector(onOk)
        cancelButton.action = #selector(onCancel)
        psdInput.placeholderString = "Password"
        timeoutTextField.stringValue = ""
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
    
    func updateWindow(titleText: String?, descriptionText: String?, okText: String?,
                      cancelText: String?, prompt: String?, errorText: String?, timeout: Int?) {
        psdInput.stringValue = ""
        if let titleText = titleText {
            titleTextField.stringValue = titleText
        }
        if let descriptionText = descriptionText {
            descTextField.stringValue = descriptionText
        }
        if let errorText = errorText {
            descTextField.stringValue = errorText
            descTextField.textColor = NSColor(ciColor: .red)
            psdInput.drawFocusRingMask()
        }
        if let okText = okText {
            okButton.title = okText
        }
        if let cancelText = cancelText {
            cancelButton.title = cancelText
        }
        if let prompt = prompt {
            psdInput.placeholderString = prompt
        }
        if let timeout = timeout {
            DispatchQueue.global(qos: .background).async { [timeout, weak self] in
                var timeout = timeout
                while(timeout > 0) {
                    sleep(1)
                    timeout -= 1;
                    DispatchQueue.main.async { [weak self] in
                        self?.timeoutTextField.stringValue = String(timeout)
                    }
                }
                self?.actionCondition.lock()
                self?.action = 2
                self?.actionCondition.signal()
                self?.actionCondition.unlock()
            }
        }
//        print(view.fittingSize)
//        view.frame.size = view.fittingSize
    }
    
    func waitForPin() async -> String? {
        return await withCheckedContinuation() { continuation in
            DispatchQueue.global(qos: .background).async { [weak self] in
                self!.actionCondition.lock()
                self!.actionCondition.wait()
                DispatchQueue.main.async { [weak self] in
                    if(self!.action == 1) {
                        continuation.resume(returning: self!.psdInput.stringValue)
                    } else {
                        continuation.resume(returning: nil)
                    }
                    self!.action = 0
                    self!.actionCondition.unlock()
                }
            }
        }
    }
    
}
