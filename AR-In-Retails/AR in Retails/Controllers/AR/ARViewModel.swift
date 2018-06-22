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

struct RoutePath {
    let source: CGPoint
    let destination: CGPoint
    let alongTrueNorth: Bool
    let routeColor: UIColor
}

class ARViewModel {
    
    private func getPaths() -> [RoutePath] { // with respect to store map
        let paths: [RoutePath] = [
            RoutePath(source: CGPoint(x: 0, y: 9), destination: CGPoint(x: 9, y: 9), alongTrueNorth: true, routeColor: .yellow),
            RoutePath(source: CGPoint(x: 9, y: 9), destination: CGPoint(x: 9, y: 6), alongTrueNorth: true, routeColor: .red),
            RoutePath(source: CGPoint(x: 9, y: 6), destination: CGPoint(x: 0, y: 6), alongTrueNorth: false, routeColor: .green),
            RoutePath(source: CGPoint(x: 0, y: 6), destination: CGPoint(x: 0, y: 9), alongTrueNorth: false, routeColor: .blue)
        ]
        return paths
    }
    
    
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
    
    func getPosition(userPosition: CGPoint, productPosition: CGPoint, groundClearance: Float = 0) -> SCNVector3 {
        let userPositionX = Float(floor(userPosition.x))
        let userPositionY = Float(floor(userPosition.y))
        let productX = Float(productPosition.x)
        let productY = Float(productPosition.y)
        
        // let's translate the positions
        let newUserX = -userPositionY
        let newUserY = userPositionX
        let newProductX = -productY
        let newProductY = productX
        
        let position = SCNVector3Make(newProductX-newUserX, groundClearance, -(newProductY-newUserY))
        return position
    }
    
    func getPaths(userLocation: CGPoint, groundClearance: Float) -> [SCNNode] {
        var nodes: [SCNNode] = []
        
        for each in getPaths() {
            //TODO: assume user at (0,9)
            
            let source = getPosition(userPosition: userLocation, productPosition: each.source, groundClearance: groundClearance )
            let destination = getPosition(userPosition: userLocation, productPosition: each.destination, groundClearance: groundClearance)
            let pathNode = SceneNodeCreator.getPathNode(position1: source, position2: destination)
            nodes.append(pathNode)
        }
        return nodes
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
