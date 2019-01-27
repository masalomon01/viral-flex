import UIKit


class SubmitDialog: UIView, UITextFieldDelegate {
    
    
    @IBOutlet weak var formName: UILabel!
    @IBOutlet weak var pin1: UITextField!
    @IBOutlet weak var pin2: UITextField!
    @IBOutlet weak var pin3: UITextField!
    @IBOutlet weak var pin4: UITextField!
    @IBOutlet weak var labelError: UILabel!
    
    
    var dim: UIView!
    var delegate: SubmitDialogDelegate?
    
    var x: CGFloat!
    var y: CGFloat!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)    }
    
    func setup() {
        
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: String(describing: type(of: self)), bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        
        view.layer.cornerRadius = CGFloat(20)
        
        
        let window = UIApplication.shared.keyWindow!
        var width = window.frame.width
        
        width -= 100
        x = (window.frame.width - width) / 2.0
        y = 50.0
        
        view.frame = CGRect(x: 0, y: 0, width: width, height: view.frame.height)
        self.frame = CGRect(x: x, y: CGFloat(y), width: width , height: view.frame.height)
        
        addSubview(view)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func show() {
        let window = UIApplication.shared.keyWindow!
        
        dim = UIView(frame: CGRect(x:0, y:0, width: window.frame.width, height: window.frame.height))
        dim!.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.5)
        dim.alpha = 0
        
        let gesture:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hide))
        gesture.numberOfTapsRequired = 1
        dim.addGestureRecognizer(gesture)
        
        window.addSubview(dim)
        window.addSubview(self)
        
        UIView.animate(withDuration: 0.3) { () -> Void in
            self.dim.alpha = 1.0
        }
    }
    
    @objc func hide() {
        removeFromSuperview()
        dim?.removeFromSuperview()
    }
    
    
    @IBAction func onDoneClick(_ sender: Any) {
        
//        let defaults = UserDefaults.standard
//        let data = defaults.object(forKey: "user")
//        if data != nil {
//            let user = NSKeyedUnarchiver.unarchiveObject(with: data as! Data) as! Dictionary<String, AnyObject>
            
            let pin = pin1.text! + pin2.text! + pin3.text! + pin4!.text!
//            if (pin == String(user["pin"] as! Int)) {
            
            delegate?.onSubmit(dialog: self, pin: Int(pin)!)
//                hide()
//            }
//        }
    }
    
    @IBAction func onCancelClick(_ sender: Any) {
        hide()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return true }
        let count = text.count + string.count - range.length
        return count <= 1
    }
    
    @IBAction func onTextChanged(_ sender: TextField) {
        
        if sender.text?.count == 0 {return}
        if let nextField = sender.superview?.viewWithTag(sender.tag + 1) as? UITextField {
            nextField.becomeFirstResponder()
        } else {
            sender .resignFirstResponder()
        }
    }
    
    @IBAction func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            
            let window = UIApplication.shared.keyWindow!
            let y = window.frame.height - (self.frame.height + keyboardSize.height)
            if self.y > y {self.frame.origin.y = y}
            else {self.frame.origin.y = self.y}
        }
    }
    
    @IBAction func keyboardWillHide(notification: NSNotification) {
        self.frame.origin.y = y
    }
}


protocol SubmitDialogDelegate {
    
    func onSubmit(dialog: SubmitDialog, pin: Int)
}
