import UIKit

@IBDesignable class UIField: UITextField, DialogDelegate {
    
    @IBInspectable var fieldName: String? {
        didSet {
            
        }
    }
    var pickerData: [String]?
    
    @IBInspectable var insetX: CGFloat = 10 {
        didSet {
            layoutIfNeeded()
        }
    }
    @IBInspectable var insetY: CGFloat = 10 {
        didSet {
            layoutIfNeeded()
        }
    }
    
    @IBInspectable var type: Int = 0 {
        didSet {
            initView()
        }
    }
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: insetX, dy: insetY)
    }
    
    // text position
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: insetX, dy: insetY)
    }
    
    override func awakeFromNib() {
        initView()
    }
    
    func initView() {
        
        if type == Dialog.TYPE_PICKER {
            rightViewMode = UITextField.ViewMode.always
            rightView = UIImageView(frame: CGRect(x: 0, y: 0, width: 16 + 10, height: 9.0))
            rightView!.contentMode = UIView.ContentMode.center
            (rightView as! UIImageView).image = UIImage(named: "arrowDownSelected")
        }
        
        addTarget(self, action: #selector(onTouch), for: .touchUpInside)
    }
    
    @IBAction func onTouch() {
        
        for view in self.superview!.subviews {
            if (view.isFirstResponder) {
                view.resignFirstResponder()
            }
        }
        
        
        let dialog = Dialog()
        dialog.delegate = self
        dialog.text = self.text!
        dialog.show()
        dialog.setup(type)
        dialog.textView.becomeFirstResponder()
        if fieldName != nil {
            dialog.pickerTitle.text = fieldName
            dialog.textTitle.text = fieldName
        }
        if (pickerData != nil) {dialog.pickerData = pickerData!}
    }
    
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
    
    func onDialogResult(text: String) {
        self.text = ""
        self.insertText(text)
    }
}


extension UITextField {
    func addDoneCancelToolbar(onDone: (target: Any, action: Selector)? = nil, onCancel: (target: Any, action: Selector)? = nil) {
        let onCancel = onCancel ?? (target: self, action: #selector(cancelButtonTapped))
        let onDone = onDone ?? (target: self, action: #selector(doneButtonTapped))
        
        let toolbar: UIToolbar = UIToolbar()
        toolbar.barStyle = .default
        toolbar.items = [
            UIBarButtonItem(title: "Done", style: .plain, target: onCancel.target, action: onCancel.action),
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil),
            UIBarButtonItem(title: "Next", style: .done, target: onDone.target, action: onDone.action)
        ]
        toolbar.sizeToFit()
        
        self.inputAccessoryView = toolbar
    }
    
    // Default actions:
    @objc func doneButtonTapped() {
//        self.resignFirstResponder()
        
        if let nextField = self.superview?.viewWithTag(self.tag + 1) as? UITextField {
            if nextField is UIField {
                self.resignFirstResponder()
                nextField.sendActions(for: .touchUpInside)
            }
            else {nextField.becomeFirstResponder()}
        } else {
            self.resignFirstResponder()
        }
    }
    @objc func cancelButtonTapped() { self.resignFirstResponder() }
}
