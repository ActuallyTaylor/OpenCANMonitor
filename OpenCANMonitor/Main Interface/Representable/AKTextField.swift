//
//  AKTextField.swift
//  CanMonitor
//
//  Created by Taylor Lineman on 9/5/23.
//

import SwiftUI
import AppKit

struct AKTextField: NSViewRepresentable {
    var placeholder: String = ""
    var bezelStyle: NSTextField.BezelStyle = .roundedBezel
    @Binding var text: String
    var isEditable: Bool = true
    var formatter: Formatter? = nil
        
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeNSView(context: Context) -> NSTextField {
        let textField = NSTextField()
        textField.formatter = formatter
        textField.stringValue = text
        textField.placeholderString = placeholder
        textField.bezelStyle = bezelStyle
        textField.delegate = context.coordinator
        
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.autoresizingMask = [.width, .height]

        return textField
    }
    
    func updateNSView(_ nsView: NSTextField, context: Context) {
        if text != nsView.stringValue {
            nsView.stringValue = text
        }
    }
    
    class Coordinator: NSObject, NSTextFieldDelegate, NSControlTextEditingDelegate {
        let parent: AKTextField
        
        init(_ textField: AKTextField) {
            self.parent = textField
        }

        func controlTextDidChange(_ obj: Notification) {
            guard let textView = obj.object as? NSTextField else { return }
            self.parent.text = textView.stringValue
        }
        
    }
}
