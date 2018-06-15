//
//  DemoView.swift
//  AR in Retails
//
//  Created by Rishabh Mishra on 05/06/18.
//  Copyright © 2018 Ashis Laha. All rights reserved.
//

import UIKit

class DemoView: UIView {
    
    var pointNodes:[CGPoint] = []
    
    init(frame: CGRect, points: [CGPoint]){
        super.init(frame: frame)
        pointNodes = points
        backgroundColor = UIColor(white: 1, alpha: 0)
    }
    
    override func draw(_ rect: CGRect) {
        let path = UIBezierPath()
        path.move(to: pointNodes[0])
        var i:Int = 0
        for point in pointNodes where point.x != -1 {
            if i != 0 {
                path.addLine(to: point)
            }
            i = i+1
        }
        path.lineWidth = 3.0
        UIColor.purple.setStroke()
        path.stroke()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }


}
