//
//  ARViewController.swift
//  AR in Retails
//
//  Created by Ashis Laha on 4/7/18.
//  Copyright © 2018 Ashis Laha. All rights reserved.
//

import UIKit
import ARKit

class ARViewController: UIViewController, ARSCNViewDelegate, ARViewDelegate {

    var productData: String?
    let storeModel = StoreModel.shared
    let viewModel = ARViewModel()
    
    var navigateToProduct: ProductDepartment?
    private var userPosition: EILOrientedPoint?
   
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
        sceneView.viewDelegate = self
        debugLabel.centerXAnchor.constraint(equalTo: sceneView.safeAreaLayoutGuide.centerXAnchor).isActive = true
        debugLabel.bottomAnchor.constraint(equalTo: sceneView.safeAreaLayoutGuide.bottomAnchor, constant: -16).isActive = true
    }
    
    func getGroundClearance(_ groundClearance: Float) {
        drawStore()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        sceneView.run()
        //addProductsImagesIntoScene()
        //drawRoute()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
          super.viewWillDisappear(animated)
          sceneView.pause()
    }
    
    private func addProductsImagesIntoScene() {
        for each in storeModel.planStore {
            if let image = storeModel.images[each.key] {
                let imageNode = SceneNodeCreator.getImageNode(image: image, name: each.key.rawValue)
                sceneView.scene.rootNode.addChildNode(imageNode)
            }
        }
    }
    
    private func updateNodesPosition(userPosition: EILOrientedPoint) {
        for eachNode in sceneView.scene.rootNode.childNodes {
            if let nodeName = eachNode.name, let product = ProductDepartment(rawValue: nodeName), let productPosition = storeModel.planStore[product] {
                let userPos = CGPoint(x: userPosition.x, y: userPosition.y)
                eachNode.position = viewModel.getPosition(userPosition: userPos, productPosition: productPosition)
            }
        }
    }
    
    private func drawStore() {
        userPosition = EILOrientedPoint(x: 0, y: 0) //TODO: remove it
        
        let pathNodes = viewModel.getPaths(userLocation: CGPoint.zero, groundClearance: sceneView.groundClearance - 0.5)
        for node in pathNodes {
           sceneView.scene.rootNode.addChildNode(node)
        }
    }
    
    private func drawRoute() {
        userPosition = EILOrientedPoint(x: 0, y: 0) //TODO: remove it
        navigateToProduct = .shoes
        
        guard let product = navigateToProduct, let navigateToPosition = storeModel.planStore[product], let userPosition = userPosition else { return }
        
        storeModel.makeGraph()
        let userLocation = CGPoint(x: userPosition.x, y: userPosition.y)
        let routePoints = storeModel.findoutRoutePoints(from: userLocation, to: navigateToPosition, product: navigateToProduct!)
        print("Path Nodes:", routePoints)
        let nodes = viewModel.getArrowNodes(from: userLocation, with: routePoints)
        for each in nodes {
            sceneView.scene.rootNode.addChildNode(each)
        }
    }
}

extension ARViewController: UserPositionUpdateProtocol {
    
    func getUserUpdate(position: EILOrientedPoint, accuracy: EILPositionAccuracy, location: EILLocation) {
        let userLocation = String(format: "x: %5.2f, y: %5.2f",position.x, position.y)
        debugLabel.text = userLocation
        userPosition = position
        updateNodesPosition(userPosition: position)
    }
    
    func userDidEnterBeaconsRegion(attachmentValue: String) {
        print(attachmentValue)
    }
}


