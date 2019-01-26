import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var error: UILabel!
    @IBOutlet weak var userName: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var forgotButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @IBAction func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            let offset = keyboardSize.height - (self.view.frame.height - (forgotButton.frame.origin.y + forgotButton.frame.height))
            self.view.frame.origin.y -= offset
        }
    }
    
    @IBAction func keyboardWillHide(notification: NSNotification) {
        self.view.frame.origin.y = 0
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        textField.next?.becomeFirstResponder()
        return true
    }
    
    @IBAction func onLoginClick(_ sender: Any) {
        
        let gestUserName = "test@rapid-genomics.com"
        let gestPassword = "1234isnotasafepassword"
        
        //        if userName.text != gestUserName || (password.text != gestPassword && password.text != "test") {
        
        //        }
        
        if let path = Bundle.main.path(forResource: "user", ofType: "json") {
            do {
                
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves) as! [Any]
                for userData in jsonResult {
                    let user = (userData as! Dictionary<String, AnyObject>)
                    
                    if ("mario.salomon07@gmail.com" == (user["email"] as! String) && "Testing$123" == (user["password"] as! String)) {
                    //if (userName.text == (user["email"] as! String) && password.text == (user["password"] as! String)) {
                        
                        let defaults = UserDefaults.standard
                        let data = NSKeyedArchiver.archivedData(withRootObject: user)
                        defaults.set(data, forKey: "user")
                        defaults.synchronize()
                        
                        if let controller = self.storyboard?.instantiateViewController(withIdentifier: "mainViewController") {
                            self.present(controller, animated: true, completion: nil)
                        }
                    }
                }
            } catch {
                print(123123123)
            }
        }
        
        error.isHidden = false
        return
        
        
    }
    
}
