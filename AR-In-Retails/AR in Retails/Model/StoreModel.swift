//
//  StoreModel.swift
//  AR in Retails
//
//  Created by Ashis Laha on 6/15/18.
//  Copyright © 2018 Ashis Laha. All rights reserved.
//

import Foundation

struct StoreModel {
    
    var Xcenter: CGFloat = 0.0
    var Ycenter: CGFloat = 0.0
    let graph = Graph(arr: [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23])
    var jsonArray: [[String: Any]] = []
    var productToNodeInt: [String:[Int]] = [
        "fruits": [0,21],
        "fruit": [0,21],
        "sports": [1,21,22],
        "sport": [1,21,22],
        "dairy": [2,23,22],
        "books": [3,23],
        "book": [3,23],
        "fashion": [4,20,0],
        "mobiles": [5,20,1,12],
        "mobile": [5,20,1,12],
        "smartphone": [5,20,1,12],
        "toys": [6,12,2,13],
        "toy": [6,12,2,13],
        "shoes": [7,13,3],
        "bags": [8,4],
        "bag": [8,4],
        "grocery": [9,5,8],
        "laptops": [10,6,11],
        "laptop": [10,6,11],
        "computer": [10,6,11],
        "utensils": [11,7],
        "utensil": [11,7],
        "cookware": [11,7]
    ]
    
    mutating func createDictionary(view: UIImageView) {
        Xcenter = view.frame.midX - view.frame.origin.x
        Ycenter = view.frame.midY - view.frame.origin.y
        
        
        print(Xcenter, Ycenter)
        
        let height = view.frame.size.height
        let width = view.frame.size.width
        
        print(Xcenter, Ycenter, height, width)
        
        
        jsonArray  = [
            [
                "storeId": 1,
                "productName": "A",
                "coordinateX":  Xcenter - width*3.0/8.0,
                "coordinateY":  Ycenter - height/6.0
            ],
            [
                "storeId": 2,
                "productName": "B",
                "coordinateX":  Xcenter - width*1.0/8.0,
                "coordinateY":  Ycenter - height/6.0
            ],
            [
                "storeId": 3,
                "productName": "C",
                "coordinateX":  Xcenter + width*1.0/8.0,
                "coordinateY":  Ycenter - height/6.0
            ],
            [
                "storeId": 4,
                "productName": "D",
                "coordinateX":  Xcenter + width*3.0/8.0,
                "coordinateY":  Ycenter - height/6.0
            ],
            [
                "storeId": 5,
                "productName": "E",
                "coordinateX":  Xcenter - width*3.0/8.0,
                "coordinateY":  Ycenter + height/6.0
            ],
            [
                "storeId": 6,
                "productName": "F",
                "coordinateX":  Xcenter - width*1.0/8.0,
                "coordinateY":  Ycenter + height/6.0
            ],
            [
                "storeId": 7,
                "productName": "G",
                "coordinateX":  Xcenter + width*1.0/8.0,
                "coordinateY":  Ycenter + height/6.0
            ],
            [
                "storeId": 8,
                "productName": "H",
                "coordinateX":  Xcenter + width*3.0/8.0,
                "coordinateY":  Ycenter + height/6.0
            ],
            [
                "storeId": 9,
                "productName": "I",
                "coordinateX":  Xcenter - width*1.0/4.0,
                "coordinateY":  Ycenter + height/3.0
            ],[
                "storeId": 10,
                "productName": "J",
                "coordinateX":  Xcenter,
                "coordinateY":  Ycenter + height/3.0
            ],
              [
                "storeId": 11,
                "productName": "K",
                "coordinateX":  Xcenter,
                "coordinateY":  Ycenter + height/3.0
            ],
              [
                "storeId": 12,
                "productName": "L",
                "coordinateX":  Xcenter + width/4.0,
                "coordinateY":  Ycenter + height/3.0
            ],
              [
                "coordinateX":  Xcenter,
                "coordinateY":  Ycenter
            ],
              [
                "coordinateX":  Xcenter + width/4.0,
                "coordinateY":  Ycenter
            ],
              [
                "coordinateX":  Xcenter - width/4.0,
                "coordinateY":  Ycenter - height/6.0
            ],[
                "coordinateX":  Xcenter,
                "coordinateY":  Ycenter - height/6.0
            ],
              [
                "coordinateX":  Xcenter + width/4.0,
                "coordinateY":  Ycenter - height/6.0
            ],
              
              [
                "coordinateX":  Xcenter - width/4.0,
                "coordinateY":  Ycenter + height/6.0
            ],
              [
                "coordinateX":  Xcenter,
                "coordinateY":  Ycenter + height/6.0
            ],
              [
                "coordinateX":  Xcenter + width/4.0,
                "coordinateY":  Ycenter + height/6.0
            ],
              [
                "coordinateX":  Xcenter - width/4.0,
                "coordinateY":  Ycenter
            ],
              [
                "coordinateX":  Xcenter - width/4.0,
                "coordinateY":  Ycenter - height/3.0
            ],
              [
                "coordinateX":  Xcenter ,
                "coordinateY":  Ycenter - height/3.0
            ],
              [
                "coordinateX":  Xcenter + width/4.0,
                "coordinateY":  Ycenter - height/3.0
            ]
        ]
    }
    
