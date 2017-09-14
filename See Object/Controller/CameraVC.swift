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


class CameraVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    func detectScene(image:CIImage){
        guard let model = try? VNCoreMLModel(for: Inceptionv3().model) else{
            fatalError()
        }
        let request = VNCoreMLRequest(model: model) { (request, error) in
            guard let results = request.results as? [VNClassificationObservation],
                let _ = results.first else{
                        //self.settingImage = false
                    return
            }
        }//end let request
       
        
    }


}

