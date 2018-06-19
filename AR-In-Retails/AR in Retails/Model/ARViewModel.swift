//
//  ARViewModel.swift
//  AR in Retails
//
//  Created by Ashis Laha on 5/31/18.
//  Copyright © 2018 Ashis Laha. All rights reserved.
//

import Foundation
import SceneKit
import ARKit


enum ProductDepartment: String {
    case fruits
    case groceries
    case shoes
    case fashion 
    case laptops
    case mobiles
}


class ARViewModel {
    
    // get all arrow nodes
    func getArrowNodes(from: CGPoint, with points: [CGPoint]) -> [ArrowNode] {
        guard !points.isEmpty else { return [] }
        
        var nodes: [ArrowNode] = []
        var previous = from
        for current in points {
            if let arrow = getArrowNode(current: current, previousLocation: previous) {
                arrow.position = getPosition(userPosition: previous, productPosition: current)
                nodes.append(arrow)
            }
            previous = current
        }
        return nodes
    }
    
    private func getArrowNode(current: CGPoint, previousLocation: CGPoint) -> ArrowNode? {
        var node : ArrowNode!
        let theta = SceneNodeCreator.getAngle(location1: previousLocation, location2: current)
        let backward = theta <= Double.pi/2 || theta <= -Double.pi/2 ? false : true
        
        node = ArrowNode(backward: backward)
        SceneNodeCreator.rotateNode(node: node, theta: theta)
        return node
    }
    
    func getPosition(userPosition: CGPoint, productPosition: CGPoint) -> SCNVector3 {
        let userPositionX = Float(floor(userPosition.x))
        let userPositionY = Float(floor(userPosition.y))
        let productX = Float(productPosition.x)
        let productY = Float(productPosition.y)
        
        // let's translate the positions
        let newUserX = -userPositionY
        let newUserY = userPositionX
        let newProductX = -productY
        let newProductY = productX
        
        let position = SCNVector3Make(newProductX-newUserX, 0, -(newProductY-newUserY))
        return position
    }
}

class ArrowNode: SCNNode {
    let sceneName = "art.scnassets/arrow.scn"
    
    public init(backward : Bool = false) {
        super.init()
        
        let annotationNode = SceneNodeCreator.getArrow3D(sceneName: sceneName, downArrow : false)
        annotationNode.scale = SCNVector3Make(0.5, 0.5, 0.5)
        addChildNode(annotationNode)
        SceneNodeCreator.addTexture(node: annotationNode, backward : backward)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
