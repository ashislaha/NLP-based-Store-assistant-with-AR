//
//  ProceedView.swift
//  AR in Retails
//
//  Created by Ashis Laha on 6/17/18.
//  Copyright © 2018 Ashis Laha. All rights reserved.
//

import Foundation

protocol ProceedTappedProtocol: class {
    func proceedTapped()
}

class ProceedView: UIView {
    
    private let nibName = "ProceedView"
    
    @IBOutlet weak private var info: UILabel!
    @IBOutlet weak private var proceed: UIButton! {
        didSet {
            proceed.layer.cornerRadius = 10.0
        }
    }
    
    weak var delegate: ProceedTappedProtocol?
    
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
        addSubview(view)
    }
    
    private func loadViewFromNib() -> UIView? {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: nibName, bundle: bundle)
        return nib.instantiate(withOwner: self, options: nil).first as? UIView
    }
    

    
    @IBAction private func proceedTapped(_ sender: UIButton) {
        delegate?.proceedTapped()
    }
    
    public func updateText(_ text: String) {
        info.text = text
    }
}
