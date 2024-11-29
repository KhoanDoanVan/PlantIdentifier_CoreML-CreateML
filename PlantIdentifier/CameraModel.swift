//
//  CameraModel.swift
//  PlantIdentifier
//
//  Created by Đoàn Văn Khoan on 29/11/24.
//

import Foundation
import AVFoundation
import SwiftUI

@MainActor
class CameraModel: NSObject, ObservableObject, AVCapturePhotoCaptureDelegate {
    @Published var isTaken = false
    @Published var session = AVCaptureSession()
    @Published var alert = false
    
    @Published var output = AVCapturePhotoOutput()
    @Published var pictureData = Data(count: 0)
    
    @Published var preview: AVCaptureVideoPreviewLayer!
    
    @Published var uiImage: UIImage?
        
    /// Check
    func Check() {
        /// Check Permission
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            setUp()
            return
        case .notDetermined:
            /// Retusting for permission
            AVCaptureDevice.requestAccess(for: .video) { status in
                if status {
                    self.setUp()
                }
            }
        case .denied:
            self.alert.toggle()
            return
        default:
            return
        }
    }
    
    /// Setup
    func setUp() {
        do {
            /// Setting Config
            self.session.beginConfiguration()
            
            guard let device = AVCaptureDevice.default(.builtInDualCamera, for: .video, position: .back) ?? AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
                print("Error: No camera avaiable")
                return
            }
            
            let input = try AVCaptureDeviceInput(device: device)
            
            /// Cheking and adding to session
            if self.session.canAddInput(input) {
                self.session.addInput(input)
            }
            if self.session.canAddOutput(self.output) {
                self.session.addOutput(self.output)
            }
            
            self.session.commitConfiguration()
            
        } catch {
            print(error.localizedDescription)
        }
    }
    
    /// Take
    func takePicture() {
        self.output.capturePhoto(with: AVCapturePhotoSettings(), delegate: self)
        
        DispatchQueue.global(qos: .background).async {
            /// Need inherit AVCapturePhotoCaptureDelegate for set delegate
            self.output.capturePhoto(with: AVCapturePhotoSettings(), delegate: self)
            self.session.stopRunning()
            
            DispatchQueue.main.async {
                withAnimation {
                    self.isTaken.toggle()
                }
            }
        }
    }
    
    
    /// Retake
    func reTakePicture() {
        DispatchQueue.global(qos: .background).async {
            self.session.startRunning()
            
            DispatchQueue.main.async {
                withAnimation {
                    self.uiImage = nil
                    self.isTaken.toggle()
                }
            }
        }
    }
    
    func takePic() {
        self.output.capturePhoto(with: AVCapturePhotoSettings(), delegate: self)
    }

    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if error != nil{
            return
        }
        DispatchQueue.global(qos: .background).async {
            self.session.stopRunning()
            DispatchQueue.main.async {
                withAnimation{self.isTaken.toggle()}
            }
        }
        
        guard let imageData = photo.fileDataRepresentation() else {
            print("Failed to get image data representation.")
            return
        }
        
        self.pictureData = imageData  // Assuming pictureData is of type Data

        print("Original image data size: \(imageData.count) bytes")

        // Directly pass imageData to the crop function without base64 encoding/decoding
        if let croppedImage = cropCenterImage(from: imageData) {
            self.uiImage = croppedImage
            print("Cropped image size: \(croppedImage.size)")
        } else {
            print("Failed to crop the image.")
        }
    }
    
//    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: (any Error)?) {
//        if error != nil {
//            print("Error capturing photo: \(String(describing: error))")
//            return
//        }
//        
//        guard let imageData = photo.fileDataRepresentation() else {
//            print("Failed to get image data representation.")
//            return
//        }
//        
//        self.pictureData = imageData  // Assuming pictureData is of type Data
//        
//        print("Original image data size: \(imageData.count) bytes")
//        
//        // Directly pass imageData to the crop function without base64 encoding/decoding
//        if let croppedImage = cropCenterImage(from: imageData) {
//            self.uiImage = croppedImage
//            print("Cropped image size: \(croppedImage.size)")
//        } else {
//            print("Failed to crop the image.")
//        }
//    }
    
//    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: (any Error)?) {
//        if error != nil {
//            return
//        }
//        
//        guard let imageData = photo.fileDataRepresentation() else { return }
//        
//        self.pictureData = imageData
//        
//        print(pictureData)
//        
//        if let imageData = Data(base64Encoded: pictureData),
//           let croppedImage = cropCenterImage(from: imageData) {
//            self.uiImage = croppedImage
//            print("Cropped image size: \(croppedImage.size)")
//        }
//    }
    
    func startSession() {
        DispatchQueue.global(qos: .background).async {
            self.session.startRunning()
        }
    }
}
