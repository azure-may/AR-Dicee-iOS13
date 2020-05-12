//
//  ViewController.swift
//  ARDicee
//
//  Created by Azure May Burmeister on 3/30/20.
//  Copyright © 2020 Azure May Burmeister. All rights reserved.
//

import UIKit
import SceneKit
import ARKit


class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    var diceArray = [SCNNode]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        sceneView.delegate = self
        sceneView.autoenablesDefaultLighting = true
    
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        sceneView.session.run(configuration)

    }
        
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        sceneView.session.pause()
    }
    
    //MARK: - Dice Rendering Methods
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let touchLocation = touch.location(in: sceneView)
            let results = sceneView.hitTest(touchLocation, types: .existingPlaneUsingExtent)
            if let hitResult = results.first {
                addDie(hitResult)
            }
        }
    }
    
    private func addDie(_ location: ARHitTestResult) {
        let diceScene = SCNScene(named: "art.scnassets/dice.scn")!
        if let diceNode = diceScene.rootNode.childNode(withName: "Dice", recursively: true) {
            diceNode.position = SCNVector3(
                x: location.worldTransform.columns.3.x,
                y: location.worldTransform.columns.3.y + diceNode.boundingSphere.radius,
                z: location.worldTransform.columns.3.z
            )
            diceArray.append(diceNode)
            sceneView.scene.rootNode.addChildNode(diceNode)
            roll(diceNode)
        }
    }
    
    private func rollAll() {
        if !diceArray.isEmpty {
            for die in diceArray {
                roll(die)
            }
        }
    }
    
    private func roll(_ die: SCNNode) {
        let randomX = Float(arc4random_uniform(4) + 1) * (Float.pi/2)
        let randomY = Float(arc4random_uniform(4) + 1) * (Float.pi/2)
        let randomZ = Float(arc4random_uniform(8) + 1) * (Float.pi/2)
        die.runAction(
            SCNAction.rotateBy(
                x: CGFloat(randomX * 3),
                y: CGFloat(randomY * 3),
                z: CGFloat(randomZ),
                duration: 0.5
            )
        )
    }
    
    @IBAction func rollAgain(_ sender: UIBarButtonItem) {
        rollAll()
    }
    
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        rollAll()
    }
    
    @IBAction func clearDice(_ sender: UIBarButtonItem) {
        if !diceArray.isEmpty {
            for die in diceArray {
                die.removeFromParentNode()
            }
        }
    }
    
    //MARK: - ARSCNSViewDelegateMethods
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        let planeNode = createPlane(planeAnchor)
        node.addChildNode(planeNode)
    }

    //MARK: - Plane Rendering Methods
    
    private func createPlane(_ planeAnchor: ARPlaneAnchor) -> SCNNode {
        let plane = SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z))
        let planeNode = SCNNode()
        planeNode.position = SCNVector3(planeAnchor.center.x, 0, planeAnchor.center.z)
        planeNode.transform = SCNMatrix4MakeRotation(-Float.pi/2, 1, 0, 0)
        planeNode.opacity = 0.0
        planeNode.geometry = plane
        return planeNode
    }
}
