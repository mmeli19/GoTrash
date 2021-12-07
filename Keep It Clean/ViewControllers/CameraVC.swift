//
//  CameraVC.swift
//  Keep It Clean
//
//  Created by Emmanuel Gyekye Atta-Penkra on 10/26/21.
//

import UIKit
import AVFoundation

class CameraVC: UIViewController {

    // Capture Session
    var session: AVCaptureSession?
    // Photo Output
    let output = AVCapturePhotoOutput()
    // Video Preview
    let previewLayer = AVCaptureVideoPreviewLayer()
    // Shutter Button
    @IBOutlet weak var shutterButton: UIButton!
    @IBOutlet weak var mapImageView: UIImageView!
    @IBOutlet weak var previewImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.layer.insertSublayer(previewLayer, at: 0)
        
        setUpShutterButton()
        setUpGestures()
        checkCameraPermissions()
        
        shutterButton.addTarget(self, action: #selector(didTapTakePhoto), for: .touchUpInside)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer.frame = view.bounds
    }
    
    private func checkCameraPermissions(){
        switch AVCaptureDevice.authorizationStatus(for: .video){
        case .notDetermined:
            // Request
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                guard granted else { return }
                
                DispatchQueue.main.async {
                    self?.setUpCamera()
                }
            }
        case .restricted, .denied:
            break
        case .authorized:
            setUpCamera()
        @unknown default:
            break
        }
    }
    
    private func setUpShutterButton(){
        shutterButton.layer.cornerRadius = 50
        shutterButton.layer.borderWidth = 10
        shutterButton.layer.borderColor = UIColor.white.cgColor
    }
    
    private func setUpGestures(){
        mapImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(mapClicked)))
        previewImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(previewClicked)))
    }
    
    private func setUpCamera(){
        let session = AVCaptureSession()
        if let device = AVCaptureDevice.default(for: .video){
            do {
                let input = try AVCaptureDeviceInput(device: device)
                
                if session.canAddInput(input) {
                    session.addInput(input)
                }
                
                if session.canAddOutput(output) {
                    session.addOutput(output)
                }
                
                previewLayer.videoGravity = .resizeAspectFill
                previewLayer.session = session
                
                session.startRunning()
                
                self.session = session
            } catch {
                print(error)
            }
        }
    }
    
    @objc private func didTapTakePhoto(){
        shutterButton.isEnabled = false
        output.capturePhoto(with: AVCapturePhotoSettings(),
                            delegate: self)
    }
    
    @objc private func mapClicked(){
        mainVC.changeView(to: 0)
    }
    
    @objc private func previewClicked(){
        mainVC.changeView(to: 2)
    }
    
//    override func viewDidAppear(_ animated: Bool) {
//        session?.startRunning()
//    }
//
//    override func viewDidDisappear(_ animated: Bool) {
//        session?.stopRunning()
//    }
}

extension CameraVC: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        shutterButton.isEnabled = true
        guard let data = photo.fileDataRepresentation() else { return }
        
        let image = UIImage(data: data)
        
//        session?.stopRunning()
        previewImageView.image = image
        
        guard let location = mainVC.location else { return }
        mainVC.trashes.append(Trash(image: image!, latitude: location.coordinate.latitude, longitude: location.coordinate.longitude))
    }
}
