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
    
    override func viewWillAppear(_ animated: Bool) {
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        let defaults = UserDefaults.standard
        let token = defaults.object(forKey: "token")
        
        if token != nil {
            print(token)
            if let controller = self.storyboard?.instantiateViewController(withIdentifier: "mainViewController") {
                self.present(controller, animated: true, completion: nil)
            }
        }
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
        
        if let path = Bundle.main.path(forResource: "user", ofType: "json") {
            do {
                
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves) as! [Any]
//                for userData in jsonResult {
//                    let user = (userData as! Dictionary<String, AnyObject>)
//
//                    if (userName.text == (user["email"] as! String) && password.text == (user["password"] as! String)) {
                
                        HttpRequest.signin(email: userName.text!, password: password.text!, onRequestSuccess: { token, response in
                            
                            print(response.statusCode)
                            let defaults = UserDefaults.standard
                            defaults.set(token, forKey: "token")
                            defaults.synchronize()

                            DispatchQueue.main.async {
                                
                                if let controller = self.storyboard?.instantiateViewController(withIdentifier: "mainViewController") {
                                    self.present(controller, animated: true, completion: nil)
                                }
                            }
                            
                        }, onRequestFailed: {(response, message) in
                            
                            print(message)
                            print(response.statusCode)
                            DispatchQueue.main.async {
                                
                                if response.statusCode == 429 {
                                    
                                    let message = message
                                    let alertController = UIAlertController(title: "", message: message, preferredStyle: .alert)
                                    
                                    alertController.addAction(UIAlertAction(title: "OK", style: .default) { (action) in })
                                    self.present(alertController, animated: true)
                                }
                                else {
                                    self.error.isHidden = false
                                }
                                
                            }
                        })
//                    }
//                }
            } catch {
                
            }
        }
        return
    }
    
}
