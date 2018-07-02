//
//  ShoppingListCell.swift
//  AR in Retails
//
//  Created by Ashis Laha on 6/21/18.
//  Copyright © 2018 Ashis Laha. All rights reserved.
//

import Foundation
import UIKit

class ShoppingListCell: UICollectionViewCell {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .purple
        addSubview(imageView)
        layoutSetup()
        backgroundColor = .clear
        layer.cornerRadius = 10
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var image : UIImage? {
        didSet {
            imageView.image = image
        }
    }
    
    private let imageView : UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private func layoutSetup() {
        imageView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        imageView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        imageView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        imageView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
    }
}

