//
//  ValidationFormStack.swift
//  Actors Pocket Guide
//
//  Created by Yulia Novikova on 3/25/21.
//  Copyright © 2021 Yulia Novikova. All rights reserved.
//

import UIKit

@IBDesignable
class FormViewItem: XibView {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var hintLabel: UILabel!
    @IBOutlet weak var delegate: UITextFieldDelegate?
    
//MARK: - @IBInspectables
    
    @IBInspectable var title: String = "Email"
    @IBInspectable var placeholder: String = ""
    
    @IBInspectable var titleStyle: String = "grayLabel14"
    @IBInspectable var textFieldStyle: String = "defaultTextField"
    @IBInspectable var hintStyle: String = "errorLabel14"
    
    @IBInspectable var customError: String?
    
    @IBInspectable var errorColor: UIColor = .error
    
    @IBInspectable var isPasswordField: Bool = false {
        didSet { setupPasswordField() }
    }
    
    @IBInspectable var isEmailField: Bool = false {
        didSet { setupEmailField() }
    }
    
    @IBInspectable var isLastFieldOnScreen: Bool = false {
        didSet {
            textField.returnKeyType = isLastFieldOnScreen ? .done : .default
        }
    }
    
 //   private var customError: String?
    
//MARK: - Variables

    private(set) var isValid = false {
        didSet {
            updateUI()
            onСhange()
        }
    }
    
    var text: String {
        textField.text.anyString
    }
    
    var onСhange: () -> () = {}
    
    private var checks: ScreenFieldsCheck?
    private var checkError: String?
    
    private var initialBorderColor: UIColor = .black
    
    private var compareWithItem: FormViewItem?
    
    var validationDisabled: Bool = false {
        didSet {
            if validationDisabled { isValid = true }
        }
    }
    
        
//MARK: - Setup
    
    override func setup() {
        textField.delegate = delegate
        textField.autocorrectionType = .no
        titleLabel.text = title
        titleLabel.styleID = titleStyle
        textField.placeholder = placeholder
        textField.styleID = textFieldStyle
        hintLabel.text = customError ?? ""
        hintLabel.styleID = hintStyle
        initialBorderColor = textField.borderColor
    }
    
    func setup(rules: [CheckRule], onСhange: @escaping () -> ()) {
        self.onСhange = onСhange
        checks = ScreenFieldsCheck([FieldCheck(name: title,
                                               field: textField,
                                               rules: rules)])
        setup()
    }
    
    func setup(compareWith field: FormViewItem,
                   error: String,
                   onСhange: @escaping () -> ()) {
        self.onСhange = onСhange
        self.customError = error
        self.compareWithItem = field
        setup()
    }
    
//MARK: - Methods
    
    @IBAction func textFieldEditingChanged(_ sender: UITextField) {
        guard !validationDisabled else { return }
        validate()
    }
    
    func validate() {
        if let compare = compareWithItem {
            guard textField.text == compare.text else {
                checkError = customError
                isValid = false
                return
            }
            isValid = true
            return
        }
        
        if let error = checks?.check(textField) {
            checkError = error
            isValid = false
            return
        }
        isValid = true
    }
    
    private func updateUI() {
        textField.borderColor = isValid ? initialBorderColor : errorColor
        hintLabel.showAnimated(!isValid)
        hintLabel.text = customError ?? checkError
    }
    
    private func setupPasswordField() {
        textField.isSecureTextEntry = true
    }
    
    private func setupEmailField() {
        textField.keyboardType = .emailAddress
    }
}


extension Array where Element == FormViewItem {
    
    var allValid: Bool {
        allSatisfy({ $0.isValid })
    }
    
    func validateAll() {
        forEach { $0.validate() }
    }
    
    func setup(rules: [CheckRule], onСhange: @escaping () -> ()) {
        forEach( {
            $0.setup(rules: rules, onСhange: onСhange)
        })
    }
    
    func setup(compareWith field: FormViewItem,
               error: String,
               onСhange: @escaping () -> ()) {
        forEach({
            $0.setup(compareWith: field, error: error, onСhange: onСhange)
        })
    }
}
