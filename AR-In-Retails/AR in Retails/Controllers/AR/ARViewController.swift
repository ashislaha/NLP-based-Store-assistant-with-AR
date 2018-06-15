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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addRightBarButtonItems()
        sceneView.delegate = self
        navigationItem.title = productData
        
        guard let scene = SCNScene(named: "./model.scn") else { return }
        let sceneNode = scene.rootNode
        sceneNode.position = SCNVector3(x: 0, y: 0, z: -1)
        sceneNode.runAction(SCNAction.rotateBy(x: 0, y: CGFloat(Float.pi/2), z: 0, duration: 0.5))
        addNodesToScene()
        sceneView.scene.rootNode.addChildNode(sceneNode)
    }
    
    
    private func addRightBarButtonItems() {
        
        let barbuttonItem2 = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(tappedDialogflowView))
        
        navigationItem.rightBarButtonItems = [barbuttonItem2]
        
    }
    
    @objc func tappedDialogflowView() {
        pushDFVC()
    }
    
    public func pushDFVC() {
        guard let dfVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DialogflowViewController") as? DialogflowViewController else { return }
        navigationController?.pushViewController(dfVC, animated: true)
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
