//
//  CameraInputBarAccessoryView.swift
//  MeloMeter
//
//  Created by LTS on 2023/08/25.
//

import InputBarAccessoryView
import UIKit

// MARK: - CameraInputBarAccessoryViewDelegate

protocol CameraInputBarAccessoryViewDelegate: InputBarAccessoryViewDelegate {
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith attachments: [AttachmentManager.Attachment])
    func sendCameraImage(_ image: UIImage)
    func downKeyboard()
}

// MARK: - CameraInputBarAccessoryView

class CameraInputBarAccessoryView: InputBarAccessoryView {
    private var imageSourceType: Bool = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Internal
    
    lazy var attachmentManager: AttachmentManager = { [unowned self] in
        let manager = AttachmentManager()
        manager.delegate = self
        return manager
    }()
    
    func configure() {
        let camera = makeButton(named: "chatCamera")
        camera.tintColor = .white
        camera.onTouchUpInside { [weak self] _ in
            self?.showImagePickerControllerActionSheet()
        }
        setLeftStackViewWidthConstant(to: 52, animated: true)
        setStackViewItems([camera], forStack: .left, animated: false)
        padding.left = 0
        inputPlugins = [attachmentManager]
        attachmentManager.delegate = self
        
    }
    
    override func didSelectSendButton() {
        if attachmentManager.attachments.count > 0 {
            (delegate as? CameraInputBarAccessoryViewDelegate)?
                .inputBar(self, didPressSendButtonWith: attachmentManager.attachments)
            for _ in 0..<attachmentManager.attachments.count { attachmentManager.removeAttachment(at: 0) }
            setAttachmentManager(active: false)
        }
        else {
            delegate?.inputBar(self, didPressSendButtonWith: inputTextView.text)
        }
    }
    
    // MARK: Private
    
    func makeButton(named _: String) -> InputBarButtonItem {
        InputBarButtonItem()
            .configure {
                $0.image = UIImage(named: "chatCamera")
                $0.setSize(CGSize(width: 44, height: 44), animated: false)
            }.onSelected {
                $0.tintColor = .gray2
            }.onDeselected {
                $0.tintColor = UIColor.lightGray
            }.onTouchUpInside { _ in
                print("Item Tapped")
            }
    }
}

// MARK: UIImagePickerControllerDelegate, UINavigationControllerDelegate

extension CameraInputBarAccessoryView: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @objc
    func showImagePickerControllerActionSheet() {
        let photoLibraryAction = UIAlertAction(title: "앨범에서 선택하기", style: .default) { [weak self] _ in
            self?.showImagePickerController(sourceType: .photoLibrary)
        }
        
        let cameraAction = UIAlertAction(title: "사진 찍기", style: .default) { [weak self] _ in
            self?.showImagePickerController(sourceType: .camera)
        }
        
        let cancelAction = UIAlertAction(title: "취소", style: .destructive, handler: nil)
        
        AlertManager.showAlert(
            style: .actionSheet,
            title: "사진",
            message: nil,
            actions: [cameraAction, photoLibraryAction, cancelAction],
            completion: nil)
    }
    
    func showImagePickerController(sourceType: UIImagePickerController.SourceType) {
        let imgPicker = UIImagePickerController()
        imgPicker.delegate = self
        imgPicker.allowsEditing = true
        if sourceType == .camera {
            self.imageSourceType = true
        }else {
            self.imageSourceType = false
        }
        imgPicker.sourceType = sourceType
        imgPicker.presentationController?.delegate = self
        inputAccessoryView?.isHidden = true
        getTopViewController()?.present(imgPicker, animated: true, completion: nil)
    }
    
    func imagePickerController(
        _: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any])
    {
        if self.imageSourceType {
            if let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
                (delegate as? CameraInputBarAccessoryViewDelegate)?
                    .sendCameraImage(image)
            }
        }
        if let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            inputPlugins.forEach { _ = $0.handleInput(of: editedImage) }
        }
        else if let originImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            inputPlugins.forEach { _ = $0.handleInput(of: originImage) }
        }
        
        getTopViewController()?.dismiss(animated: true, completion: nil)
        inputAccessoryView?.isHidden = false
        (delegate as? CameraInputBarAccessoryViewDelegate)?.downKeyboard()
    }

    func imagePickerControllerDidCancel(_: UIImagePickerController) {
        getTopViewController()?.dismiss(animated: true, completion: nil)
        inputAccessoryView?.isHidden = false
    }
    
    func getRootViewController() -> UIViewController? {
        (UIApplication.shared.delegate as? SceneDelegate)?.window?.rootViewController
    }
    func getTopViewController() -> UIViewController? {
        var topViewController = UIApplication.shared.keyWindow?.rootViewController
        
        while let presentedViewController = topViewController?.presentedViewController {
            topViewController = presentedViewController
        }
        
        return topViewController
    }
}

// MARK: AttachmentManagerDelegate

extension CameraInputBarAccessoryView: AttachmentManagerDelegate {
    // MARK: - AttachmentManagerDelegate
    
    func attachmentManager(_ manager: AttachmentManager, shouldBecomeVisible: Bool) {
        setAttachmentManager(active: shouldBecomeVisible)
    }
    
    func attachmentManager(_ manager: AttachmentManager, didReloadTo _: [AttachmentManager.Attachment]) {
        if manager.attachments.count > 0 {
            sendButton.isEnabled = true
        }
    }
    
    func attachmentManager(_ manager: AttachmentManager, didInsert cell: AttachmentManager.Attachment, at index: Int) {
        manager.dataSource?.attachmentManager(manager, cellFor: cell, at: index)
            .deleteButton.setImage(UIImage(named: "cancel"), for: .normal)
        if manager.attachments.count > 0 {
            sendButton.isEnabled = true
        }
    }
    
    func attachmentManager(_ manager: AttachmentManager, didRemove _: AttachmentManager.Attachment, at _: Int) {
        if manager.attachments.count > 0 {
            sendButton.isEnabled = true
        }
    }

    func attachmentManager(_ manager: AttachmentManager, didSelectAddAttachmentAt index: Int) {
        self.showImagePickerControllerActionSheet()
    }

    // MARK: - AttachmentManagerDelegate Helper
    
    func setAttachmentManager(active: Bool) {
        let topStackView = topStackView
        if active, !topStackView.arrangedSubviews.contains(attachmentManager.attachmentView) {
            topStackView.insertArrangedSubview(attachmentManager.attachmentView, at: topStackView.arrangedSubviews.count)
            topStackView.layoutIfNeeded()
        } else if !active, topStackView.arrangedSubviews.contains(attachmentManager.attachmentView) {
            topStackView.removeArrangedSubview(attachmentManager.attachmentView)
            topStackView.layoutIfNeeded()
            invalidateIntrinsicContentSize()
        }
    }
}

// MARK: UIAdaptivePresentationControllerDelegate

extension CameraInputBarAccessoryView: UIAdaptivePresentationControllerDelegate {
    // Swipe to dismiss image modal
    public func presentationControllerWillDismiss(_: UIPresentationController) {
        isHidden = false
    }
}
