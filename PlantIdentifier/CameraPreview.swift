//
//  CameraPreview.swift
//  PlantIdentifier
//
//  Created by Đoàn Văn Khoan on 29/11/24.
//

import SwiftUI
import AVFoundation

struct CameraPreview: UIViewRepresentable {
    @ObservedObject var camera: CameraModel
    
    func makeUIView(context: Context) -> some UIView {
        let containerView = UIView(frame: UIScreen.current?.bounds ?? .zero)
        
        // Create the camera preview layer
        camera.preview = AVCaptureVideoPreviewLayer(session: camera.session)
        camera.preview.frame = containerView.bounds
        camera.preview.videoGravity = .resizeAspectFill
        containerView.layer.addSublayer(camera.preview)
        
        // Create the mask to apply a semi-transparent background outside the rounded rectangle
        let maskView = UIView(frame: containerView.bounds)
        maskView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        
        // Create a rounded rectangle path in the center
        let path = UIBezierPath(rect: maskView.bounds)
        let rectanglePath = UIBezierPath(roundedRect: CGRect(x: (maskView.bounds.width - 300) / 2,
                                                              y: (maskView.bounds.height - 300) / 2,
                                                              width: 300,
                                                              height: 300),
                                         cornerRadius: 20)
        path.append(rectanglePath)
        path.usesEvenOddFillRule = true
        
        // Create a shape layer for the mask
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath
        shapeLayer.fillRule = .evenOdd
        maskView.layer.mask = shapeLayer
        
        containerView.addSubview(maskView)
        camera.startSession()
        
        return containerView
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        // No updates needed for now
    }
}

//struct CameraPreview: UIViewRepresentable {
//    @ObservedObject var camera: CameraModel
//    
//    func makeUIView(context: Context) -> some UIView {
//        let view = UIView(frame: UIScreen.current?.bounds ?? .zero)
//        
//        camera.preview = AVCaptureVideoPreviewLayer(session: camera.session)
//        camera.preview.frame = view.frame
//        camera.preview.videoGravity = .resizeAspectFill
//        
//        camera.preview.opacity = 0.5
//        
//        view.layer.addSublayer(camera.preview)
//        
//        camera.session.startRunning()
//        
//        return view
//    }
//    
//    func updateUIView(_ uiView: UIViewType, context: Context) {
//        
//    }
//}


extension UIWindow {
    static var current: UIWindow? {
        for scene in UIApplication.shared.connectedScenes {
            guard let windowScene = scene as? UIWindowScene else { continue }
            for window in windowScene.windows {
                if window.isKeyWindow { return window }
            }
        }
        return nil
    }
}


extension UIScreen {
    static var current: UIScreen? {
        UIWindow.current?.screen
    }
}
