//
//  ShoppingList.swift
//  AR in Retails
//
//  Created by Ashis Laha on 6/21/18.
//  Copyright © 2018 Ashis Laha. All rights reserved.
//

import Foundation

protocol ShoppingListProtocol: class {
    func didSelectProduct(indexPath: IndexPath)
}

class ShoppingList: UIView, UICollectionViewDelegate, UICollectionViewDataSource {
    
    private let nibName = "ShoppingList"
    var images: [UIImage] = []
    
    weak var delegate: ShoppingListProtocol?
    
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            collectionView.delegate = self
            collectionView.dataSource = self
            collectionView.register(ShoppingListCell.self, forCellWithReuseIdentifier: "cell")
            collectionView.backgroundColor = .clear
            collectionView.isUserInteractionEnabled = true
            collectionView.isScrollEnabled = true
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupNib()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupNib()
    }
    
    private func setupNib() {
        guard let view = loadViewFromNib() else { return }
        view.frame = bounds
        backgroundColor = .clear
        addSubview(view)
        collectionView.reloadData()
    }
    
    private func loadViewFromNib() -> UIView? {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: nibName, bundle: bundle)
        return nib.instantiate(withOwner: self, options: nil).first as? UIView
    }
    
    // collection view
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? ShoppingListCell else { return UICollectionViewCell() }
        cell.image = images[indexPath.item]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.didSelectProduct(indexPath: indexPath)
    }
}

extension ShoppingList : UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
       return CGSize(width: 100, height: 100)
    }
}
