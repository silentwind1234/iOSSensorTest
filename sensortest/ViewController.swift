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
    var text = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        textView.text = ""
        counterText.text = "Counted Updates: 0"
        startMotionUpdates()
        NotificationCenter.default.addObserver(self, selector: #selector(startMotionUpdates), name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(startMotionUpdates), name: UIApplication.didEnterBackgroundNotification, object: nil)
    }
    
    @IBAction func backAction(_ sender: Any) {
        UIApplication.shared.perform(#selector(NSXPCConnection.suspend))
    }
    @objc func startMotionUpdates(){
        if manager.isAccelerometerAvailable {
            manager.deviceMotionUpdateInterval = 1
            manager.startAccelerometerUpdates(to: .current!) { [weak self] data, err in
                print(self?.counter ?? 0)
                guard let data = data else {
                    return
                }
                self?.counter += 1
                self?.text = "x: \(data.acceleration.x.toStringFromated(3)) , Y: \(data.acceleration.y.toStringFromated(3)) , Z: \(data.acceleration.z.toStringFromated(3))"
                self?.textView.text = self?.text
                self?.counterText.text = "Counted Updates: \(self?.counter ?? 0)"
            }
        }
    }

}

extension Double {
    //MARK: - Using string interpolation
    func toStringFromated(_ numOfDecimal: Int) -> String {
        return String(format: "%.\(numOfDecimal)f", self)
    }
}
