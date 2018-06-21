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

struct RoutePath {
    let source: CGPoint
    let destination: CGPoint
    let alongTrueNorth: Bool
    let routeColor: UIColor
}

class ARViewModel {
    
    private func getPaths() -> [RoutePath] {
        let paths: [RoutePath] = [
            RoutePath(source: CGPoint(x: 0.5, y: 0.5), destination: CGPoint(x: 9, y: 0.5), alongTrueNorth: true, routeColor: .yellow),
            RoutePath(source: CGPoint(x: 0.5, y: 2.5), destination: CGPoint(x: 9, y: 2.5), alongTrueNorth: true, routeColor: .yellow),
            RoutePath(source: CGPoint(x: 3, y: 0.5), destination: CGPoint(x: 3, y: 4.5), alongTrueNorth: false, routeColor: .green),
            RoutePath(source: CGPoint(x: 6, y: 0.5), destination: CGPoint(x: 6, y: 4.5), alongTrueNorth: false, routeColor: .green)
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
    
    func getPaths(userLocation: CGPoint, groundClearance: Float) -> [SCNNode] {
        var nodes: [SCNNode] = []
        for each in getPaths() {
            //TODO: update from Point and toPoint based on user position
            
            let fromPoint = SCNVector3Make(Float(each.source.x), groundClearance, Float(each.source.y))
            let toPosition = SCNVector3Make(Float(each.destination.x), groundClearance, Float(each.destination.y))
            let pathNode = SceneNodeCreator.getPathNode(position1: fromPoint, position2: toPosition)
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
