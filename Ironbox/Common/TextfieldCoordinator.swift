//
//  TextfieldCoordinator.swift
//  Ironbox
//
//  Created by Abul Hussain on 20/10/21.
//  Copyright © 2021 Gopalsamy A. All rights reserved.
//

import SwiftUI
import UIKit

typealias Completion = () -> Void
typealias StringAny = [String: Any]

enum TextFieldTriggerReason {
    case shouldBegin
    case didChange(String)
    case didEnd
    case didBegin
    case clickReturn
    case onBack
}

class BackDetectTextField: UITextField {
    var onBack: Completion?
    override func deleteBackward() {
        onBack?()
        super.deleteBackward()
    }
}

@available(iOS 13.0, *)
class TextFieldCoordinator: NSObject, UITextFieldDelegate, ObservableObject {
    var index = 0
    var toolbarCoordinator = ToolbarCoordinator()
    
    func enableToolbar(_ model: ToolbarModel? = nil) {
        if let model = model {
            toolbarCoordinator.toolbarModel = model
        }
        toolbarCoordinator.field = textField
        textField.inputAccessoryView = toolbarCoordinator.getToolbar()
    }
    
    @Published var text = ""
    var trimmedText: String {
        text.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    var textLimit: Int?
    
    var additional: StringAny?
    
    var isNotEmpty: Bool {
        trimmedText.count > 0
    }
    
    @Published var isFocused = false {
        didSet {
            if isFocused && !textField.isFirstResponder {
                textField.becomeFirstResponder()
            } else if !isFocused && textField.isFirstResponder {
                textField.resignFirstResponder()
            }
        }
    }
    
    var isAvoidDidChange = false
    
    public func setText(_ string: String, avoidDidchange: Bool = false) {
        isAvoidDidChange = avoidDidchange
        text = string
        textField.text = string
    }
    
    var textField = BackDetectTextField() {
        didSet {
            textField.delegate = self
            textField.onBack = { [weak self] in
                _ = self?.reason?(.onBack)
            }
        }
    }
    
    override init() {
        super.init()
        textField.delegate = self
        textField.onBack = { [weak self] in
            _ = self?.reason?(.onBack)
        }
        textField.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
    }
    
    var reason: ((TextFieldTriggerReason) -> Bool?)?
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        guard isAvoidDidChange == false else {
            isAvoidDidChange = false
            return
        }
        text = textField.text ?? ""
        if let limit = textLimit, text.count > limit {
            let startIndex = text.startIndex
            let endIndex = text.index(startIndex, offsetBy: limit)
            setText(String(text[startIndex..<endIndex]), avoidDidchange: true)
            return
        }
        _ = reason?(.didChange(text))
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        isFocused = true
        _ = reason?(.didBegin)
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        let isAllow = reason?(.shouldBegin) ?? true
        return isAllow
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        //        if let char = string.cString(using: String.Encoding.utf8) {
        //            let isBackSpace = strcmp(char, "\\b")
        //            if (isBackSpace == -92) {
        //                _ = reason?(.onBack)
        //            }
        //        }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        isFocused = false
        _ = reason?(.didEnd)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let allowReturn = reason?(.clickReturn) else {
            return true
        }
        return allowReturn
    }
}

struct ToolbarModel {
    let items: [ToolBarButtonModel]
    
}

struct ToolBarButtonModel {
    var button: UIBarButtonItem
    var action: Completion?
    
    @available(iOS 14.0, *)
    static let flex = ToolBarButtonModel(button: UIBarButtonItem(systemItem: .flexibleSpace), action: nil)
    
    static func title(_ title: String, action: Completion? = nil) -> ToolBarButtonModel {
        return ToolBarButtonModel(button: UIBarButtonItem(title: title, style: .plain, target: nil, action: nil), action: action)
    }
}

class ToolbarCoordinator {
    var toolbarModel: ToolbarModel!
    var field: UITextField!
    
    func getToolbar() -> UIView {
        let bar = UIToolbar()
        bar.sizeToFit()
        
        var barButtons = [UIBarButtonItem]()
        for (i, item) in toolbarModel.items.enumerated() {
            item.button.tag = i
            item.button.action = #selector(onclick(_:))
            item.button.target = self
            barButtons.append(item.button)
        }
        
        bar.items = barButtons
        return bar
    }
    
    deinit {
        print("toolbar coordinator deinited")
    }
    
    @objc func onclick(_ sender: UIBarButtonItem) {
//        toolbarModel.items[safe: sender.tag]?.action?()
        field.endEditing(true)
    }
}
//extension TextFieldCoordinator {
//
//    func toolBar(title1: String, title1Action: Completion?, title2: String, title2Action: Completion) {
//        let toolBar = UIToolbar()
//        toolBar.sizeToFit()
//
//        let title1Item = UIBarButtonItem(title: title1, style: .done, target: self, action: nil)
//        title1Item.action = #selector(title1Action)
//
//    }
//}

