//
//  ConfirmationModal.swift
//  PoseFinder
//
//  Created by Cédric Debroux on 19/10/2022.
//  Copyright © 2022 Apple. All rights reserved.
//

import UIKit
import CoreData

protocol ConfirmationModalDelegate {
    func willAppear()
    func willDisappear()
    func SavedData()
}

class ConfirmationModal: UIViewController {
    
    @IBOutlet var nameField: UITextField!
    @IBOutlet var poseImage: PoseImageView!
    
    var delegate: ConfirmationModalDelegate!
    var currentPose: [Pose]!
    var currentPosesSize: CGSize!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        
        
        view.addGestureRecognizer(tap)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let scale = currentPosesSize.width / 480
        poseImage.show(poses: currentPose, scale: CGFloat(scale))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        delegate.willAppear()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        delegate.willDisappear()
    }
    
    @IBAction func cancelButtonTapped() {
        self.dismiss(animated: true)
    }
    
    @IBAction func saveButtonTapped() {
        if nameField.text?.isEmpty == false {
            addNewPose()
            self.dismiss(animated: true)
        }
    }
    
    @objc func dismissKeyboard() {
         view.endEditing(true)
    }
}

extension ConfirmationModal {
    func addNewPose() {
        SavedPoses.shared.poses.append(Ghost(name: nameField.text!, poses: currentPose, size: currentPosesSize))
        delegate.SavedData()
    }
}


