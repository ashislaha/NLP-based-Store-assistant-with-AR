//
//  StoreIdentifyViewController.swift
//  AR in Retails
//
//  Created by Rishabh Mishra
//  Copyright © 2018 Ashis Laha. All rights reserved.
//

import UIKit
import AVFoundation
import Speech

class StoreViewController: UIViewController, EILIndoorLocationManagerDelegate, SFSpeechRecognizerDelegate {

    var demoView:DemoView?
    let locationManager = EILIndoorLocationManager()
    var storeModel = StoreModel()
    
    @IBOutlet weak var assistantButton: UIButton! {
        didSet {
            assistantButton.layer.cornerRadius = 10.0
        }
    }
    @IBOutlet weak var arButtonOutlet: UIButton! {
        didSet {
           arButtonOutlet.layer.cornerRadius = 10.0
        }
    }
    @IBOutlet weak var storePlan: UIImageView!
    
    @IBAction func assistantTapped(_ sender: UIButton) {
        initialiseChatViewController()
    }
    
    @IBAction func arButtonTapped(_ sender: UIButton) {
        openARView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
     
        locationManager.delegate = self
        title = "Store plan"
        storeModel.makeGraph()
        storeModel.createDictionary(view: view)
    }
    
    func displayPath(start: Int, des: [Int]) {
        
        let width: CGFloat = view.frame.size.width
        let height: CGFloat = view.frame.size.height/2
        
        var vertices:[Int] = storeModel.graph.BFS(start: start, des: des)
        var ourDes:Int = -1
        for i in des {
            if vertices[i] != -1{
                ourDes = i
                break
            }
        }
        
        if ourDes == -1 {
            let alert = UIAlertController(title: "", message: "You are already here", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        } else {
            var val:Int = ourDes
            var points: [CGPoint] = []
            var i: Int = 0
            while i < storeModel.graph.vertices{
                points.append(CGPoint(x: -1, y: -1))
                i = i + 1
            }
            
            i = 0
            while val != start{
                points[i] = storeModel.returnPoint(index: val)
                i = i+1
                val = vertices[val]
            }
            points[i] = storeModel.returnPoint(index: start)
            
            
            demoView?.removeFromSuperview()
            demoView = DemoView(frame: CGRect(x: 0.0 ,y: 0.0,width: width,height: height), points: points)
            self.view.addSubview(demoView!)
        }
    }
    
    private func openARView() {
        guard let arVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ARViewController") as? ARViewController else { return }
        navigationController?.pushViewController(arVC, animated: true)
    }
    
    private func initialiseChatViewController() {
        guard let chatVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ChatViewController") as? ChatViewController else { return }
        navigationController?.pushViewController(chatVC, animated: true)
        chatVC.isUserInsideStore = true 
    }
}


// MARK: Setting up new location
extension StoreViewController {
    
    func buildLocation() {
        let locationBuilder = EILLocationBuilder()
        let boundaryPoints: [EILPoint] = [EILPoint(x: 0, y: 0), EILPoint(x: 5, y: 0), EILPoint(x: 5, y: 5), EILPoint(x: 0, y: 5)]
        locationBuilder.setLocationBoundaryPoints(boundaryPoints)
        locationBuilder.setLocationOrientation(0)
        
        locationBuilder.addBeacon(withIdentifier: "test", atBoundarySegmentIndex: 0, inDistance: 2, from: .leftSide)
        
    }
}

