//
//  CameraViewController.swift
//  MeloMeter
//
//  Created by 오현택 on 2023/05/10.
//

import UIKit

//class CameraViewController: UIViewController {
//    let cameraModel = CameraModel()
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        // register to receive the notification to launch the camera
//        NotificationCenter.default.addObserver(self, selector: #selector(launchCamera(_:)), name: Notification.Name("LaunchCamera"), object: nil)
//    }
//    
//    @objc func openCamera(_ sender: Any) {
//        // call the method on the camera model to launch the camera
//        cameraModel.launchCamera()
//    }
//    
//    @objc func launchCamera(_ notification: Notification) {
//        if let imagePickerController = notification.object as? UIImagePickerController {
//            imagePickerController.delegate = self
//            present(imagePickerController, animated: true, completion: nil)
//        }
//    }
//}
//
//extension CameraViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
//    // UIImagePickerControllerDelegate methods
//    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
//        dismiss(animated: true, completion: nil)
//    }
//    
//    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
//        dismiss(animated: true, completion: nil)
//    }
//}
