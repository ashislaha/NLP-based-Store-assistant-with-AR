//
//  BFS.swift
//  AR in Retails
//
//  Created by Rishabh Mishra on 06/06/18.
//  Copyright © 2018 Ashis Laha. All rights reserved.
//

import Foundation

class Node {
    var data : Int?
    var next : Node?
    
    init(val : Int) {
        data = val
        next = nil
    }
}

class Graph {
    
    var vertices : Int = 0
    var adj : [Node] = []
    var visited : [Bool] = []
    
    // init
    init(arr : [Int]) {
        vertices = arr.count
        for each in arr {
            adj.append(Node(val: each))
            visited.append(false)
        }
    }
    
    // add to list
    public func add(node : Node?, item : Int) {
        guard let node = node else { return }
        
        let newNode = Node(val: item)
        newNode.next = node.next
        node.next = newNode
    }
    
    // add Edge
    public func addEdge(u : Int, v : Int) {
        guard u < vertices && v < vertices else { return }
        add(node: adj[u], item: v)
    }
    
    // BFS
    public func BFS(start : Int, des : [Int]) -> [Int] {
        
        
        guard start < vertices else { return []}
        var parent:[Int] = []
        var j:Int = 0
        while j<vertices {
            visited[j] = false
            parent.append(-1)
            j = j+1
        }
        
        // added to the Queue
        var Q = [Node]()
        Q.append(Node(val: start))
        visited[start] = true
        while !Q.isEmpty {
            
            if let popData = Q.removeFirst().data {
                //                print("data : \(popData)")
                if( self.isPresent(popData: popData, des: des)){
                    break
                }
                
                // traverse the adj list of pop elements
                var nextElement = adj[popData].next
                while let next = nextElement , let nextData = next.data {
                    
                    if !visited[nextData] {
                        visited[nextData] = true
                        Q.append(next)
                        parent[nextData] = popData
                    }
                    nextElement = next.next
                }
            }
        }
        
        
        return parent
    }
    
    func isPresent( popData: Int, des: [Int]) -> Bool {
        for data in des{
            if popData == data{
                return true
            }
        }
        return false
    }
}
