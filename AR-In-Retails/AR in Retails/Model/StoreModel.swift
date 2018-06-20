//
//  StoreModel.swift
//  AR in Retails
//
//  Created by Ashis Laha on 6/15/18.
//  Copyright © 2018 Ashis Laha. All rights reserved.
//

import Foundation
import UIKit



struct StoreModel {
    
    var Xcenter: CGFloat = 0.0
    var Ycenter: CGFloat = 0.0
    var height: CGFloat = 0.0
    var width: CGFloat = 0.0
    let graph = Graph(arr: [0,1,2,3,4,5,6,7,8,9,10,11,12,13])
    var jsonArray: [[String: Any]] = []
    
    let storesBoundary: [String: [(Double,Double)]] = [
        "aura-block-b": [(12.938026, 77.690704), (12.937993, 77.691184), (12.936907, 77.691089), (12.936910, 77.690698)],
        "aura-block-a": [(12.936807, 77.690841), (12.936803, 77.691079), (12.936042, 77.691032), (12.936002, 77.690855)]
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
        .shoes: CGPoint(x: 7, y: 5),
        .fashion: CGPoint(x: 2, y: 1),
        .laptops: CGPoint(x: 4.5, y: 1),
        .mobiles: CGPoint(x: 7, y: 1)
    ]
    
    let images: [ProductDepartment: UIImage] = [
        .fruits: #imageLiteral(resourceName: "fruits"),
        .groceries: #imageLiteral(resourceName: "groceries"),
        .shoes: #imageLiteral(resourceName: "shoes2"),
        .fashion: #imageLiteral(resourceName: "dress"),
        .laptops: #imageLiteral(resourceName: "Laptop-Free-Download-PNG"),
        .mobiles: #imageLiteral(resourceName: "mobiles")
    ]
    
    public func findoutRoutePoints(from: CGPoint, to: CGPoint, product: ProductDepartment) -> [CGPoint] {
        
        
        weak var delegate: ChatDelegate?
        let source = delegate?.findOutSource(userX: from.x, userY: from.y)
        let dest: [Int]  = productToNodeInt[product]!
        let nodes:[Int] = graph.BFS(start: source!, des: dest)
        var interNodes:[CGPoint] = []
        for item in nodes {
            let mapPoint : CGPoint = returnPoint(index: item)
            interNodes.append(CGPoint(x: mapPoint.x*9.5/width, y: mapPoint.y*5.0/height))
        }
        return interNodes
    }
    
    
    mutating func createDictionary(view: UIImageView) {
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
