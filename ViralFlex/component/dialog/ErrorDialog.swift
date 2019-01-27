import UIKit


class ErrorDialog: UIView, UITextFieldDelegate {
    
    var dim: UIView!
    
    
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
        let x = (window.frame.width - width) / 2.0
        let y = 50.0
        
        view.frame = CGRect(x: 0, y: 0, width: width, height: view.frame.height)
        self.frame = CGRect(x: x, y: CGFloat(y), width: width , height: view.frame.height)
        
        addSubview(view)
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
        hide()
    }
    
    @IBAction func onCancelClick(_ sender: Any) {
        hide()
    }
}
