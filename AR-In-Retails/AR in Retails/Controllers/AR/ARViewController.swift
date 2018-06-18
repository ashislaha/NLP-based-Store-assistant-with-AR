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
    let storeModel = StoreModel()
   
    private var sceneView: ARView = {
        let view = ARView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let debugLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .red
        label.text = ""
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addSceneView()
        sceneView.delegate = self
        
        navigationItem.title = productData
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate, let beaconManager = appDelegate.beaconManager {
            beaconManager.delegate = self
            addDebugLabel()
        }
    }
    
    private func addSceneView() {
        view.addSubview(sceneView)
        NSLayoutConstraint.activate([
            sceneView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            sceneView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            sceneView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            sceneView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
            ])
    }
    
    private func addDebugLabel() {
        sceneView.addSubview(debugLabel)
        debugLabel.centerXAnchor.constraint(equalTo: sceneView.safeAreaLayoutGuide.centerXAnchor).isActive = true
        debugLabel.bottomAnchor.constraint(equalTo: sceneView.safeAreaLayoutGuide.bottomAnchor, constant: -16).isActive = true
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        sceneView.run()
        addNodesToScene()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
          super.viewWillDisappear(animated)
          sceneView.pause()
    }
    
    private func addNodesToScene() {
        for each in storeModel.planStore {
            if let image = storeModel.images[each.key] {
                let imageNode = SceneNodeCreator.getImageNode(image: image, name: each.key.rawValue)
                sceneView.scene.rootNode.addChildNode(imageNode)
            }
        }
        view.addSubview(sceneView)
    }
    
    private func updateNodesPosition(userPosition: EILOrientedPoint) {
        for eachNode in sceneView.scene.rootNode.childNodes {
            if let nodeName = eachNode.name, let product = ProductDepartment(rawValue: nodeName), let productPosition = storeModel.planStore[product] {
                let userPositionX = Float(floor(userPosition.x))
                let userPositionY = Float(floor(userPosition.y))
                let productX = Float(productPosition.x)
                let productY = Float(productPosition.y)
                
                // let's translate the positions
                let newUserX = -userPositionY
                let newUserY = userPositionX
                let newProductX = -productY
                let newProductY = productX
                
                let position = SCNVector3Make(newProductX-newUserX, 0, -(newProductY-newUserY))
                eachNode.position = position
            }
        }
    }
}

extension ARViewController: UserPositionUpdateProtocol {
    
    func getUserUpdate(position: EILOrientedPoint, accuracy: EILPositionAccuracy, location: EILLocation) {
        let userLocation = String(format: "x: %5.2f, y: %5.2f",position.x, position.y)
        debugLabel.text = userLocation
        updateNodesPosition(userPosition: position)
    }
}
