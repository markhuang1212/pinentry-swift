//
//  AppMenu.swift
//  pinentry-swift
//
//  Created by Meng on 24/11/2021.
//

import Foundation
import Cocoa

class AppMenu: NSMenu {
    override init(title: String) {
        super.init(title: title)
        let mainMenu = NSMenuItem()
        let editMenu = NSMenuItem()
        editMenu.submenu = NSMenu(title: "Edit")
        editMenu.submenu?.addItem(withTitle: "Paste", action: #selector(NSText.paste(_:)), keyEquivalent: "v")
        
        items = [mainMenu, editMenu]
    }
    required init(coder: NSCoder) {
        super.init(coder: coder)
    }
}
