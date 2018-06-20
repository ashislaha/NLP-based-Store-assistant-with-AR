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

class StoreViewController: UIViewController, SFSpeechRecognizerDelegate {

    var demoView:DemoView?
    var storeModel = StoreModel()
    var userPosition: EILOrientedPoint?
    
    let userPositionImage: UIImageView = {
        let imageView = UIImageView(image: #imageLiteral(resourceName: "blue_dot"))
        imageView.frame = .zero
        return imageView
    }()
    
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
    
    @IBOutlet weak var debugLabel: UILabel! {
        didSet {
            debugLabel.text = ""
            debugLabel.textColor = .red
        }
    }
    
    @IBAction func arButtonTapped(_ sender: UIButton) {
        openARView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Store plan"
        storeModel.makeGraph()
        storeModel.createDictionary(view: storePlan)
        storePlan.addSubview(userPositionImage)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate, let beaconManager = appDelegate.beaconManager {
            beaconManager.delegate = self
        }
    }
    
    func displayPath(start: Int, des: [Int]) {
        
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
            demoView = DemoView(frame: CGRect(x: storePlan.frame.origin.x ,y: storePlan.frame.origin.y,width: storePlan.frame.size.width ,height: storePlan.frame.size.height), points: points)
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
        chatVC.delegate = self
        chatVC.isUserInsideStore = true 
    }
}

// chat view delegate
extension StoreViewController: ChatDelegate {
    
    func navigate(to: ProductDepartment) {
        
       // guard let userX = userPosition?.x, let userY = userPosition?.y else {return}
        let userX = 9
        let userY = 5
        let source = findOutSource(userX: CGFloat(userX), userY: CGFloat(userY))
        if let dest = StoreModel().productToNodeInt[to] {
             displayPath(start: source, des: dest)
        }
    }
    
    private func CGPointDistanceSquared(from: CGPoint, to: CGPoint) -> CGFloat {
        return (from.x - to.x) * (from.x - to.x) + (from.y - to.y) * (from.y - to.y)
    }

    func findOutSource(userX : CGFloat, userY: CGFloat) -> Int {
        // userPosition give you the current user location
        // find out the nearest source node of that position to apply BFS
//        guard let userX = userPosition?.x, let userY = userPosition?.y else {return -1}

        var i: Int = 0
        var minDis: CGFloat = 10000.0
        var minNode: Int = -1

        while i < 14 {
            let node = storeModel.returnPoint(index: i)
            let point: CGPoint = CGPoint(x: (node.x/storeModel.width)*9.5, y: (node.y/storeModel.height)*5.0)
            let dis = CGPointDistanceSquared(from: point,to: CGPoint(x: userX, y: userY))
            if  dis - minDis < 0.0 {
                minDis = dis
                minNode = i
            }
            i = i+1
        }
        return minNode
    }
}

extension StoreViewController: UserPositionUpdateProtocol {
    
    func getUserUpdate(position: EILOrientedPoint, accuracy: EILPositionAccuracy, location: EILLocation) {
        let userLocation = String(format: "x: %5.2f, y: %5.2f",position.x, position.y)
        debugLabel.text = userLocation
        userPosition = position
        updateUserImage(position: position)
    }
    
    private func updateUserImage(position: EILOrientedPoint) {
        let userX = CGFloat(position.x)
        let userY = CGFloat(position.y)
        let storePlanWidth = storePlan.frame.width
        let storePlanHeight = storePlan.frame.height
        
        let userPositionX = userX * (storePlanWidth/BeaconConstants.storeWidth)
        let userPositionY = storePlanHeight - (userY * (storePlanHeight/BeaconConstants.storeHeight))
        
        let newFrame = CGRect(x: userPositionX, y: userPositionY, width: 10, height: 10)
        userPositionImage.frame = newFrame
    }
}

