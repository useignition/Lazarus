//
//  ViewController.swift
//  Lazarus
//
//  Created by Ignition on 02/06/18.
//  Copyright © 2018 Fluid, LLC. All rights reserved.
//

import UIKit
import NetworkExtension


class ViewController: UIViewController {
    
    @IBOutlet var connectButton: UIButton!
    
//    @IBOutlet weak var statusLabel: UILabel!
    
    
    var status: VPNStatus {
        didSet(o) {
            updateConnectButton()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.status = .off
        super.init(coder: aDecoder)
        NotificationCenter.default.addObserver(self, selector: #selector(onVPNStatusChanged), name: NSNotification.Name(rawValue: kProxyServiceVPNStatusNotification), object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.status = VPNManager.shared.vpnStatus
    }
    
    @objc func onVPNStatusChanged(){
        self.status = VPNManager.shared.vpnStatus
    }
    
    func updateConnectButton(){
        switch status {
        case .connecting:
            connectButton.setTitle("Starting", for: UIControl.State())
        // statusLabel.text = "Starting"
        case .disconnecting:
            connectButton.setTitle("Disconnecting", for: UIControl.State())
        // statusLabel.text = "Disconnecting"
        case .on:
            connectButton.setTitle("Protecting", for: UIControl.State())
        // statusLabel.text = "Protecting"
        case .off:
            connectButton.setTitle("Start Protecting", for: UIControl.State())
            // statusLabel.text = "Start Protecting"
            
        }
        connectButton.isEnabled = [VPNStatus.on,VPNStatus.off].contains(VPNManager.shared.vpnStatus)
        
        
    }
    
    @IBAction func connectToLazarus(_ sender: AnyObject) {
        print("Connecting to Lazarus")
        if(VPNManager.shared.vpnStatus == .off){
            VPNManager.shared.connect()
        } else{
            // VPNManager.shared.disconnect()
        }
    }
    
    
}


