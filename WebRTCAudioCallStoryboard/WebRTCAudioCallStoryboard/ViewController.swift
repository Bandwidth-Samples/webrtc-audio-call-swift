//
//  ViewController.swift
//  WebRTCAudioCallStoryboard
//
//  Created by Michael Hamer on 1/11/21.
//

import UIKit
import BandwidthWebRTC
import WebRTC

class ViewController: UIViewController {
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var callButton: UIButton!
    @IBOutlet weak var endCallButton: UIButton!
    @IBOutlet weak var muteBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var connectBarButtonItem: UIBarButtonItem!
    
    private var mute = false
    
    private var bandwidth = RTCBandwidth()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        bandwidth.delegate = self
    }

    @IBAction func connect(_ sender: Any) {
        // Grab the Bandwidth provided token from your hosted server application.
        getToken { token in
            do {
                try self.bandwidth.connect(using: token) {
                    DispatchQueue.main.async {
                        self.connectBarButtonItem.title = "Disconnect"
                    }
                    
                    print("Connected to Bandwidth's WebRTC server.")
                    
                    self.bandwidth.publish(audio: true, video: false, alias: nil) {
                        DispatchQueue.main.async {
                            // Enable the mute button once we've started publishing.
                            self.muteBarButtonItem.isEnabled = true
                            
                            self.statusLabel.text = "Online, no call"
                            self.callButton.isEnabled = true
                        }
                    }
                }
            }
            catch {
                print(error.localizedDescription)
            }
        }
    }
    
    @IBAction func call(_ sender: Any) {
        callButton.isEnabled = false
        
        call {
            DispatchQueue.main.async {
                self.statusLabel.text = "Online, in call"
                self.endCallButton.isEnabled = true
            }
        }
    }

    @IBAction func endCall(_ sender: Any) {
        endCall {
            DispatchQueue.main.async {
                self.statusLabel.text = "Online, no call"
                self.callButton.isEnabled = true
                self.endCallButton.isEnabled = false
            }
        }
    }
    
    func getToken(completion: @escaping (String) -> Void) {
        print("Fetching media token from server application.")

        guard let url = URL(string: "\(Settings.default.address)/startBrowserCall") else {
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data {
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                        if let token = json["token"] as? String {
                            DispatchQueue.main.async {
                                completion(token)
                            }
                        }
                    }
                } catch {
                    print(error.localizedDescription)
                }
            } else if let error = error {
                print(error.localizedDescription)
            }
        }.resume()
    }
    
    func call(completion: @escaping () -> Void) {
        print("Starting PSTN call through server application.")
        
        guard let url = URL(string: "\(Settings.default.address)/startPSTNCall") else {
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print(error.localizedDescription)
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                return
            }
            
            guard httpResponse.statusCode == 200 else {
                print("Failed to set up participant: \(httpResponse.statusCode)")
                return
            }
            
            completion()
        }.resume()
    }
    
    func endCall(completion: @escaping () -> Void) {
        print("Ending PSTN call through server application.")
        
        guard let url = URL(string: "\(Settings.default.address)/endPSTNCall") else {
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print(error.localizedDescription)
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                return
            }
            
            guard httpResponse.statusCode == 200 else {
                print("Failed to end call: \(httpResponse.statusCode)")
                return
            }
            
            completion()
        }.resume()
    }
    
    @IBAction func mute(_ sender: Any) {
        // Toggle the local mute state.
        mute.toggle()
        
        // Toggle the title of the mute button to display to the user.
        muteBarButtonItem.title = mute ? "Unmute" : "Mute"
        
        // Set the audio of all local WebRTC connections.
        bandwidth.setAudio(isEnabled: !mute)
    }
}

extension ViewController: RTCBandwidthDelegate {
    func bandwidth(_ bandwidth: RTCBandwidth, streamAvailableAt endpointId: String, participantId: String, alias: String?, mediaTypes: [MediaType], mediaStream: RTCMediaStream?) {

    }
    
    func bandwidth(_ bandwidth: RTCBandwidth, streamUnavailableAt endpointId: String) {

    }
}
