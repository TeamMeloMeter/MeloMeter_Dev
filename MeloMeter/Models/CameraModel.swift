//
//  CameraModel.swift
//  MeloMeter
//
//  Created by 오현택 on 2023/05/10.
//

import UIKit

class CameraModel {
    func launchCamera() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = .camera
        
        NotificationCenter.default.post(name: Notification.Name("LaunchCamera"), object: imagePickerController)
    }
}
