//
//  ViewController.swift
//  sensortest
//
//  Created by Ahmed El Ashwah on 27/01/2024.
//

import UIKit
import CoreMotion
class ViewController: UIViewController {
    
    
    @IBOutlet weak var textView: UILabel!
    @IBOutlet weak var counterText: UILabel!
    let manager = CMMotionManager()
    var counter = 0
    let recorder = CMSensorRecorder()
    var text = ""
    var recording = false
    var dateStart = Date()
    let activityManager = CMMotionActivityManager()
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        textView.text = ""
        counterText.text = ""
        //startMotionUpdates()
        
        if CMSensorRecorder.isAccelerometerRecordingAvailable(){
            if CMSensorRecorder.authorizationStatus() == .authorized {
                start()
            }
            else {
                self.activityManager.startActivityUpdates(to: OperationQueue.main, withHandler: {(data: CMMotionActivity!) -> Void in
                    if CMSensorRecorder.authorizationStatus() == .authorized {
                        self.start()
                    }
                    else{
                        print("\(CMSensorRecorder.authorizationStatus())")
                        self.textView.text = "not authorised"
                        
                    }
                })
                print("\(CMSensorRecorder.authorizationStatus())")
                self.textView.text = "not authorised"
            }
        }
        else {
            print ("Recording not available")
            self.textView.text = "Not available"
        }
        NotificationCenter.default.addObserver(self, selector: #selector(startMotionUpdates), name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(startMotionUpdates), name: UIApplication.didEnterBackgroundNotification, object: nil)
    }
    func start(){
        DispatchQueue.global(qos: .background).async {
            DispatchQueue.global(qos: .background).sync{
                self.dateStart = Date()
                self.recording = true
                self.recorder.recordAccelerometer(forDuration: 60*60)
                DispatchQueue.main.async {
                    self.textView.text = "Started Recording, you can send the App to background "
                }
            }
        }
    }
    @IBAction func backAction(_ sender: Any) {
        UIApplication.shared.perform(#selector(NSXPCConnection.suspend))
    }
    @objc func startMotionUpdates(){
        if recording{
            //DispatchQueue.global(qos: .background).async {
                let accelerometerData = self.recorder.accelerometerData(from: self.dateStart, to: Date())
                var count = 0
                guard accelerometerData?.enumerated() != nil else{
                    return
                }
                for (_, data) in (accelerometerData?.enumerated())! {
                    if let data = data as? CMRecordedAccelerometerData {
                            self.textView.text = "x: \(data.acceleration.x.toStringFromated(3)) , Y: \(data.acceleration.y.toStringFromated(3)) , Z: \(data.acceleration.z.toStringFromated(3))"
                        
                    }
                    count += 1
                }
                self.counterText.text = "counter: \(count)"
            //}
        }
    }

}

extension Double {
    //MARK: - Using string interpolation
    func toStringFromated(_ numOfDecimal: Int) -> String {
        return String(format: "%.\(numOfDecimal)f", self)
    }
}
extension CMSensorDataList: Sequence {
    public typealias Iterator = NSFastEnumerationIterator

    public func makeIterator() -> NSFastEnumerationIterator {
        return NSFastEnumerationIterator(self)
    }
}
