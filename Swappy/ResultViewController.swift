//
//  ResultViewController.swift
//  Swappy
//
//  Created by Yaroslav Skorokhid on 6/27/15.
//  Copyright (c) 2015 Starry Night. All rights reserved.
//

import UIKit

class ResultViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var imageViewWC: NSLayoutConstraint!
    @IBOutlet weak var imageViewHC: NSLayoutConstraint!
    var faces: [Face]!
    var originalImage: UIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.generateMixedFacedImage()
    }
    
    func generateMixedFacedImage() {
        let shuffledFaces = faces.shuffled()
        var finalImage = originalImage
        for i in 0..<faces.count {
            // 1. extract part of image by x,y,w,h from orig face
            // 2. extract part of image by x,y,w,h from shuffled face
            // 3. resize orig face size to be shuffled face size and vice versa
            // 4. put shuffled face image instead of orig face and vice versa
            // 5. repeat for rest faces
            let origFace = faces[i]
            let croppedOrigImage = UIImage.cropImage(originalImage, toRect: origFace.rect)
            let shuffledFace = shuffledFaces[i]
            let resizedCroppedOrigImage = UIImage.scaleImage(croppedOrigImage, toSize: shuffledFace.rect.size)
            
            finalImage = drawImage(resizedCroppedOrigImage, inRect: shuffledFace.rect, onImage: finalImage)
        }
        self.imageViewHC.constant = finalImage.size.height
        self.imageViewWC.constant = finalImage.size.width
        self.imageView.image = finalImage
        self.view.layoutIfNeeded()
    }
    
    func drawImage(imageToDraw: UIImage, inRect: CGRect, onImage: UIImage) -> UIImage {
        UIGraphicsBeginImageContext(onImage.size)
        onImage.drawInRect(CGRect(origin: CGPointZero, size: onImage.size))
        imageToDraw.drawInRect(inRect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }

}
