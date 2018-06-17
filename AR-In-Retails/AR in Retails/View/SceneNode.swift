//
//  SceneNode.swift
//  AR in Retails
//
//  Created by Ashis Laha on 5/31/18.
//  Copyright © 2018 Ashis Laha. All rights reserved.
//

import UIKit
import SceneKit

class SceneNodeCreator {
    
    static let pathColor = UIColor(red: 20.0/255.0, green: 126.0/255.0, blue: 193.0/255.0, alpha: 1.0)
    
    class func getPathNode(position1 : SCNVector3, position2 : SCNVector3 ) -> SCNNode {
        
        // calculate Angle
        let dx = position2.x - position1.x
        let dz = (-1.0) * (position2.z - position1.z)
        var theta = atan(Double(dz/dx))
        if theta == .nan {
            theta = 3.14159265358979 / 2 // 90 Degree
        }
        print("Angle between point1 and point2 is : \(theta * 180 / Double.pi) along Y-Axis")
        
        //Create Node
        let width = CGFloat(sqrt( dx*dx + dz*dz ))
        let height : CGFloat = 0.1
        let length : CGFloat = 0.8
        let chamferRadius : CGFloat = 0.05
        let route = SCNBox(width: width, height: height, length: length, chamferRadius: chamferRadius)
        route.firstMaterial?.diffuse.contents = SceneNodeCreator.pathColor
        let midPosition = SCNVector3Make((position1.x+position2.x)/2, -1, (position1.z+position2.z)/2)
        let node = SCNNode(geometry: route)
        node.position = midPosition
        
        node.rotation = SCNVector4Make(0, 1, 0, Float(theta))
        return node
    }
    
    class func getImageNode(image: UIImage, name: String) -> SCNNode {
        let plane = SCNPlane(width: 0.5, height: 0.5)
        plane.firstMaterial?.diffuse.contents = image
        plane.firstMaterial?.lightingModel = .constant
        
        let node = SCNNode()
        node.geometry = plane
        node.name = name
        
        let billboardConstraint = SCNBillboardConstraint()
        billboardConstraint.freeAxes = SCNBillboardAxis.Y
        node.constraints = [billboardConstraint]
        
        return node
    }
}
