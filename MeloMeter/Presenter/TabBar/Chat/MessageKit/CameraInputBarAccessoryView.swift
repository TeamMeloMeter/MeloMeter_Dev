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
}

extension CameraInputBarAccessoryViewDelegate {
    func inputBar(_: InputBarAccessoryView, didPressSendButtonWith _: [AttachmentManager.Attachment]) { }
}

// MARK: - CameraInputBarAccessoryView

class CameraInputBarAccessoryView: InputBarAccessoryView {
    // MARK: Lifecycle
    
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
    }
    
    override func didSelectSendButton() {
        if attachmentManager.attachments.count > 0 {
            (delegate as? CameraInputBarAccessoryViewDelegate)?
                .inputBar(self, didPressSendButtonWith: attachmentManager.attachments)
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
        
        AlertService.showAlert(
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
        imgPicker.sourceType = sourceType
        imgPicker.presentationController?.delegate = self
        inputAccessoryView?.isHidden = true
        getTopViewController()?.present(imgPicker, animated: true, completion: nil)
    }
    
    func imagePickerController(
        _: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any])
    {
        if let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            //self.sendImageMessage(photo: editedImage)
            inputPlugins.forEach { _ = $0.handleInput(of: editedImage) }
        }
        else if let originImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            inputPlugins.forEach { _ = $0.handleInput(of: originImage) }
            //self.sendImageMessage(photo: originImage)
        }
        getTopViewController()?.dismiss(animated: true, completion: nil)
        inputAccessoryView?.isHidden = false
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
    
    func attachmentManager(_: AttachmentManager, shouldBecomeVisible: Bool) {
        print("55555555")
        setAttachmentManager(active: shouldBecomeVisible)
    }
    
    func attachmentManager(_ manager: AttachmentManager, didReloadTo _: [AttachmentManager.Attachment]) {
        print("444444444")
        sendButton.isEnabled = manager.attachments.count > 0
    }
    
    func attachmentManager(_ manager: AttachmentManager, didInsert _: AttachmentManager.Attachment, at _: Int) {
        print("33333333332")
        sendButton.isEnabled = manager.attachments.count > 0
    }
    
    func attachmentManager(_ manager: AttachmentManager, didRemove _: AttachmentManager.Attachment, at _: Int) {
        print("22222222222222")
        sendButton.isEnabled = manager.attachments.count > 0
    }

    func attachmentManager(_ manager: AttachmentManager, didSelectAddAttachmentAt index: Int) {
        print("디드셀렉트에드어텟ㅅ치", manager, index)
        showImagePickerControllerActionSheet()
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
