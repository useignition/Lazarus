//
//  VPNManager.swift
//  Lazarus
//
//  Created by Ignition on 02/06/18.
//  Copyright © 2018 Fluid, LLC. All rights reserved.
//

import Foundation
import NetworkExtension


enum VPNStatus {
    case off
    case connecting
    case on
    case disconnecting
}


class VPNManager {
    static let shared = VPNManager()
    var observerAdded: Bool = false

    
    fileprivate(set) var vpnStatus = VPNStatus.off {
        didSet {
            NotificationCenter.default.post(name: Notification.Name(rawValue: kProxyServiceVPNStatusNotification), object: nil)
        }
    }
    
    init() {
        loadProviderManager{
            guard let manager = $0 else{return}
            self.updateVPNStatus(manager)
        }
        addVPNStatusObserver()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func addVPNStatusObserver() {
        guard !observerAdded else{
            return
        }
        loadProviderManager { [unowned self] (manager) -> Void in
            if let manager = manager {
                self.observerAdded = true
                NotificationCenter.default.addObserver(forName: NSNotification.Name.NEVPNStatusDidChange, object: manager.connection, queue: OperationQueue.main, using: { [unowned self] (notification) -> Void in
                    self.updateVPNStatus(manager)
                    })
            }
        }
    }
    
    
    func updateVPNStatus(_ manager: NEVPNManager) {
        switch manager.connection.status {
        case .connected:
            self.vpnStatus = .on
        case .connecting, .reasserting:
            self.vpnStatus = .connecting
        case .disconnecting:
            self.vpnStatus = .disconnecting
        case .disconnected, .invalid:
            self.vpnStatus = .off
        @unknown default:
            fatalError()
        }
        print(self.vpnStatus)
    }
}

extension VPNManager {

    
    fileprivate func createProviderManager() -> NETunnelProviderManager {
        let manager = NETunnelProviderManager()
        let conf = NETunnelProviderProtocol()
        let onDemandRuleConnect = NEOnDemandRuleConnect()
        onDemandRuleConnect.interfaceTypeMatch = .any
        manager.onDemandRules = [onDemandRuleConnect]
        manager.isOnDemandEnabled = true
        conf.serverAddress = "Lazarus"
        manager.protocolConfiguration = conf
        manager.localizedDescription = "Lazarus"
        return manager
    }
    
    
    func loadAndCreatePrividerManager(_ complete: @escaping (NETunnelProviderManager?) -> Void ){
        NETunnelProviderManager.loadAllFromPreferences{ (managers, error) in
            guard let managers = managers else{return}
            let manager: NETunnelProviderManager
            if managers.count > 0 {
                manager = managers[0]
                self.delDupConfig(managers)
            }else{
                manager = self.createProviderManager()
            }
            
            manager.isEnabled = true
            self.setRulerConfig(manager)
            manager.saveToPreferences{
                if $0 != nil{complete(nil);return;}
                manager.loadFromPreferences{
                    if $0 != nil{
                        print($0.debugDescription)
                        complete(nil);return;
                    }
                    self.addVPNStatusObserver()
                    complete(manager)
                }
            }
            
        }
    }
    
    func loadProviderManager(_ complete: @escaping (NETunnelProviderManager?) -> Void){
        NETunnelProviderManager.loadAllFromPreferences { (managers, error) in
            if let managers = managers {
                if managers.count > 0 {
                    let manager = managers[0]
                    complete(manager)
                    return
                }
            }
            complete(nil)
        }
    }
    
    
    func delDupConfig(_ arrays:[NETunnelProviderManager]){
        if (arrays.count)>1{
            for i in 0 ..< arrays.count{
                print("Del DUP Profiles")
                arrays[i].removeFromPreferences(completionHandler: { (error) in
                    if(error != nil){print(error.debugDescription)}
                })
            }
        }
    }
}

extension VPNManager {
    func connect(){
        self.loadAndCreatePrividerManager { (manager) in
            guard let manager = manager else{return}
            do{
                try manager.connection.startVPNTunnel(options: [:])
            }catch let err{
                print(err)
            }
        }
    }
    
    func disconnect(){
        loadProviderManager{$0?.connection.stopVPNTunnel()}
    }
}

extension VPNManager {
    fileprivate func getRuleConf() -> String{
        let Path = Bundle.main.path(forResource: "VPN Rules", ofType: "conf")
        let Data = try? Foundation.Data(contentsOf: URL(fileURLWithPath: Path!))
        let str = String(data: Data!, encoding: String.Encoding.utf8)!
        return str
    }
    
    fileprivate func setRulerConfig(_ manager:NETunnelProviderManager){
        var conf = [String:AnyObject]()
        conf["ss_address"] = "0.0.0.0" as AnyObject?
        conf["ss_port"] = 1025 as AnyObject?
        conf["ss_method"] = "CHACHA20" as AnyObject?
        conf["ss_password"] = "LOL" as AnyObject?
        conf["ymal_conf"] = getRuleConf() as AnyObject?
        let orignConf = manager.protocolConfiguration as! NETunnelProviderProtocol
        orignConf.providerConfiguration = conf
        manager.protocolConfiguration = orignConf
    }
}
