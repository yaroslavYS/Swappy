//
//  Face.swift
//  Swappy
//
//  Created by Yaroslav Skorokhid on 6/27/15.
//  Copyright (c) 2015 Starry Night. All rights reserved.
//

import UIKit

enum Gender: String {
    case Male = "Male"
    case Female = "Female"
    case Unknown = "Unknown"
}

class Face {
    private(set) var originalX: CGFloat = 0
    private(set) var originalY: CGFloat = 0
    private(set) var width: CGFloat = 0
    private(set) var height: CGFloat = 0
    
    var rect: CGRect {
        return CGRect(x: originalX, y: originalY, width: width, height: height)
    }
    
    private(set) var gender: Gender = .Unknown
    
    init(dictionary: [String: AnyObject]) {
        var face = dictionary
        let x = face["topLeftX"] as! Float
        let y = face["topLeftY"] as! Float
        let width = face["width"] as! Float
        let height = face["height"] as! Float
        var gender: Gender = .Unknown
        if let attributes = face["attributes"] as? [String:AnyObject], faceGender = attributes["gender"] as? [String:AnyObject], genderType = faceGender["type"] as? String {
            gender = genderType == "M" ? .Male : .Female
        }
        
        self.originalX = CGFloat(x)
        self.originalY = CGFloat(y)
        self.width = CGFloat(width)
        self.height = CGFloat(height)
        self.gender = gender
    }
}
