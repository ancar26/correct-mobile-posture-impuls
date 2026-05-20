import AVFoundation
import Vision
import Combine

final class CameraManager: NSObject, ObservableObject {
    let captureSession = AVCaptureSession()

    // Head pitch in radians from VNFaceObservation (negative = chin down)
    @Published private(set) var facePitch: Double? = nil
    // Head yaw in radians (how much the face is turned left/right)
    @Published private(set) var faceYaw: Double? = nil
    // Shoulder asymmetry: normalized Y-position difference between left/right shoulder
    @Published private(set) var shoulderSlope: Double? = nil

    private let videoOutput = AVCaptureVideoDataOutput()
    private let sessionQueue = DispatchQueue(label: "postureguard.camera.session")
    private let analysisQueue = DispatchQueue(label: "postureguard.camera.analysis")

    override init() {
        super.init()
        configureSession()
    }

    func start() {
        sessionQueue.async { [weak self] in
            guard let self, !captureSession.isRunning else { return }
            captureSession.startRunning()
        }
    }

    func stop() {
        sessionQueue.async { [weak self] in
            guard let self, captureSession.isRunning else { return }
            captureSession.stopRunning()
        }
    }

    private func configureSession() {
        sessionQueue.async { [weak self] in
            guard let self else { return }
            captureSession.beginConfiguration()
            captureSession.sessionPreset = .medium

            guard
                let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front),
                let input = try? AVCaptureDeviceInput(device: device),
                captureSession.canAddInput(input)
            else {
                captureSession.commitConfiguration()
                return
            }
            captureSession.addInput(input)

            videoOutput.alwaysDiscardsLateVideoFrames = true
            videoOutput.setSampleBufferDelegate(self, queue: analysisQueue)
            if captureSession.canAddOutput(videoOutput) {
                captureSession.addOutput(videoOutput)
            }

            captureSession.commitConfiguration()
        }
    }
}

extension CameraManager: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }

        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .leftMirrored)

        // Request 1: Face with roll/pitch/yaw angles
        let faceRequest = VNDetectFaceRectanglesRequest { [weak self] req, _ in
            guard let self else { return }
            guard let faces = req.results as? [VNFaceObservation], let face = faces.first else {
                DispatchQueue.main.async {
                    self.facePitch = nil
                    self.faceYaw = nil
                }
                return
            }
            let pitch = face.pitch.map { Double(truncating: $0) }
            let yaw = face.yaw.map { Double(truncating: $0) }
            DispatchQueue.main.async {
                self.facePitch = pitch
                self.faceYaw = yaw
            }
        }

        // Request 2: Body pose for shoulder line
        let bodyRequest = VNDetectHumanBodyPoseRequest { [weak self] req, _ in
            guard let self else { return }
            guard let observations = req.results as? [VNHumanBodyPoseObservation],
                  let body = observations.first else {
                DispatchQueue.main.async { self.shoulderSlope = nil }
                return
            }
            let leftShoulder = try? body.recognizedPoint(.leftShoulder)
            let rightShoulder = try? body.recognizedPoint(.rightShoulder)

            if let l = leftShoulder, let r = rightShoulder,
               l.confidence > 0.4, r.confidence > 0.4 {
                // Difference in Y position between shoulders — large value = uneven/hunched
                let slope = abs(Double(l.location.y) - Double(r.location.y))
                DispatchQueue.main.async { self.shoulderSlope = slope }
            } else {
                DispatchQueue.main.async { self.shoulderSlope = nil }
            }
        }

        try? handler.perform([faceRequest, bodyRequest])
    }
}
