//
//  ARViewController.swift
//  AR in Retails
//
//  Created by Ashis Laha on 4/7/18.
//  Copyright © 2018 Ashis Laha. All rights reserved.
//

import UIKit
import ARKit

class ARViewController: UIViewController, ARSCNViewDelegate {

    var productData: String?
    var model: ARModel?
   
    @IBOutlet weak var sceneView: ARSCNView!
    
    private let debugLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .red
        label.text = ""
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addRightBarButtonItems()
        sceneView.delegate = self
        navigationItem.title = productData
        
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate, let beaconManager = appDelegate.beaconManager {
            beaconManager.delegate = self
            addDebugLabel()
        }
        
        guard let scene = SCNScene(named: "./art.scnassets/model.scn") else { return }
        let sceneNode = scene.rootNode
        sceneNode.position = SCNVector3(x: 0, y: 0, z: -1)
        sceneNode.runAction(SCNAction.rotateBy(x: 0, y: CGFloat(Float.pi/2), z: 0, duration: 0.5))
        addNodesToScene()
        sceneView.scene.rootNode.addChildNode(sceneNode)
    }
    
    private func addDebugLabel() {
        sceneView.addSubview(debugLabel)
        debugLabel.centerXAnchor.constraint(equalTo: sceneView.safeAreaLayoutGuide.centerXAnchor).isActive = true
        debugLabel.bottomAnchor.constraint(equalTo: sceneView.safeAreaLayoutGuide.bottomAnchor, constant: -16).isActive = true
    }
    
    private func addRightBarButtonItems() {
        let dismiss = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(dismissAR))
        navigationItem.rightBarButtonItems = [dismiss]
    }
    
    @objc func dismissAR() {
       navigationController?.popViewController(animated: true)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let configuration = ARWorldTrackingConfiguration()
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
          super.viewWillDisappear(animated)
          sceneView.session.pause()
    }
    
    private func addNodesToScene() {
        let position1 = SCNVector3(0, 0, 0)
        let position2 = SCNVector3(0, 0, -20)
        
        let position3 = SCNVector3(0, 0, -20)
        let position4 = SCNVector3(-20, 0, -50)

        let node1 = SceneNodeCreator.getPathNode(position1: position1, position2: position2)
        let node2 = SceneNodeCreator.getPathNode(position1: position3, position2: position4)
        
        sceneView.scene.rootNode.addChildNode(node1)
        sceneView.scene.rootNode.addChildNode(node2)
        
        view.addSubview(sceneView)
    }
}

extension ARViewController: UserPositionUpdateProtocol {
    
    func getUserUpdate(position: EILOrientedPoint, accuracy: EILPositionAccuracy, location: EILLocation) {
        let userLocation = String(format: "x: %5.2f, y: %5.2f",position.x, position.y)
        debugLabel.text = userLocation
    }
}