    func makeGraph(){
        graph.addEdge(u: 0, v: 14)
        graph.addEdge(u: 1, v: 14)
        graph.addEdge(u: 1, v: 15)
        graph.addEdge(u: 2, v: 15)
        graph.addEdge(u: 2, v: 16)
        graph.addEdge(u: 3, v: 16)
        graph.addEdge(u: 4, v: 17)
        graph.addEdge(u: 5, v: 17)
        graph.addEdge(u: 5, v: 18)
        graph.addEdge(u: 6, v: 18)
        graph.addEdge(u: 6, v: 19)
        graph.addEdge(u: 7, v: 19)
        graph.addEdge(u: 8, v: 17)
        graph.addEdge(u: 9, v: 10)
        graph.addEdge(u: 9, v: 18)
        graph.addEdge(u: 10, v: 18)
        graph.addEdge(u: 10, v: 9)
        graph.addEdge(u: 11, v: 19)
        graph.addEdge(u: 12, v: 15)
        graph.addEdge(u: 12, v: 18)
        graph.addEdge(u: 13, v: 16)
        graph.addEdge(u: 13, v: 19)
        graph.addEdge(u: 14, v: 0)
        graph.addEdge(u: 14, v: 20)
        graph.addEdge(u: 14, v: 1)
        graph.addEdge(u: 14, v: 21)
        
        graph.addEdge(u: 15, v: 1)
        graph.addEdge(u: 15, v: 12)
        graph.addEdge(u: 15, v: 2)
        graph.addEdge(u: 15, v: 22)
        
        graph.addEdge(u: 16, v: 2)
        graph.addEdge(u: 16, v: 3)
        graph.addEdge(u: 16, v: 13)
        graph.addEdge(u: 16, v: 23)
        
        graph.addEdge(u: 17, v: 4)
        graph.addEdge(u: 17, v: 5)
        graph.addEdge(u: 17, v: 8)
        graph.addEdge(u: 17, v: 20)
        graph.addEdge(u: 18, v: 5)
        graph.addEdge(u: 18, v: 6)
        graph.addEdge(u: 18, v: 9)
        graph.addEdge(u: 18, v: 10)
        graph.addEdge(u: 18, v: 12)
        graph.addEdge(u: 19, v: 6)
        graph.addEdge(u: 19, v: 7)
        graph.addEdge(u: 19, v: 11)
        graph.addEdge(u: 19, v: 13)
        graph.addEdge(u: 20, v: 17)
        graph.addEdge(u: 20, v: 14)
        
        graph.addEdge(u: 21, v: 14)
        graph.addEdge(u: 22, v: 15)
        graph.addEdge(u: 23, v: 16)
    }
    
    func returnPoint(index: Int) -> CGPoint {
        guard index < jsonArray.count, let pointX = jsonArray[index]["coordinateX"] as? CGFloat, let pointY = jsonArray[index]["coordinateY"] as? CGFloat else { return CGPoint.zero }
        return CGPoint(x: pointX, y: pointY)
    }
}
