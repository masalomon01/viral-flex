import UIKit
import WebKit

class HelpViewController: UIViewController {
    
    @IBOutlet weak var webView: WKWebView!
    
    override func viewDidLoad() {
        
        let preferences = WKPreferences()
        preferences.javaScriptEnabled = true
        webView.configuration.preferences = preferences
        webView.load(URLRequest.init(url: URL.init(string: "https://www.rapid-genomics.com/app-documentation/")!))
    }
    
    @IBAction func onBackClick(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
