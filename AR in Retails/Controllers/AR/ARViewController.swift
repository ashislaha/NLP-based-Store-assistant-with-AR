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
    var isStartShopping = false
    
    var navigateToProduct: ProductDepartment?
    private var userPosition: EILOrientedPoint?
    
    private var items: [ProductDepartment: [String]] = [:]
   
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
    
    private let shoppingList: ShoppingList = {
        let shoppingList = ShoppingList()
        shoppingList.translatesAutoresizingMaskIntoConstraints = false
        shoppingList.clipsToBounds = true
        return shoppingList
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        sceneView.run()
        addProductsImagesIntoScene()
        updateNodesPosition(userPosition: EILOrientedPoint(x: 0, y: 9))
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.pause()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        addSceneView()
        sceneView.delegate = self
        
        navigationItem.title = productData
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate, let beaconManager = appDelegate.beaconManager {
            beaconManager.delegate = self
            addDebugLabel()
        }
       
        if isStartShopping {
            addShoppingList()
            drawRoute()
            drawShoppingItems()
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
        debugLabel.bottomAnchor.constraint(equalTo: sceneView.safeAreaLayoutGuide.bottomAnchor, constant: -116).isActive = true
    }
    
    private func addShoppingList() {
        guard !StoreModel.shared.shoppingList.isEmpty else { return }
        
        var totalImages: [(UIImage, String)] = []
        let departments: [ProductDepartment] = [.fruits, .groceries, .shoes, .mobiles, .laptops, .fashion]
        
        // product names - show in 3-D text
        for each in departments {
            let productName = StoreModel.shared.shoppingList[each]!.map{ $0.prodName }
            items[each] = productName
        }

        // product images
        for each in departments {
            let images = StoreModel.shared.shoppingList[each]!.map{ ($0.image, $0.prodName) }
            totalImages.append(contentsOf: images)
        }

        shoppingList.images = totalImages
        sceneView.addSubview(shoppingList)
        shoppingList.delegate = self
        
        NSLayoutConstraint.activate([
            shoppingList.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor, constant: 0),
            shoppingList.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -8),
            shoppingList.widthAnchor.constraint(equalToConstant: 210),
            shoppingList.heightAnchor.constraint(equalToConstant: 100)
            ])
    }
    
    func drawShoppingItems() {
        guard !items.isEmpty else { return }
        let userPos = CGPoint(x: 0, y: 9)
        
        for (key, value) in items {
            switch key {
                
            case .fruits:
                var i: Float = 0
                let productPosition = storeModel.planStore[.fruits]!
                let position = viewModel.getPosition(userPosition: userPos, productPosition: productPosition)
                for eachItem in value {
                    let node = SceneNodeCreator.create3DText(eachItem, position: SCNVector3Make(position.x - 0.5, 0 + i, position.z))
                    sceneView.scene.rootNode.addChildNode(node)
                    i += 0.3
                }
                let marker = SceneNodeCreator.getImageNode(image: #imageLiteral(resourceName: "map-pin-hi"), name: "")
                marker.position = SCNVector3Make(position.x - 0.5, 0 + i, position.z)
                sceneView.scene.rootNode.addChildNode(marker)
                
            case .groceries:
                var i: Float = 0
                let productPosition = storeModel.planStore[.groceries]!
                let position = viewModel.getPosition(userPosition: userPos, productPosition: productPosition)
                for eachItem in value {
                    let node = SceneNodeCreator.create3DText(eachItem, position: SCNVector3Make(position.x + 0.5, 0 + i, position.z))
                    sceneView.scene.rootNode.addChildNode(node)
                    i += 0.3
                }
                
                if !value.isEmpty {
                    let marker = SceneNodeCreator.getImageNode(image: #imageLiteral(resourceName: "map-pin-hi"), name: "")
                    marker.position = SCNVector3Make(position.x + 0.5, 0 + i , position.z)
                    sceneView.scene.rootNode.addChildNode(marker)
                }
                
            case .shoes:
                var i: Float = 0
                let productPosition = storeModel.planStore[.shoes]!
                let position = viewModel.getPosition(userPosition: userPos, productPosition: productPosition)
                for eachItem in value {
                    let node = SceneNodeCreator.create3DText(eachItem, position: SCNVector3Make(position.x, 0 + i, position.z + 1))
                    sceneView.scene.rootNode.addChildNode(node)
                    i += 0.3
                }
                
                if !value.isEmpty {
                    let marker = SceneNodeCreator.getImageNode(image: #imageLiteral(resourceName: "map-pin-hi"), name: "")
                    marker.position = SCNVector3Make(position.x, 0 + i, position.z + 1)
                    sceneView.scene.rootNode.addChildNode(marker)
                }
                
            case .mobiles:
                var i: Float = 0
                let productPosition = storeModel.planStore[.mobiles]!
                let position = viewModel.getPosition(userPosition: userPos, productPosition: productPosition)
                for eachItem in value {
                    let node = SceneNodeCreator.create3DText(eachItem, position: SCNVector3Make(position.x, 0 + i, position.z + 1))
                    sceneView.scene.rootNode.addChildNode(node)
                    i += 0.3
                }
                if !value.isEmpty {
                    let marker = SceneNodeCreator.getImageNode(image: #imageLiteral(resourceName: "map-pin-hi"), name: "")
                    marker.position = SCNVector3Make(position.x, 0 + i, position.z + 1)
                    sceneView.scene.rootNode.addChildNode(marker)
                }
                
            case .laptops:
                
                var i: Float = 0
                let productPosition = storeModel.planStore[.shoes]!
                let position = viewModel.getPosition(userPosition: userPos, productPosition: productPosition)
                for eachItem in value {
                    let node = SceneNodeCreator.create3DText(eachItem, position: SCNVector3Make(position.x, 0 + i, position.z - 1))
                    sceneView.scene.rootNode.addChildNode(node)
                    i += 0.3
                }
                
                if !value.isEmpty {
                    let marker = SceneNodeCreator.getImageNode(image: #imageLiteral(resourceName: "map-pin-hi"), name: "")
                    marker.position = SCNVector3Make(position.x, 0 + i, position.z - 1)
                    sceneView.scene.rootNode.addChildNode(marker)
                }
                
                
            case .fashion:
                var i: Float = 0
                let productPosition = storeModel.planStore[.fashion]!
                let position = viewModel.getPosition(userPosition: userPos, productPosition: productPosition)
                for eachItem in value {
                    let node = SceneNodeCreator.create3DText(eachItem, position: SCNVector3Make(position.x, 0 + i, position.z - 1))
                    sceneView.scene.rootNode.addChildNode(node)
                    i += 0.3
                }
                
                if !value.isEmpty {
                    let marker = SceneNodeCreator.getImageNode(image: #imageLiteral(resourceName: "map-pin-hi"), name: "")
                    marker.position = SCNVector3Make(position.x, 0 + i, position.z - 1)
                    sceneView.scene.rootNode.addChildNode(marker)
                }
            }
        }
    }
    
    func getGroundClearance(_ groundClearance: Float) {
        drawStore()
    }
    
    private func drawRoute() {
        userPosition = EILOrientedPoint(x: 0, y: 9) //TODO: remove it
        let userLocation = CGPoint(x: 0, y: 9)
        
        /*
         navigateToProduct = .shoes
         guard let product = navigateToProduct, let navigateToPosition = storeModel.planStore[product], let userPosition = userPosition else { return }
         storeModel.makeGraph()
         let userLocation = CGPoint(x: userPosition.x, y: userPosition.y)
         let routePoints = storeModel.findoutRoutePoints(from: userLocation, to: navigateToPosition, product: navigateToProduct!)
         print("Path Nodes:", routePoints)
         */
        
        let routePoints: [CGPoint] = [CGPoint(x: 4.5, y: 9.5)] //  CGPoint(x: 9, y: 9), CGPoint(x: 9, y: 6), CGPoint(x: 4.5, y: 6)
        let nodes = viewModel.getArrowNodes(from: userLocation, with: routePoints)
        for each in nodes {
            sceneView.scene.rootNode.addChildNode(each)
        }
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
        userPosition = EILOrientedPoint(x: 0, y: 9) //TODO: remove it
        
        let pathNodes = viewModel.getPaths(userLocation: CGPoint(x: 0, y: 9), groundClearance: sceneView.groundClearance - 0.5)
        for node in pathNodes {
           sceneView.scene.rootNode.addChildNode(node)
        }
    }
}

extension ARViewController: UserPositionUpdateProtocol {
    
    func getUserUpdate(position: EILOrientedPoint, accuracy: EILPositionAccuracy, location: EILLocation) {
        let userLocation = String(format: "x: %5.2f, y: %5.2f",position.x, position.y)
        debugLabel.text = userLocation
        userPosition = position
        // update product based on user location
        // updateNodesPosition(userPosition: position)
    }
    
    func userDidEnterBeaconsRegion(attachmentValue: String) {
        print(attachmentValue)
    }
}

extension ARViewController: ShoppingListProtocol {
    func didSelectProduct(indexPath: IndexPath) {
        let productName = shoppingList.images[indexPath.item].1
        let alert = UIAlertController(title: "Pick up Confirmation", message: "\(productName) picked up", preferredStyle: .alert)
        let yesAction = UIAlertAction(title: "Yes", style: .default) { [weak self] (action) in
            // remove the product from shopping images and store dictionary
            self?.shoppingList.images.remove(at: indexPath.item)
            self?.shoppingList.collectionView.reloadData()
        }
        let noAction = UIAlertAction(title: "No", style: .default, handler: nil)
        alert.addAction(yesAction)
        alert.addAction(noAction)
        present(alert, animated: true, completion: nil)
    }
}


