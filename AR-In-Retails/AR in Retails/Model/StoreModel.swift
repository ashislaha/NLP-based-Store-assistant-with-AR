//
//  StoreModel.swift
//  AR in Retails
//
//  Created by Ashis Laha on 6/15/18.
//  Copyright © 2018 Ashis Laha. All rights reserved.
//

import Foundation
import UIKit



class StoreModel {
    
    static let shared = StoreModel()
    
    var width: CGFloat = 0.0
    var height: CGFloat = 0.0
    var Xcenter: CGFloat = 0.0
    var Ycenter: CGFloat = 0.0

    let graph = Graph(arr: [0,1,2,3,4,5,6,7,8,9,10,11,12,13])
    var jsonArray: [[String: Any]] = []
    
    let storesBoundary: [String: [(Double,Double)]] = [
        "aura-block-b": [(12.938026, 77.690704), (12.937993, 77.691184), (12.936907, 77.691089), (12.936910, 77.690698)],
        "aura-block-a": [(12.936806, 77.690747), (12.936803, 77.691079), (12.936042, 77.691032), (12.936002, 77.690855)]
    ]
    
    
    let productToNodeInt: [ProductDepartment :[Int]] = [
        .fruits: [0,2],
        .fashion: [2, 7, 9],
        .mobiles: [6, 8, 13],
        .shoes: [1, 6],
        .groceries: [0, 1, 4],
        .laptops: [4, 7, 8, 11],
    ]
    
    let planStore: [ProductDepartment: CGPoint] = [
        .fruits: CGPoint(x: 2, y: 4),
        .groceries: CGPoint(x: 4.5, y: 4),
        .shoes: CGPoint(x: 7, y: 4),
        .fashion: CGPoint(x: 2, y: 1),
        .laptops: CGPoint(x: 4.5, y: 1),
        .mobiles: CGPoint(x: 7, y: 1)
    ]
    
    let images: [ProductDepartment: UIImage] = [
        .fruits: #imageLiteral(resourceName: "fruits"),
        .groceries: #imageLiteral(resourceName: "groceries"),
        .shoes: #imageLiteral(resourceName: "shoes"),
        .fashion: #imageLiteral(resourceName: "fashion"),
        .laptops: #imageLiteral(resourceName: "laptop"),
        .mobiles:#imageLiteral(resourceName: "mobiles")
    ]
    
    // mapped beacons
    let productsToBeacons: [ProductDepartment: String] = [
        .fruits: "purple1",
        .groceries: "yellow1",
        .shoes: "pink1",
        .fashion: "purple2",
        .laptops: "yellow2",
        .mobiles: "pink2"
    ]
    
    func findOutSource(userX : CGFloat, userY: CGFloat) -> Int {
        var i: Int = 0
        var minDis: CGFloat = 10000.0
        var minNode: Int = -1
        
        while i < 14 {
            let node = returnPoint(index: i)
            let point: CGPoint = CGPoint(x: (node.x/width)*9.5, y: (node.y/height)*5.0)
            let dis = CGPointDistanceSquared(from: point,to: CGPoint(x: userX, y: userY))
            if  dis - minDis < 0.0 {
                minDis = dis
                minNode = i
            }
            i = i+1
        }
        return minNode
    }
    
    private func CGPointDistanceSquared(from: CGPoint, to: CGPoint) -> CGFloat {
        return (from.x - to.x) * (from.x - to.x) + (from.y - to.y) * (from.y - to.y)
    }
    
    public func findoutRoutePoints(from: CGPoint, to: CGPoint, product: ProductDepartment) -> [CGPoint] {
        let source = findOutSource(userX: from.x, userY: from.y)
        let dest: [Int] = productToNodeInt[product]!
        let nodes:[Int] = graph.BFS(start: source, des: dest)
        var interNodes:[CGPoint] = []
        let pathPoints = calculatePathPoints(parents: nodes, des: dest, source:source )
        for item in pathPoints {
            interNodes.append(CGPoint(x: item.x*9.5/width, y: item.y*5.0/height))
        }
        return interNodes
    }
    
