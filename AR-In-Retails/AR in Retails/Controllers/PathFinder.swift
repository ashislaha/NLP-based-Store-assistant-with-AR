//
//  PathFinder.swift
//  AR in Retails
//
//  Created by Rishabh Mishra on 05/06/18.
//  Copyright © 2018 Ashis Laha. All rights reserved.
//

import UIKit

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
    public func BFS(start : Int) {
        guard start < vertices else { return }
        
        // added to the Queue
        var Q = [Node]()
        Q.append(Node(val: start))
        visited[start] = true
        
        while !Q.isEmpty {
            
            if let popData = Q.removeFirst().data {
                print("data : \(popData)")
                
                // traverse the adj list of pop elements
                var nextElement = adj[popData].next
                while let next = nextElement , let nextData = next.data {
                    
                    if !visited[nextData] {
                        visited[nextData] = true
                        Q.append(next)
                    }
                    nextElement = next.next
                }
            }
        }
    }
}

let graph = Graph(arr: [0,1,2,3,4,5])
graph.addEdge(u: 0, v: 1)
graph.addEdge(u: 0, v: 2)
graph.addEdge(u: 1, v: 0)
graph.addEdge(u: 2, v: 0)
graph.addEdge(u: 1, v: 3)
graph.addEdge(u: 2, v: 3)
graph.addEdge(u: 3, v: 4)
graph.addEdge(u: 3, v: 5)
graph.addEdge(u: 4, v: 3)
graph.addEdge(u: 5, v: 3)

graph.BFS(start: 0)
