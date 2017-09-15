//
//  ArdetectVC.swift
//  See Object
//
//  Created by kitiwat chanluthin on 9/14/17.
//  Copyright © 2017 kitiwat chanluthin. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import Vision


class ArdetectVC: UIViewController {

    // SCENE
    @IBOutlet weak var sceneView: ARSCNView!
    @IBOutlet weak var debugLbl: UILabel!
    
    var lastestPrediction  = "N/A"
    
    // COREML
    var visionRequest = [VNRequest]()
    let disPatchQueueML = DispatchQueue(label: "MLqueue")
    
    override func viewDidLoad() {
        super.viewDidLoad()

        sceneView.delegate = self
        sceneView.showsStatistics = true
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        
        let scene = SCNScene()
        sceneView.scene = scene
        
//        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(gesture:)))
        //view.addGestureRecognizer(tap)

        // set up Vision
        
        guard let inceptionV3Model = try? VNCoreMLModel(for: Inceptionv3().model) else{
            fatalError("Error setup InceptionV3")
        }
        
        let classificationRequest = VNCoreMLRequest(model: inceptionV3Model ,completionHandler:classificationCompleteHandler)
        classificationRequest.imageCropAndScaleOption = VNImageCropAndScaleOption.centerCrop
        visionRequest = [classificationRequest]
        
        loopCoreMLUpdate()
    }
    
    func loopCoreMLUpdate(){
        disPatchQueueML.async {
            self.updateCoreML()
            self.loopCoreMLUpdate()
        }
    }
    
    func updateCoreML(){
        let pixelBuffer:CVPixelBuffer?  = (sceneView.session.currentFrame?.capturedImage)
        guard pixelBuffer != nil else {return}
        let ciImage = CIImage(cvImageBuffer: pixelBuffer!)
        
        let imageRequestHandler = VNImageRequestHandler(ciImage: ciImage)
        
        do{
            try imageRequestHandler.perform(self.visionRequest)
        }catch{
            debugPrint("image request error \(error)")
        }
    }
    
    func classificationCompleteHandler(request:VNRequest,error:Error?){
        guard let results = request.results as? [VNClassificationObservation] else {return}
        DispatchQueue.main.async {
            if let first = results.first{
                let firstConfidence = Int(first.confidence * 100)
                self.debugLbl.text = "\(first.identifier) confidence:\(firstConfidence)%"
//                print("first.identifier |\(first.identifier)|")
                var objName = (first.identifier).components(separatedBy: ",")
                self.lastestPrediction = objName[0]
                
            }
        }
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    @objc func handleTap(gesture:UITapGestureRecognizer){
        
//        let sceneCentre:CGPoint = CGPoint(x: self.sceneView.bounds.midX, y: self.sceneView.bounds.midY)
//
//        let arHitTestResults:[ARHitTestResult] = sceneView.hitTest(sceneCentre, types: [.featurePoint])
//
//        if let closestResult = arHitTestResults.first{
//
//            let transform:matrix_float4x4 = closestResult.worldTransform
//            let worldCoord : SCNVector3 = SCNVector3Make(transform.columns.3.x, transform.columns.3.y, transform.columns.3.z)
//
//            let node : SCNNode = BubbleText.createNewBubbleParentNode(text: lastestPrediction)
//            sceneView.scene.rootNode.addChildNode(node)
//            node.position = worldCoord
//        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard  let touch = touches.first else { return }
        let touchLocation = touch.location(in: sceneView)
        let results = sceneView.hitTest(touchLocation, types: .featurePoint)
        if let hitResult = results.first{
            let node : SCNNode = BubbleText.createNewBubbleParentNode(text: lastestPrediction)
            sceneView.scene.rootNode.addChildNode(node)
            node.position = SCNVector3(hitResult.worldTransform.columns.3.x, hitResult.worldTransform.columns.3.y, hitResult.worldTransform.columns.3.z)
        }
    }

}

extension ArdetectVC:ARSCNViewDelegate{
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        DispatchQueue.main.async {
            //print("<#T##items: Any...##Any#>")
        }
        
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        if anchor is ARPlaneAnchor{
            
//            let planeAnchor = anchor as! ARPlaneAnchor
//
//            let plane = SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z))
//
//            let planeNode = SCNNode()
//
//            planeNode.position = SCNVector3(planeAnchor.center.x, 0, planeAnchor.center.z)
//
//            planeNode.transform = SCNMatrix4MakeRotation(-Float.pi/2, 1, 0, 0)
//
//            let gridMaterial = SCNMaterial()
//
//            gridMaterial.diffuse.contents = UIImage(named:"grid.png")
//
//            plane.materials = [gridMaterial]
//
//            planeNode.geometry = plane
//
//            node.addChildNode(planeNode)
            
        }else{
            return
        }
    }
    
}
extension UIFont {
    // Based on: https://stackoverflow.com/questions/4713236/how-do-i-set-bold-and-italic-on-uilabel-of-iphone-ipad
    func withTraits(traits:UIFontDescriptorSymbolicTraits...) -> UIFont {
        let descriptor = self.fontDescriptor.withSymbolicTraits(UIFontDescriptorSymbolicTraits(traits))
        return UIFont(descriptor: descriptor!, size: 0)
    }
}
