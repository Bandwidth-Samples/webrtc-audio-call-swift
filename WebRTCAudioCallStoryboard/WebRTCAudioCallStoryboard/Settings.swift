//
//  Settings.swift
//  WebRTCAudioCallStoryboard
//
//  Created by Michael Hamer on 1/21/21.
//

import Foundation

class Settings {
    static let `default` = Settings()

    /// Address contains the path to your application server.
    var address: String = {
        guard let path = Bundle.main.path(forResource: "Config", ofType: "plist"), let data = try? Data(contentsOf: URL(fileURLWithPath: path)) else {
            fatalError("Failed to load configuration property list. Did you create a Config.plist file?")
        }
        
        guard let configuration = try? PropertyListSerialization.propertyList(from: data, options: .mutableContainers, format: nil) as? [String: String] else {
            fatalError("Failed to load configuration data.")
        }
        
        guard let address = configuration["Address"] else {
            fatalError("Failed to load address. Did you add an Address key with your application server address?")
        }
        
        return address
    }()
    
    private init() {

    }
}
