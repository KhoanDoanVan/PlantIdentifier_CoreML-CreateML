//
//  Util.swift
//  PlantIdentifier
//
//  Created by Đoàn Văn Khoan on 29/11/24.
//

import UIKit

func cropCenterImage(from imageData: Data, size: CGSize = CGSize(width: 300, height: 300)) -> UIImage? {
    // Step 1: Convert Data to UIImage
    guard let image = UIImage(data: imageData) else {
        print("Failed to create image from data.")
        return nil
    }

    // Step 2: Get CGImage from UIImage
    guard let cgImage = image.cgImage else {
        print("Failed to get CGImage.")
        return nil
    }

    // Step 3: Calculate the cropping rectangle
    let imageWidth = CGFloat(cgImage.width)
    let imageHeight = CGFloat(cgImage.height)
    let x = (imageWidth - size.width) / 2
    let y = (imageHeight - size.height) / 2
    let croppingRect = CGRect(x: x, y: y, width: size.width, height: size.height)

    // Step 4: Crop the image
    guard let croppedCgImage = cgImage.cropping(to: croppingRect) else {
        print("Failed to crop the image.")
        return nil
    }

    // Step 5: Create a new UIImage from the cropped CGImage
    let croppedImage = UIImage(cgImage: croppedCgImage, scale: image.scale, orientation: image.imageOrientation)

    return croppedImage
}
