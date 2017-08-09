//
//  MemeEditorViewController.swift
//  pickImage
//
//  Created by Humberto Sanchez Lara on 7/3/17.
//  Copyright © 2017 Humberto Sanchez. All rights reserved.
//

import UIKit

class MemeEditorViewController: UIViewController, UIImagePickerControllerDelegate,UINavigationControllerDelegate,UITextFieldDelegate {
    
    var meme: Meme!

    @IBOutlet weak var pickedImage: UIImageView!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var topField: UITextField!
    @IBOutlet weak var bottomField: UITextField!
    @IBOutlet weak var toolBar: UIToolbar!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var pickButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setTextFieldFormat()
        
        if meme != nil {
            
            self.topField.text = meme.topText
            self.bottomField.text = meme.bottomText
            self.pickedImage.image = meme.originalImage
            enableShareButton()
        }
        

    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        subscribeToKeyboardNotifications()
        
        
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    
    // MARK: UIImagePickerController Functions
    
    func pickAnImage(source: UIImagePickerControllerSourceType) {
        let controller = UIImagePickerController()
        controller.delegate = self
        controller.sourceType = source
        self.present(controller, animated: true, completion: nil)
    }

    @IBAction func takeImageCamera(_ sender: Any) {
        pickAnImage(source: .camera)
    }
    
    @IBAction func pickAnImage(_ sender: Any) {
        pickAnImage(source: .photoLibrary)
    }
    
    
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
            if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
                pickedImage.image = image
                dismiss(animated: true, completion: nil)
                enableShareButton()
            }
    }
    
    func enableShareButton() {
        shareButton.isEnabled = true
    }
    
    
    // MARK: Keyboard Show and Hide
    
    func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: .UIKeyboardWillHide, object: nil)
    }
    
    
    func unsubscribeFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
    }
    
    func keyboardWillShow(_ notification:Notification) {
        
        if bottomField.isFirstResponder {
            view.frame.origin.y -= getKeyboardHeight(notification)
            view.frame.origin.y += 40
            // or use the following
            // view.frame.origin.y = getKeyboardHeight(notification) * (-1)
        }
        
    }
    
    func getKeyboardHeight(_ notification:Notification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.cgRectValue.height
    }
    
    func keyboardWillHide(_ notification: Notification) {
        
        if bottomField.isFirstResponder {
            view.frame.origin.y = 0
        }
        
    }
    
    // MARK: Textfield Delegate Functions
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextFieldDidEndEditingReason) {
        setTextFieldFormat()
    }
    
    func setTextFieldFormat() {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        
        let memeTextAttributes:[String:Any] = [
            NSStrokeColorAttributeName: UIColor.black,
            NSForegroundColorAttributeName: UIColor.white,
            NSFontAttributeName: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
            NSStrokeWidthAttributeName: -5.0,
            NSParagraphStyleAttributeName: paragraphStyle]
        
        topField.defaultTextAttributes = memeTextAttributes
        bottomField.defaultTextAttributes = memeTextAttributes
        
    }
    
    // MARK: Generate Meme
    
    func hideBars(hideThem: Bool) {
        self.navigationController?.setNavigationBarHidden(hideThem, animated: false)
        toolBar.isHidden = hideThem
    }
    
    func generateMemedImage() -> UIImage {
        
      
        hideBars(hideThem: true)
        // Render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        hideBars(hideThem: false)
        
        return memedImage
    }
    
    // MARK: Save Meme
    
    func save() {
        // Create the meme
        let meme = Meme(topText: topField.text!, bottomText: bottomField.text!, originalImage: pickedImage.image!, memedImage: generateMemedImage())
        
        let object = UIApplication.shared.delegate
        let appDelegate = object as! AppDelegate
        appDelegate.memes.append(meme)
    }
    
 
    @IBAction func cancelButton(_ sender: Any) {
        pickedImage.image = nil
        topField.text = "TOP"
        bottomField.text = "BOTTOM"
        shareButton.isEnabled = false
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func shareButton(_ sender: Any) {
        
        let memedImage = generateMemedImage()
        
        let activityVC = UIActivityViewController(activityItems: [memedImage], applicationActivities: nil)
        
        activityVC.completionWithItemsHandler = { (activityType: UIActivityType?, completed: Bool, returnedItems: [Any]?, error: Error?) -> Void in
            if completed == true {
                self.save()
                self.dismiss(animated: true, completion: nil)
                self.navigationController?.popToRootViewController(animated: true)
                print("Saved")
            }
        }
        
        navigationController?.present(activityVC, animated: true, completion: nil)
        
    }
    


}

