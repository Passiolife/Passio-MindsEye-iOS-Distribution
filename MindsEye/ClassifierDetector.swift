//  Copyright © 2021 Passio Inc. All rights reserved.

import UIKit
import CoreML
import Vision

struct ClassifierDetector {

    let numberOfCandidates = 5
    var coreModel: VNCoreMLModel?
    
    init() {
        guard let modelURL = Bundle.main.url(forResource: "My-Passio-MindsEye-Model",
                                             withExtension: "mlmodelc") else {
            print("Couldn't find the model My-Passio-MindsEye-Model.mlmodel")
            return
        }

        do {
            let model = try MLModel(contentsOf: modelURL) //, configuration: config )
            coreModel = try VNCoreMLModel(for: model)
        } catch let error as NSError {
            print("Error loading model: \(error)")
        }
    }

    func detectCandidatesIn(cmSampleBuffer: CMSampleBuffer,
                            completion: @escaping ([ClassCandidateImp]) -> Void) {

        guard let coreModel = coreModel else {
            completion([])
            print("No core Model")
            return
        }

        let request = VNCoreMLRequest(model: coreModel) { (data, _) in
            guard let results = data.results as? [VNClassificationObservation] else {
                completion([])
                return
            }
            let number = results.count < self.numberOfCandidates ? results.count : self.numberOfCandidates
            var candidates = [ClassCandidateImp]()
            for i in 0..<number {
                let newCandidate = ClassCandidateImp(label: results[i].identifier,
                                                     confidence: Double(results[i].confidence)
                )
                candidates.append(newCandidate)
            }

            candidates.sort {$1.confidence < $0.confidence}
            completion(candidates)
        }

        request.imageCropAndScaleOption = .scaleFill

        try? VNImageRequestHandler(cmSampleBuffer: cmSampleBuffer).perform([request])
    }

}

struct ClassCandidateImp {
    var label: String
    var confidence: Double
}
