//
//  ViewController.swift
//  See Object
//
//  Created by kitiwat chanluthin on 9/14/17.
//  Copyright © 2017 kitiwat chanluthin. All rights reserved.
//

import UIKit
import CoreML
import Vision
import AVFoundation


class CameraVC: UIViewController {

    var settingImage = false
    var frameExtractor:FrameExtractor!
    
    
    @IBOutlet weak var previewImage: UIImageView!
    @IBOutlet weak var iSee: UILabel!
    
    
    var currentImage:CIImage?{
        didSet{
            if let image = currentImage{
                self.detectScene(image: image)
            }
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        frameExtractor = FrameExtractor()
        frameExtractor.delegate = self
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let uiExample = UIImage(named:"car"){
            let example = CIImage(image:uiExample)
            self.detectScene(image: example!)
        }
    }
    
    func detectScene(image:CIImage){
        guard let model = try? VNCoreMLModel(for: Inceptionv3().model) else{
            fatalError()
        }
        let request = VNCoreMLRequest(model: model) { (request, error) in
            guard let results = request.results as? [VNClassificationObservation],
                let _ = results.first else{
                    self.settingImage = false
                    return
            }
            
            DispatchQueue.main.async { [unowned self] in
                if let first = results.first{
                    let firstConfidence = Int(first.confidence * 100)
                    if (firstConfidence) > 1 {
                        print("raw confidence \(firstConfidence)")
                        self.iSee.text = "I see \(first.identifier)  confidence:\(firstConfidence)%"
                        //print("I see \(first.identifier)  confidence:\(Int(first.confidence*100))%")
                        self.settingImage = false
                    }else{
                        self.iSee.text = "?? Not sure \(first.identifier)  confidence:\(firstConfidence)%"
                    }
                }
                
//                for classification in results{
//                    if classification.confidence < 0.7 {
//                        let unknowObjectMessage = "Not sure what this is."
//                        self.iSee.text = unknowObjectMessage
//                        //synthesizeSpeech(fromString: unknowObjectMessage)
//                        //self.confidenceLbl.text = ""
//                        break
//                    }else{
//                        let identification = classification.identifier
//                        let confidence = Int(classification.confidence * 100)
//
//                        //self.confidenceLbl.text = "CONFIDENCE: \(confidence) %"
//                        let completeSentence = "This look like a \(identification) and I'm \(confidence) percent sure."
//                        self.iSee.text = completeSentence
//                        //synthesizeSpeech(fromString: completeSentence)
//                        break
//                    }
//                }
            }//end dispatchQueue
        }//end let request
        
        let handler = VNImageRequestHandler(ciImage: image)
        DispatchQueue.global(qos: .userInteractive).async {
            do{
                try handler.perform([request])
            }catch{
                debugPrint(error)
            }
        }
        
    }//end detectScene


}//end class CameraVC

extension CameraVC:FrameExtractorDelegate{
    func captured(image: UIImage) {
        self.previewImage.image = image
        if let test_cgImage = image.cgImage, !settingImage{
            settingImage = true
            DispatchQueue.global(qos: .userInteractive).async { [unowned self] in
                self.currentImage = CIImage(cgImage:test_cgImage)
            }
        }
    }
}



















