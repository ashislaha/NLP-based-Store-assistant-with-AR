//
//  HomeViewController.swift
//  AR in Retails
//
//  Created by Ashis Laha on 6/14/18.
//  Copyright © 2018 Ashis Laha. All rights reserved.
//

import Foundation

class HomeViewController: UIViewController {
    
    @IBOutlet weak private var yesButton: UIButton! {
        didSet {
            yesButton.layer.cornerRadius = 10.0
        }
    }
    @IBOutlet weak private var noButton: UIButton! {
        didSet {
            noButton.layer.cornerRadius = 10.0
        }
    }
    
    @IBAction private func yesTapped(_ sender: UIButton) {
        initialiseStoreMapViewController()
    }
    
    @IBAction private func noTapped(_ sender: UIButton) {
        initialiseChatViewController()
    }
    
    private func initialiseStoreMapViewController() {
        guard let storeMapVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "StoreViewController") as? StoreViewController else { return }
        navigationController?.pushViewController(storeMapVC, animated: true)
    }
    
    private func initialiseChatViewController() {
        guard let chatVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ChatViewController") as? ChatViewController else { return }
        navigationController?.pushViewController(chatVC, animated: true)
        chatVC.isUserInsideStore = false 
    }
}
