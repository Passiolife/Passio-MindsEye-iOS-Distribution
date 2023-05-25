//
//  ViewController.swift
//  MindsEye
//
//  Created by Zvika on 4/27/23.
//

import UIKit
import AVFoundation
import VideoToolbox

class ViewController: UIViewController {
    
 let classifierDetector = ClassifierDetector()
    
//Simple UI
    @IBOutlet weak var classLabel: UILabel!
// Preview Layer from the camera.
    var previewLayer: AVCaptureVideoPreviewLayer?
    var captureSession: AVCaptureSession?
// Parameters to send the PixelBuffer to the Classifier
    var timeBetweenDetection = 0.5
    var lastImageTime = Date()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if AVCaptureDevice.authorizationStatus(for: .video) == .authorized {
            setupPreviewLayer()
        } else {
            AVCaptureDevice.requestAccess(for: .video) { (granted) in
                if granted {
                    DispatchQueue.main.async {
                        self.setupPreviewLayer()
                    }
                } else {
                    print("The user didn't grant access to use camera")}
            }
        }
        
    }

    func setupPreviewLayer() {
        captureSession = AVCaptureSession()
        guard let session = captureSession else { return }
        session.beginConfiguration()
        session.sessionPreset = .hd1920x1080
        let deviceTypes: [AVCaptureDevice.DeviceType] = [.builtInDualCamera, .builtInWideAngleCamera]
        let videoSession = AVCaptureDevice.DiscoverySession(deviceTypes: deviceTypes,
                                                            mediaType: .video,
                                                            position: .back)
        guard let videoDevice = videoSession.devices.first,
              let videoDeviceInput = try? AVCaptureDeviceInput(device: videoDevice),
              session.canAddInput(videoDeviceInput) else {
                  return
              }
        session.addInput(videoDeviceInput)
        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        guard session.canAddOutput(videoOutput) else {
            return
        }
        session.addOutput(videoOutput)
        session.commitConfiguration()
        previewLayer = AVCaptureVideoPreviewLayer()
        guard let preview = previewLayer else {
            return
        }
        preview.session = captureSession
        DispatchQueue.global(qos: .userInteractive).async {
            session.startRunning()
        }
        preview.videoGravity = AVLayerVideoGravity.resizeAspectFill
        preview.frame = view.bounds
        preview.connection?.videoOrientation = .portrait
        view.layer.insertSublayer(preview, at: 0)
    }

}

extension ViewController: AVCaptureVideoDataOutputSampleBufferDelegate {

    func captureOutput(_ output: AVCaptureOutput,
                       didOutput sampleBuffer: CMSampleBuffer,
                       from connection: AVCaptureConnection) {

        guard Date().timeIntervalSince(lastImageTime) > timeBetweenDetection else {
                  return
              }

        lastImageTime = Date()

        classifierDetector.detectCandidatesIn(cmSampleBuffer: sampleBuffer) { candidates in
            DispatchQueue.main.async {
                if let first = candidates.first {
                    self.classLabel.text = "\(first.label): \(round(first.confidence*100)/100)"
                        } else {
                    self.classLabel.text = "Scanning"
                }
            }
        }
    }

}

