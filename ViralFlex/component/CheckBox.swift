import UIKit

class CheckBox: UIButton {
    
    override func awakeFromNib() {
        self.setImage(UIImage(named:"checkbox_unchecked"), for: .normal)
        self.setImage(UIImage(named:"checkbox_checked"), for: .selected)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
//        let point:CGPoint = touches.first!.location(in: self)
//        if !self.frame.contains(point) {return super.touchesEnded(touches, with: event)}
        
//        setSelected(selected: !self.isSelected)
        super.touchesEnded(touches, with: event)
    }
    
    func setSelected(selected: Bool) {
    
        self.isSelected = selected
        UIView.animate(withDuration: 0.1, delay: 0, options: .curveLinear, animations: {
            self.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
            
        }) { (success) in
            UIView.animate(withDuration: 0.1, delay: 0, options: .curveLinear, animations: {
                self.transform = .identity
                
            }, completion: nil)
        }
    }
}
