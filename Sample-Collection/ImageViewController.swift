//
//  ImageViewController.swift
//  Sample-Collection
//
//  Created by Joseph Tocco on 10/23/18.
//  Copyright © 2018 Joseph Ryan Tocco. All rights reserved.
//

import UIKit

protocol ImageViewControllerDelegate {
    func sendImageData(_ image: UIImage)
}

class ImageViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var libraryButton: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var saveImageButton: UIButton!
    
    let imagePickerController = UIImagePickerController()
    var image: UIImage!
    var delegate: ImageViewControllerDelegate?
    var navigationControllerDelegate: UINavigationController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view
        
        imagePickerController.delegate = self
        navigationControllerDelegate?.delegate = self
        
        imageView.image = self.image
        
        let deleteButton: UIBarButtonItem!
        deleteButton = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deleteImage))
        deleteButton.tintColor = UIColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 0.75)
        self.navigationItem.rightBarButtonItem = deleteButton
        
        if let imageToCompareWith = UIImage(named: "plus_image") {
            print("Comapare Image Aailable")
            let dataOfImageToCompareWith = UIImagePNGRepresentation(imageToCompareWith)
            if let passedImageFromHomeData = UIImagePNGRepresentation(self.image) {
                if passedImageFromHomeData == dataOfImageToCompareWith {
                    print("Compare Succeed")
                    image = nil
                    self.imageView.image = image
                    enableOrDisable(cameraButton: false, libraryButton: false, saveImageButton: true)
                    deleteButton.isEnabled = false
                } else {
                    deleteButton.isEnabled = true
                    enableOrDisable(cameraButton: true, libraryButton: true, saveImageButton: false)
                }
            } else {
                print("Can't Convert passed image data to NSData")
            }
        } else {
            print("plus_image not avilable")
        }
    }
    
    func enableOrDisable(cameraButton: Bool, libraryButton: Bool, saveImageButton: Bool) -> () {
        self.cameraButton.isHidden = cameraButton
        self.saveImageButton.isHidden = saveImageButton
        self.libraryButton.isHidden = libraryButton
    }
    
    func deleteImage() {
        self.image = nil
        self.imageView.image = image
        enableOrDisable(cameraButton: false, libraryButton: false, saveImageButton: true)
        delegate?.sendImageData(UIImage(named: "plus_image")!)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        print("View Controller is: ", viewController)
    }
    
    @IBAction func useCamera() {
        if(UIImagePickerController.isSourceTypeAvailable(.camera)) {
            imagePickerController.sourceType = .camera
            self.present(imagePickerController, animated: true, completion: nil)
        } else {
            // TODO: Give alert message.
            print("Camera not available")
        }
    }
    
    @IBAction func useLibrary() {
        imagePickerController.sourceType = .photoLibrary
        self.present(imagePickerController, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info : [String : Any]) {
        self.image = info[UIImagePickerControllerOriginalImage] as! UIImage
        self.imageView.image = image
        picker.dismiss(animated: true, completion: nil)
        viewDidLoad()
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveImage() {
        delegate?.sendImageData(self.image)
        _ = navigationController?.popViewController(animated: true)
    }
}
