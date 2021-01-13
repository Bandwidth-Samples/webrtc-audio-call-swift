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
    
    private let address = "http://localhost:3000"
    
    private var webRTC = WebRTC()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        webRTC.delegate = self
    }

    @IBAction func connect(_ sender: Any) {
        // Grab the Bandwidth provided token from your hosted server application.
        getToken { token in
            do {
                try self.webRTC.connect(using: token) {
                    print("Connected to Bandwidth's WebRTC server.")
                    
                    self.webRTC.publish(audio: true, video: false) {
                        self.statusLabel.text = "Online, no call"
                        self.callButton.isEnabled = true
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

        guard let url = URL(string: "\(address)/startBrowserCall") else {
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
        
        guard let url = URL(string: "\(address)/startPSTNCall") else {
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
        
        guard let url = URL(string: "\(address)/endPSTNCall") else {
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
}

extension ViewController: WebRTCDelegate {
    func webRTC(_ webRTC: WebRTC, didChangePeerConnectionState state: PeerConnectionState?, with error: WebRTCError?) {
        if let state = state {
            print("Peer connection state: \(state)")
        } else if let error = error {
            print(error.localizedDescription)
        }
    }
    
    func webRTC(_ webRTC: WebRTC, didReceiveRemoteSDP sdp: RTCSessionDescription) {
        
    }
    
    func webRTC(_ webRTC: WebRTC, didReceiveRemoteICECandidate candidate: RTCIceCandidate) {
        
    }
}
