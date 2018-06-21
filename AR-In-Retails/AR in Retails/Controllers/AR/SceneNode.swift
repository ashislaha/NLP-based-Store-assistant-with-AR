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
    
    static let pathColor = UIColor(red: 20.0/255.0, green: 126.0/255.0, blue: 193.0/255.0, alpha: 0.75)
    static let sceneName = "art.scnassets/arrow.scn"
    
    class func getPathNode(position1 : SCNVector3, position2 : SCNVector3, color: UIColor = SceneNodeCreator.pathColor ) -> SCNNode {
        
        // calculate Angle
        let dx = position2.x - position1.x
        let dz = (-1.0) * (position2.z - position1.z)
        var theta = atan(Double(dz/dx))
        if theta == .nan {
            theta = 3.14159265358979 / 2 // 90 Degree
        }
        print("Angle between point1 and point2 is : \(theta * 180 / Double.pi) along Y-Axis")
        
        //Create Node
        let width: CGFloat = CGFloat(sqrt( dx*dx + dz*dz ))
        let height : CGFloat = 0.05
        let length : CGFloat = 0.5
        let chamferRadius : CGFloat = 0.03
        let route = SCNBox(width: width, height: height, length: length, chamferRadius: chamferRadius)
        route.firstMaterial?.diffuse.contents = color
        let midPosition = SCNVector3Make((position1.x+position2.x)/2, position1.y, (position1.z+position2.z)/2)
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
    
    class func getArrow3D(sceneName : String, downArrow : Bool = false) -> SCNNode {
        guard let scene = SCNScene(named:sceneName) else { return SCNNode() }
        if scene.rootNode.childNodes.count == 2 {
            scene.rootNode.childNodes[0].geometry?.firstMaterial?.diffuse.contents = UIColor.getFrontSideArrowColor()
            scene.rootNode.childNodes[1].geometry?.firstMaterial?.diffuse.contents = UIColor.getBackSideArrrowColor()
        } else {
            for each in scene.rootNode.childNodes {
                each.geometry?.firstMaterial?.diffuse.contents = UIColor.getFrontSideArrowColor()
            }
        }
        scene.rootNode.scale = SCNVector3Make(2, 2, 2)
        if downArrow {
            scene.rootNode.rotation = SCNVector4Make(0, 0, 1, -Float(Double.pi/2))
        }
        return scene.rootNode
    }
    
    class func addTexture(node : SCNNode, backward : Bool = false) {
        let toPow: Double = 3
        let timeDuration: Double = 15 / pow(2, toPow)
        let textureAction = SCNAction.customAction(duration: timeDuration) { (node, d) in
            let num = Int(Double(d) * pow(2, toPow)) + 1
            let imageName = backward ? "b\(num)" : "f\(num)"
            //print(imgName)
            if let image = UIImage(named: imageName) {
                let material1 = SCNMaterial()
                material1.diffuse.contents = image
                
                let material2 = SCNMaterial()
                material2.diffuse.contents = UIColor.getFrontSideArrowColor()
                
                node.childNodes[0].geometry?.firstMaterial = material1
                node.childNodes[1].geometry?.firstMaterial = material2
            }
        }
        let repeatAction = SCNAction.repeatForever(textureAction)
        node.runAction(repeatAction)
    }
    
    class func getAngle(location1 : CGPoint, location2 : CGPoint) -> Double {
        let dx = location2.x - location1.x
        let dy = location2.y - location1.y
        var theta = 0.0
        
        theta += atan(Double(dy/dx))
        print("tan-inverse theta: \(theta * 180 / Double.pi)")
        
        if dx < 0 && dy > 0 || dx < 0 && dy < 0 { // 2nd, 3rd coordinates, no need to add anything for 1st coordinate and 4th coordinates
            theta += Double.pi
        } else if theta == .nan && dy >= 0 { // dx = 0
            theta = Double.pi/2 // 90 Degree
        } else if theta == .nan && dy < 0 { // dx = 0
            theta = -Double.pi/2 // -90 Degree
        } else if theta == 0.0 && dx < 0 { // dy = 0
            theta = Double.pi // 180 degree
        } // else if theta == 0.0 && dx>= 0 { theta = 0.0 }
        
        print("dx = \(dx) and dy =\(dy) Angle: \(theta * 180 / Double.pi) ")
        return theta
    }
    
    class func rotateNode(node : SCNNode, theta : Double, with animation : Bool = false) {
        if animation {
            let rotation = CABasicAnimation(keyPath: "rotation")
            rotation.fromValue = SCNVector4Make(0, 1, 0, 0)
            rotation.toValue = SCNVector4Make(0, 1, 0,  Float(theta))
            rotation.duration = 2.0
            node.addAnimation(rotation, forKey: "Rotate it")
        }
        node.rotation = SCNVector4Make(0, 1, 0, Float(theta))
    }
}

extension UIColor {
    class func getFrontSideArrowColor() -> UIColor {
        return self.init(red: 237.0/255.0, green: 252.0/255.0, blue: 41.0/255.0, alpha: 1.0)
    }
    class func getBackSideArrrowColor() -> UIColor {
        return self.init(red: 212.0/255.0, green: 219.0/255.0, blue: 40.0/255.0, alpha: 1.0)
    }
    class func getCustomColor() -> UIColor {
        return self.init(red: 239.0/255.0, green: 253.0/255.0, blue: 65.0/255.0, alpha: 0.8)
    }
}
