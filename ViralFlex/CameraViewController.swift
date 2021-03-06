import UIKit

class CameraViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var imageView: UIImageView!
    var picker: UIImagePickerController!
    
    override func viewDidLoad() {
        
        picker = UIImagePickerController()
        
        
        self.view.backgroundColor = UIColor.white

        self.imageView = UIImageView()
        self.imageView.frame = CGRect(x: self.view.frame.size.width / 4 / 2, y: 64, width: self.view.frame.size.width / 4 * 3, height: self.view.frame.size.height / 4 * 2)
        self.imageView.image = UIImage(named: "profile")

        let cameraBtn: UIButton = UIButton()
        cameraBtn.frame = CGRect(x: self.view.frame.size.width / 4 / 2, y: 30 + self.imageView.frame.origin.y + self.imageView.frame.size.height, width: self.view.frame.size.width / 4 * 3, height: 50)
        cameraBtn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 30)
        cameraBtn.setTitle("Camera", for: .normal)
        cameraBtn.setTitleColor(UIColor.white, for: .normal)
        cameraBtn.layer.cornerRadius = 10
        cameraBtn.backgroundColor = UIColor.darkGray
        cameraBtn.addTarget(self, action: #selector(self.onCameraBtnAction(_:)), for: UIControl.Event.touchUpInside)

        let photoBtn: UIButton = UIButton()
        photoBtn.frame = CGRect(x: self.view.frame.size.width / 4 / 2, y: 30 + cameraBtn.frame.origin.y + cameraBtn.frame.size.height, width: self.view.frame.size.width / 4 * 3, height: 50)
        photoBtn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 30)
        photoBtn.setTitle("Album", for: .normal)
        photoBtn.setTitleColor(UIColor.white, for: .normal)
        photoBtn.layer.cornerRadius = 10
        photoBtn.backgroundColor = UIColor.darkGray
        photoBtn.addTarget(self, action: #selector(self.onPhotoBtnAction(_:)), for: UIControl.Event.touchUpInside)

        self.view.addSubview(self.imageView)
        self.view.addSubview(cameraBtn)
        self.view.addSubview(photoBtn)
        
        self.callGetPhoneWithKind(1);
    }

    
    
    func callGetPhoneWithKind(_ kind: Int) {
        
        switch kind {
        case 1:
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera) {
                picker.sourceType = UIImagePickerController.SourceType.camera
                picker.allowsEditing = true
                picker.delegate = self
                self.present(picker, animated: true, completion: nil)
            }
        default:
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.photoLibrary) {
                picker.sourceType = UIImagePickerController.SourceType.photoLibrary
                picker.allowsEditing = true
                picker.delegate = self
                self.present(picker, animated: true, completion: nil)
            }
        }
    }
    
    
    @objc func onCameraBtnAction(_ sender: UIButton) {
        self.callGetPhoneWithKind(1)
    }
    
    @objc func onPhotoBtnAction(_ sender: UIButton) {
        self.callGetPhoneWithKind(2)
    }
}
