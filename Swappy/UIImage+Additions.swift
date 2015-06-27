//
//  UIImage+Additions.swift
//  Swappy
//
//  Created by Yaroslav Skorokhid on 6/27/15.
//  Copyright (c) 2015 Starry Night. All rights reserved.
//

import Foundation
import AVFoundation

extension UIImage {
    // MARK: UIImage helpers
    
    class func scaleImage(image: UIImage, toSize size: CGSize) -> UIImage {
        UIGraphicsBeginImageContext(size)
        image.drawInRect(CGRect(x: 0, y: 0, width: size.width, height: size.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
    
    class func cropImage(image: UIImage, toRect rect: CGRect) -> UIImage {
        let contextImage: UIImage = UIImage(CGImage: image.CGImage)!
        
        // Create bitmap image from context using the rect
        let imageRef: CGImageRef = CGImageCreateWithImageInRect(contextImage.CGImage, rect)
        
        // Create a new image based on the imageRef and rotate back to the original orientation
        let resultImage: UIImage = UIImage(CGImage: imageRef, scale: image.scale, orientation: image.imageOrientation)!
        
        return resultImage
    }
    
    class func optimizeImage(image: UIImage) -> UIImage {
        let maxWidth: CGFloat = 2000
        let maxHeight: CGFloat = 1000
        
        
        
        let aspectRatio = image.size.width / image.size.height
        var scaledImage = image
        if (image.size.width > maxWidth || image.size.height > maxHeight) {
            let size = AVMakeRectWithAspectRatioInsideRect(image.size, CGRect(x: 0, y: 0, width: maxWidth, height: maxHeight)).size
            scaledImage = self.scaleImage(image, toSize: size)
        }
        
        let lighterImage = UIImage(data: UIImageJPEGRepresentation(scaledImage, 0.8))!
        return lighterImage
    }
}