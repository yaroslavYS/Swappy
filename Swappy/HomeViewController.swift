//
//  HomeViewController.swift
//  Swappy
//
//  Created by Yaroslav Skorokhid on 6/27/15.
//  Copyright (c) 2015 Starry Night. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    let showResultSegueIdentifier = "ShowResult"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let tapGesture = UITapGestureRecognizer(target: self, action: "tryExampleButtonPressed:")
        self.imageView.addGestureRecognizer(tapGesture)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func selectImageButtonPressed(sender: AnyObject) {
        self.showImagePicker()
    }
    
    @IBAction func tryExampleButtonPressed(sender: AnyObject) {
        self.loadExample("friends", imageName: "example_friends")
    }
    
    @IBAction func tryExample2ButtonPressed(sender: AnyObject) {
        self.loadExample("friends2", imageName: "example_friends2")
    }
    
    func loadExample(jsonFileName: String, imageName: String) {
        let filePath = NSBundle.mainBundle().pathForResource(jsonFileName, ofType: "json")!
        let data = NSData(contentsOfFile: filePath)!
        let json = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.allZeros, error: nil) as! [NSObject: AnyObject]
        let image = UIImage(named: imageName)!
        self.processRecognitionResponse(json, originalImage: image)
    }
    
    func showImagePicker() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        if UIImagePickerController.isSourceTypeAvailable(.PhotoLibrary) {
            imagePickerController.sourceType = .PhotoLibrary
        }
        else {
            imagePickerController.sourceType = .SavedPhotosAlbum
        }
        self.presentViewController(imagePickerController, animated: true, completion: nil)
    }
    
    func processImage(image: UIImage?) {
        if let image = image {
            SVProgressHUD.showWithStatus("Uploading and processing image...");
            // we are optimizing image for upload process to take less time
            let optimizedImage = UIImage.optimizeImage(image)
            dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
                KairosSDK.detectWithImage(optimizedImage, selector: "FULL", success: { (result: [NSObject : AnyObject]!) -> Void in
                    SVProgressHUD.dismiss()
                    NSLog("%@", result)
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.processRecognitionResponse(result, originalImage: image)
                    })
                    }, failure: { (result: [NSObject : AnyObject]!) -> Void in
                        SVProgressHUD.showErrorWithStatus(result.description)
                })
            })
        }
    }
    
    func processRecognitionResponse(result: [NSObject : AnyObject]!, originalImage: UIImage) {
        if let images = result["images"] as? [[String:AnyObject]], facesInfo = images.first!["faces"] as? [[String:AnyObject]] where facesInfo.count > 0 {
            var faces = [Face]()
            for faceInfo in facesInfo {
                let face = Face(dictionary: faceInfo)
                faces.append(face)
//                let message = String(format: "Found %@ face at (%f; %f) with size %f x %f", arguments: [face.gender.rawValue, face.originalX, face.originalY, face.width, face.height])
//                SVProgressHUD.showSuccessWithStatus(message)
            }
            self.processFaces(faces, originalImage: originalImage)
        }
        else {
            SVProgressHUD.showErrorWithStatus("No faces found, try different image!")
        }
    }
    
    func processFaces(faces: [Face], originalImage: UIImage) {
        if faces.count < 2 {
            SVProgressHUD.showErrorWithStatus("We haven't recognized enough faces to swap, please pick another photo")
        }
        else {
            self.performSegueWithIdentifier(showResultSegueIdentifier, sender: ["faces": faces, "originalImage": originalImage])
        }
    }
    
    //MARK: UIImagePickerControllerDelegate methods
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        self.dismissViewControllerAnimated(true, completion: nil)
        self.processImage(image)
    }
    
    //MARK: Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == showResultSegueIdentifier {
            if let controller = segue.destinationViewController as? ResultViewController, info = sender as? [String: AnyObject], faces = info["faces"] as? [Face], originalImage = info["originalImage"] as? UIImage {
                controller.faces = faces
                controller.originalImage = originalImage
            }
        }
    }

}

extension Array {
    mutating func shuffle() {
        for i in 0..<(count - 1) {
            let j = Int(arc4random_uniform(UInt32(count - i))) + i
            swap(&self[i], &self[j])
        }
    }
    func shuffled() -> [T] {
        var list = self
        for i in 0..<(list.count - 1) {
            let j = Int(arc4random_uniform(UInt32(list.count - i))) + i
            swap(&list[i], &list[j])
        }
        return list
    }
}

