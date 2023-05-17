//
//  SelectVC.swift
//  imageViewCrop
//
//  Created by Kirit on 16/05/23.
//

import UIKit
import PhotosUI
import TOCropViewController

import TOCropViewController

class SelectVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    func presentCropViewController(image: UIImage) {
        let cropViewController = TOCropViewController(image: image)
        cropViewController.delegate = self
        cropViewController.aspectRatioPreset = .preset16x9
        cropViewController.aspectRatioLockEnabled = true
        cropViewController.toolbar.resetButtonHidden = true
        cropViewController.toolbar.clampButtonHidden = true
        present(cropViewController, animated: true, completion: nil)
    }
    
    @IBAction func onClickCamera(_ sender: Any) {
        let alert = UIAlertController(title: "", message: "" , preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "camera", style: .default, handler: { _ in
            self.onClickCamera()
        }))
        
        alert.addAction(UIAlertAction(title: "gallary", style: .default, handler: { _ in
            self.onClickPhoto()
        }))
        
        alert.addAction(UIAlertAction.init(title: "Cancle", style: .cancel, handler: nil))
        
        //If you want work actionsheet on ipad then you have to use popoverPresentationController to present the actionsheet, otherwise app will crash in iPad
        switch UIDevice.current.userInterfaceIdiom {
        case .pad:
            alert.popoverPresentationController?.sourceView = send as? UIView
            alert.popoverPresentationController?.sourceRect = (send as AnyObject).bounds
            alert.popoverPresentationController?.permittedArrowDirections = .up
        default:
            break
        }
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func onClickCamera() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .camera;
            imagePicker.allowsEditing = true
            self.present(imagePicker, animated: true, completion: nil)
        } else {
           print("error")
        }
    }
    
    
    func onClickPhoto() {
        
        if #available(iOS 14, *) {
            var config = PHPickerConfiguration(photoLibrary: PHPhotoLibrary.shared())
            config.selectionLimit = 1
            config.filter = .none
            config.filter = PHPickerFilter.any(of: [.images])
            //config.filter = .videos
            config.preferredAssetRepresentationMode = .current
            let picker = PHPickerViewController(configuration: config)
            picker.delegate = self
            
            picker.view.backgroundColor = UIColor.white
            DispatchQueue.main.async {
                self.present(picker, animated: true, completion: nil)
            }
        }else{
        
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.sourceType = .photoLibrary
                //imagePicker.allowsEditing = false
                if #available(iOS 13.0, *) {
                    imagePicker.modalPresentationStyle = .fullScreen
                }
                self.present(imagePicker, animated: true, completion: nil)
            }
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension SelectVC: TOCropViewControllerDelegate {
    func cropViewController(_ cropViewController: TOCropViewController, didCropToImage image: UIImage, with cropRect: CGRect, angle: Int) {
        // Handle the cropped image here
        // The 'image' parameter contains the cropped image
        // Dismiss the crop view controller if needed
        cropViewController.dismiss(animated: true, completion: nil)
    }
}

extension SelectVC : UIImagePickerControllerDelegate, UINavigationControllerDelegate,PHPickerViewControllerDelegate {
    @available(iOS 14, *)
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        dismiss(animated: true, completion: nil)
        guard let result = results.first else { return }
        let prov = result.itemProvider
        if prov.canLoadObject(ofClass: UIImage.self) {
            
            prov.loadObject(ofClass: UIImage.self) { imageMaybe, errorMaybe in
                
                if errorMaybe != nil{
                    print("Error = ",errorMaybe)
                }
                if let image = imageMaybe as? UIImage {
                    DispatchQueue.main.async {
                        //self.setCropView(image: image)
                        
                        self.presentCropViewController(image: image)
                        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ViewController") as? ViewController
                        
                        vc?.img = image
                        let nav = UINavigationController(rootViewController: vc!)
                        nav.modalPresentationStyle = .fullScreen
                       // self.present(nav, animated: true)
                       // self.setBannerImage(image: image)
                    }
                }
            }
        }
    }
    // MARK: - IMAGE PICKER DELEGATE
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        //let assetPath = info[UIImagePickerController.InfoKey.phAsset] as! NSURL
        //if (assetPath.absoluteString?.hasSuffix("JPG"))!  || (assetPath.absoluteString?.hasSuffix("PNG"))! || (assetPath.absoluteString?.hasSuffix("JPEG"))! || (assetPath.absoluteString?.hasSuffix("GIF"))! {
        if let image = info[.originalImage] as? UIImage {
            picker.dismiss(animated: true, completion: {
                
            })
            //setCropView(image: image)
//            let
//            setBannerImage(image: image)
//
            self.presentCropViewController(image: image)
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ViewController") as? ViewController
            vc?.img = image
            let nav = UINavigationController(rootViewController: vc!)
            nav.modalPresentationStyle = .fullScreen
           // self.present(nav, animated: true)
            
        } else {
            print("Unknown")
           
        }
    }
//    func (image:UIImage){
//        let editedImage = image .scaleAndRotateImage(image, withSize: 1000)
//
//        //self.imgBanner.image = editedImage;
//        //isprofilePicEdit = true
//        //dismiss(animated: true, completion: nil)
//
//        let cropController = CropViewController(croppingStyle: CropViewCroppingStyle.default , image: editedImage!)
//        //cropController.modalPresentationStyle = .fullScreen
//        cropController.delegate = self
//        cropController.customAspectRatio = CGSize(width: 4, height: 5)
//        //cropController.aspectRatioPreset = .presetSquare; //Set the initial aspect ratio as a square
//        cropController.aspectRatioLockEnabled = true // The crop box is locked to the aspect ratio and can't be resized away from it
//        cropController.aspectRatioPickerButtonHidden = true
//        cropController.resetButtonHidden = false
//        cropController.resetAspectRatioEnabled = false
//        if #available(iOS 13.0, *) {
//            cropController.modalPresentationStyle = .fullScreen
//        }
//        self.present(cropController, animated: true, completion: nil)
//    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}
