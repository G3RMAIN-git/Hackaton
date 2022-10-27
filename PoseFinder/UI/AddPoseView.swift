//
//  AddPoseView.swift
//  PoseFinder
//
//  Created by Cédric Debroux on 18/10/2022.
//  Copyright © 2022 Apple. All rights reserved.
//

import AVFoundation
import UIKit
import VideoToolbox

protocol AddPoseViewDelegate {
    func dataChange()
}

class AddPoseView: UIViewController {
    
    var delegate: AddPoseViewDelegate!
    
    @IBOutlet var savedPose: UIImageView!
    
    
    @IBOutlet private var previewImageView: PoseImageView!

    private let videoCapture = VideoCapture()

    private var poseNet: PoseNet!

    /// The frame the PoseNet model is currently making pose predictions from.
    private var currentFrame: CGImage?


    /// The set of parameters passed to the pose builder when detecting poses.
    private var poseBuilderConfiguration = PoseBuilderConfiguration()
    
    private var currentPoses: [Pose]?
    private var currentPosesFrame: CGImage?

    override func viewDidLoad() {
        super.viewDidLoad()

        // For convenience, the idle timer is disabled to prevent the screen from locking.
        UIApplication.shared.isIdleTimerDisabled = true

        do {
            poseNet = try PoseNet()
        } catch {
            fatalError("Failed to load model. \(error.localizedDescription)")
        }

        poseNet.delegate = self
        setupAndBeginCapturingVideoFrames()
    }

    private func setupAndBeginCapturingVideoFrames() {
        videoCapture.setUpAVCapture { error in
            if let error = error {
                print("Failed to setup camera with error \(error)")
                return
            }

            self.videoCapture.delegate = self

            self.videoCapture.startCapturing()
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        videoCapture.startCapturing {
            super.viewWillAppear(animated)
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        videoCapture.stopCapturing {
            super.viewWillDisappear(animated)
        }
    }
    

    override func viewWillTransition(to size: CGSize,
                                     with coordinator: UIViewControllerTransitionCoordinator) {
        // Reinitilize the camera to update its output stream with the new orientation.
        setupAndBeginCapturingVideoFrames()
    }
    
    
    @IBAction func savedPoseButton(_ sender: Any) {
        let confirmationModal = storyboard?.instantiateViewController(identifier: "ConfirmationModal") as? ConfirmationModal
        confirmationModal?.modalPresentationStyle = .automatic
        
        confirmationModal?.delegate = self
        confirmationModal?.currentPose = currentPoses
        confirmationModal?.currentPosesSize = currentPosesFrame?.size
    
        present(confirmationModal!, animated: true, completion: nil)
    }
    
    @IBAction func onCameraButtonTapped(_ sender: Any) {
        videoCapture.flipCamera { error in
            if let error = error {
                print("Failed to flip camera with error \(error)")
            }
        }
    }

}


// MARK: - VideoCaptureDelegate

extension AddPoseView: VideoCaptureDelegate {
    func videoCapture(_ videoCapture: VideoCapture, didCaptureFrame capturedImage: CGImage?) {
        guard currentFrame == nil else {
            return
        }
        guard let image = capturedImage else {
            fatalError("Captured image is null")
        }

        currentFrame = image
        poseNet.predict(image)
    }
}

// MARK: - PoseNetDelegate

extension AddPoseView: PoseNetDelegate {
    func poseNet(_ poseNet: PoseNet, didPredict predictions: PoseNetOutput) {
        defer {
            // Release `currentFrame` when exiting this method.
            self.currentFrame = nil
        }

        guard let currentFrame = currentFrame else {
            return
        }

        let poseBuilder = PoseBuilder(output: predictions,
                                      configuration: poseBuilderConfiguration,
                                      inputImage: currentFrame)

        let poses = [poseBuilder.pose]
        if let personPose = poses.first,
            personPose.joints.values.allSatisfy({ $0.isValid }) {
            self.currentPoses = poses
            self.currentPosesFrame = currentFrame
            
             //dump(poses)
        }
        
        previewImageView.show(poses: poses, on: currentFrame)
    }
}

extension AddPoseView : ConfirmationModalDelegate {
    func willAppear() {
        videoCapture.stopCapturing()
    }
    
    func willDisappear() {
        currentPoses = nil
        videoCapture.startCapturing()
    }
    func SavedData() {
        delegate.dataChange()
    }
}
