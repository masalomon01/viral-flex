import UIKit

class Dialog: UIView, UIPickerViewDelegate, UIPickerViewDataSource {
    
    
    static let TYPE_TEXT = 0
    static let TYPE_NUMBER = 1
    static let TYPE_PICKER = 2
    static let TYPE_VACCINATIONS = 3
    
    @IBOutlet weak var textTitle: UILabel!
    @IBOutlet weak var pickerTitle: UILabel!
    @IBOutlet weak var labelDialogTitle: UILabel!
    @IBOutlet weak var textFieldTitle: UITextField! {
        didSet { textFieldTitle?.addDoneCancelToolbar() }
    }
    @IBOutlet weak var textAge: UITextField! {
        didSet { textAge?.addDoneCancelToolbar() }
    }
    @IBOutlet weak var textDoses: UITextField! {
        didSet { textDoses?.addDoneCancelToolbar() }
    }
    @IBOutlet weak var textAdmin: UIField! {
        didSet { textAdmin?.addDoneCancelToolbar() }
    }
    @IBOutlet weak var textBrand: UITextField! {
        didSet { textBrand?.addDoneCancelToolbar() }
    }
    
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var picker: UIPickerView!
    
    @IBOutlet weak var buttonCancel: UIButton!
    @IBOutlet weak var buttonDone: UIButton!
    
    var dialogType: Int!
    var text: String = ""
    var pickerData:[String] = []
    var vaccination: Vaccination?
    var dim: UIView!
    var delegate: DialogDelegate?
    var vaccinationsDelegate: DialogVaccinationsDelegate?
    
    var x: CGFloat!
    var y: CGFloat!
    
    init() {
        let window = UIApplication.shared.keyWindow!
        super.init(frame: CGRect(x: 0, y: window.frame.height - 300, width: window.frame.width, height: 300))
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setup(_ dialogType: Int) {
        self.dialogType = dialogType
        let index = dialogType == 0 ? dialogType:(dialogType - 1)
        
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: String(describing: type(of: self)), bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[index] as! UIView
        
        
        let window = UIApplication.shared.keyWindow!
        var width = window.frame.width
        x = CGFloat(0.0)
        y = window.frame.height - view.frame.height
        if dialogType == Dialog.TYPE_VACCINATIONS {
            width -= 100
            x = (window.frame.width - width) / 2.0
            y = 50
        }
        
        
        view.frame = CGRect(x: 0, y: 0, width: width, height: view.frame.height)
        self.frame = CGRect(x: x, y: y, width: width , height: view.frame.height)
        
        addSubview(view)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        if dialogType == Dialog.TYPE_TEXT {
            view.layer.cornerRadius = CGFloat(20)
            textView.text = self.text
        }
        else if dialogType == Dialog.TYPE_NUMBER {
            view.layer.cornerRadius = CGFloat(20)
            textView.text = self.text
            textView.keyboardType = .numberPad
        }
        else if dialogType == Dialog.TYPE_PICKER {
            view.layer.cornerRadius = CGFloat(20)
            picker.showsSelectionIndicator = true
        }
        else {
            view.layer.cornerRadius = CGFloat(20)
            if vaccination == nil{
                vaccination = Vaccination("New Vaccination")
                labelDialogTitle.isHidden = true
                textFieldTitle.isHidden = false
                textFieldTitle.becomeFirstResponder()
            }
            else {
                labelDialogTitle.text = vaccination?.name.replacingOccurrences(of: "\n", with: " ")
                
                if vaccination!.age != nil {textAge.text = String(vaccination!.age!)}
                if vaccination!.doses != nil {textDoses.text = String(vaccination!.doses!)}
                textAdmin.text = vaccination?.admin
                textBrand.text = vaccination?.brand
            }
            
            textAdmin.pickerData = ["Oral", "Injection", "Coarse spray", "Intraocular", "Intramuscular", "Nasal drop", "Water", "In-ovo", "Wing-web"]
        }
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
    
    @IBAction func onCancelClick(_ sender: Any) {
        hide()
    }
    @IBAction func onDoneClick(_ sender: Any) {
        if dialogType == Dialog.TYPE_TEXT || dialogType == Dialog.TYPE_NUMBER {
            delegate?.onDialogResult(text: textView.text)
        }
        else if dialogType == Dialog.TYPE_PICKER {
            delegate?.onDialogResult(text: self.text)
        }
        else {
            
            if (textFieldTitle.text != "") {labelDialogTitle.text = textFieldTitle.text}
            vaccination?.name = labelDialogTitle.text
            vaccination?.age = Int(textAge.text!)
            vaccination?.doses = Int(textDoses.text!)
            vaccination?.admin = textAdmin.text
            vaccination?.brand = textBrand.text
            vaccinationsDelegate?.onDialogResult(vaccination!)
        }
        hide()
    }
    
    @IBAction func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            
            let window = UIApplication.shared.keyWindow!
            let y = max(window.frame.height - (self.frame.height + keyboardSize.height), 0)
            if self.y > y {self.frame.origin.y = y}
            else {self.frame.origin.y = self.y}
        }
    }
    
    @IBAction func keyboardWillHide(notification: NSNotification) {
        self.frame.origin.y = y
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.text = pickerData[row]
    }
}

protocol DialogDelegate {
    func onDialogResult(text: String)
}

protocol DialogVaccinationsDelegate {
    func onDialogResult(_ vaccination: Vaccination)
}