    private func calculatePathPoints(parents: [Int], des: [Int], source: Int)-> [CGPoint] {
        var ourDes:Int = -1
        for i in des {
            if parents[i] != -1 {
                ourDes = i
                break
            }
        }
        // back tracking
        var val = ourDes
        var points: [CGPoint] = []
        
        while val != source {
            let point = returnPoint(index: val)
            points.append(point)
            val = parents[val]
        }
        points.append(returnPoint(index: source)) 
        return points
    }
    
    
    func createDictionary(view: UIImageView) {
        height = view.frame.size.height
        width = view.frame.size.width
        Xcenter = view.frame.midX - view.frame.origin.x
        Ycenter = view.frame.midY - view.frame.origin.y - height/50.0
        
        print(Xcenter, Ycenter, height, width)
        
        jsonArray  = [
            [
                "coordinateX":  Xcenter - width*5.0/30.0,
                "coordinateY":  Ycenter - height*6.0/25.0
            ],
            [
                "coordinateX":  Xcenter + width*5.0/30.0,
                "coordinateY":  Ycenter - height*6.0/25.0
            ],
            [
                "coordinateX":  Xcenter - width*10.0/30.0,
                "coordinateY":  Ycenter
            ],
            [
                
                "coordinateX":  Xcenter - width*5.0/30.0,
                "coordinateY":  Ycenter
            ],
            [
                "coordinateX":  Xcenter ,
                "coordinateY":  Ycenter
            ],
            [
                "coordinateX":  Xcenter + width*5.0/30.0,
                "coordinateY":  Ycenter
            ],
            [
                "coordinateX":  Xcenter + width*10.0/30.0,
                "coordinateY":  Ycenter
            ],
            [
                "coordinateX":  Xcenter - width*5.0/30.0,
                "coordinateY":  Ycenter + height*6.0/25.0
            ],
            [
                "coordinateX":  Xcenter + width*5.0/30.0,
                "coordinateY":  Ycenter + height*6.0/25.0
            ],[
                "coordinateX":  Xcenter - width*10.0/30.0,
                "coordinateY":  Ycenter + height*12.0/25.0
            ],
              [
                "coordinateX":  Xcenter - width*5.0/30.0,
                "coordinateY":  Ycenter + height*12.0/25.0
            ],
              [
                "coordinateX":  Xcenter ,
                "coordinateY":  Ycenter + height*12.0/25.0
            ],
              [
                "coordinateX":  Xcenter + width*5.0/30.0,
                "coordinateY":  Ycenter + height*12.0/25.0
            ],
              [
                "coordinateX":  Xcenter + width*10.0/30.0,
                "coordinateY":  Ycenter + height*12.0/25.0
            ]
        ]
    }
    
    func makeGraph(){
        graph.addEdge(u: 0, v: 3)
        graph.addEdge(u: 1, v: 5)
        graph.addEdge(u: 2, v: 3)
        graph.addEdge(u: 3, v: 0)
        graph.addEdge(u: 3, v: 2)
        graph.addEdge(u: 3, v: 4)
        graph.addEdge(u: 3, v: 7)
        graph.addEdge(u: 4, v: 3)
        graph.addEdge(u: 4, v: 5)
        graph.addEdge(u: 5, v: 1)
        graph.addEdge(u: 5, v: 4)
        graph.addEdge(u: 5, v: 6)
        graph.addEdge(u: 5, v: 8)
        graph.addEdge(u: 6, v: 5)
        graph.addEdge(u: 7, v: 3)
        graph.addEdge(u: 7, v: 10)
        graph.addEdge(u: 8, v: 12)
        graph.addEdge(u: 8, v: 5)
        graph.addEdge(u: 9, v: 10)
        graph.addEdge(u: 10, v: 9)
        graph.addEdge(u: 10, v: 11)
        graph.addEdge(u: 10, v: 7)
        graph.addEdge(u: 11, v: 12)
        graph.addEdge(u: 11, v: 10)
        graph.addEdge(u: 12, v: 8)
        graph.addEdge(u: 12, v: 11)
        graph.addEdge(u: 12, v: 13)
        graph.addEdge(u: 13, v: 12)
    }
    
    func returnPoint(index: Int) -> CGPoint {
        
        guard index < jsonArray.count, let pointX = jsonArray[index]["coordinateX"] as? CGFloat, let pointY = jsonArray[index]["coordinateY"] as? CGFloat else { return CGPoint.zero }
        return CGPoint(x: pointX, y: pointY)
    }
}
