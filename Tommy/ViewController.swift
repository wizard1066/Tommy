//
//  ViewController.swift
//  Tommy
//
//  Created by localadmin on 20.01.20.
//  Copyright © 2020 Mark Lucking. All rights reserved.
//

import UIKit
import Network

let portAddr = "49152"

class ViewController: UIViewController, speaker {

  func running(_ service: String) {
    switch service {
    case "Connect":
      DispatchQueue.main.async {
        self.connected.backgroundColor = .green
      }
    case "Listen":
      DispatchQueue.main.async {
        self.listening.backgroundColor = .green
      }
    default:
      break
    }
    
  }
  

  var communications:Connect?

  func speak(_ comm: String) {
    DispatchQueue.main.async {
      self.data.text = comm
    }
  }
  
  func paras(_ inX: String, outX: String) {
    DispatchQueue.main.async {
      self.inbound.text = inX
      self.outbound.text = outX
    }
  }
  
  @IBAction func Transmit(_ sender: UIButton) {
    communications?.sendUDP("Hello World")
  }
  
  @IBAction func connect(_ sender: UIButton) {
    if ipAddr != nil {
      let hostUDPx = NWEndpoint.Host.init(ipAddr.text!)
      let portUDPx = NWEndpoint.Port.init(portAddr)
      communications?.spoken = self
      communications?.connectToUDP(hostUDP: hostUDPx, portUDP: portUDPx!)
    }
  }
  
  @IBAction func listen(_ sender: UIButton) {
    let portUDPx = NWEndpoint.Port.init(portAddr)
    communications?.spoken = self
    communications?.listenUDP(port: portUDPx!)
  }
  
  @IBOutlet weak var inbound: UILabel!
  @IBOutlet weak var outbound: UILabel!
  @IBOutlet weak var data: UILabel!
  @IBOutlet weak var ipAddr: UITextField!
  @IBOutlet weak var listening: UIButton!
  @IBOutlet weak var connected: UIButton!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
    communications = Connect()
    communications?.spoken = self
    
    let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
    
    self.view.addGestureRecognizer(tap)
  }

   @objc func dismissKeyboard() {
          view.endEditing(true)
  }

}

