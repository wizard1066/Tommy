//
//  connect.swift
//  Tommy
//
//  Created by localadmin on 20.01.20.
//  Copyright © 2020 Mark Lucking. All rights reserved.
//

import UIKit
import Network

protocol speaker {
  func speak(_ comm:String)
  func paras(_ inX:String, outX:String)
  func running(_ service:String)
}

class Connect: NSObject {

  private var connection: NWConnection?
  private var listen: NWListener?
  private var spoken: speaker?
  private var localEndPoint: String?
  private var remoteEndPoint: String?
  
  func listenUDP(port: NWEndpoint.Port) {
    do {
      self.listen = try NWListener(using: .udp, on: port )
      self.listen?.stateUpdateHandler = {(newState) in
        switch newState {
        case .ready:
          print("Server ready...")
          self.spoken?.running("Listen")
        case .failed(let error):
          print("Failed Server failure, error: \(error.localizedDescription)")
          exit(EXIT_FAILURE)
        case .waiting(let error):
          print("Waiting Server failure, error: \(error.localizedDescription)")
        default:
          print("No idea")
        }
      }
      
      self.listen?.newConnectionHandler = {(newConnection) in
        newConnection.stateUpdateHandler = {newState in
          switch newState {
          case .ready:
            self.localEndPoint = (newConnection.currentPath?.localEndpoint!.debugDescription)!
            self.remoteEndPoint = (newConnection.currentPath?.remoteEndpoint!.debugDescription)!
            self.spoken?.paras(self.localEndPoint!, outX: self.remoteEndPoint!)
            self.receive(on: newConnection)
          case .failed(let error):
            print("client failed with error: \(error)")
          case .cancelled:
            print("Cancelled connection")
          default:
            break
          }
        }
        newConnection.start(queue: DispatchQueue(label: "new client"))
      }
    } catch {
      print("not listening")
    }
    self.listen?.start(queue: .main)
  }
  
  func stopListening() {
    self.listen?.cancel()
  }
  
  func receive(on connection: NWConnection) {
    
    connection.receiveMessage { (data, context, isComplete, error) in
      if let error = error {
        print(error)
        return
      }
      if let data = data, !data.isEmpty {
        let backToString = String(decoding: data, as: UTF8.self)
        self.spoken?.speak(backToString)
      }
      connection.send(content: "ok".data(using: .utf8), completion: .contentProcessed({error in
        if let error = error {
          print("error while sending data: \(error)")
          return
        }
      }))
      self.receive(on: connection)
    }
  }
  
  private var portX: NWEndpoint.Port?
  private var hostX: NWEndpoint.Host?
  
  func reconnect() {
    if hostX == nil || portX == nil { return }
    connectToUDP(hostUDP:hostX!,portUDP:portX!)
  }

  func returnEndPoints() -> (String?,String?) {
    return (localEndPoint,remoteEndPoint)
  }

  func connectToUDP(hostUDP:NWEndpoint.Host,portUDP:NWEndpoint.Port) {
    hostX = hostUDP
    portX = portUDP
    
    self.connection?.viabilityUpdateHandler = { (isViable) in
      if (!isViable) {
      
        print("connection viable")
        // display error
      } else {
        print("no connection")
        return
        // display ok
      }
    }
    
    self.connection = NWConnection(host: hostUDP, port: portUDP, using: .udp)
    self.connection?.stateUpdateHandler = { (newState) in
      
      switch (newState) {
      case .ready:
        self.spoken?.running("Connect")
        self.localEndPoint = (self.connection?.currentPath?.localEndpoint!.debugDescription)!
        self.sendUDP("foobar")
      case .setup:
        print("State: Setup\n")
      case .cancelled:
        print("State: Cancelled\n")
      case .preparing:
        print("State: Preparing\n")
      case .failed(_):
        print("Failed")
      default:
        print("ERROR! State not defined!\n")
      }
    }
    
    self.connection?.betterPathUpdateHandler = { (betterPathAvailable) in
      if (betterPathAvailable) {
        // code
      } else {
        // code
      }
    }
    //    self.connection?.start(queue: .global())
    self.connection?.start(queue: .main)
    
  }
  
 var connectedStatus: Bool {
  guard let connect = self.connection?.state else { return false }
  if connect == .preparing || connect == .ready {
    return true
  } else {
    return false
  }
 }
  
  func disconnectUDP() {
    self.connection?.cancel()
  }
  
  func sendUDP(_ content: Data) {
    self.connection?.send(content: content, completion: NWConnection.SendCompletion.contentProcessed(({ (NWError) in
      if (NWError == nil) {
        
//        print("Data was sent to UDP")
//        self.receiveUDPV2()
      } else {
        print("ERROR! Error when data (Type: Data) sending. NWError: \n \(NWError!) ")
      }
    })))
  }
  
  func sendUDP(_ content: String) {

      
      let contentToSendUDP = content.data(using: String.Encoding.utf8)
      self.connection?.send(content: contentToSendUDP, completion: NWConnection.SendCompletion.contentProcessed(({ (NWError) in
        if (NWError == nil) {
          // code
        } else {
          print("ERROR! Error when data (Type: String) sending. NWError: \n \(NWError!) ")
        }
      })))

  }
  
  func receiveUDP() {
    self.connection?.receive(minimumIncompleteLength: 1, maximumLength: 65536, completion: { (data, context, isComplete, error) in
      if let data = data, !data.isEmpty {
        print("did receive \(data.count) bytes")
      }
    })
  }
  
  func receiveUDPV2() {
    self.connection?.receiveMessage { (data, context, isComplete, error) in
      if (isComplete) {
        
        if (data != nil) {
          let backToString = String(decoding: data!, as: UTF8.self)
          print("recieved ",backToString)
        } else {
          print("Data == nil")
        }
      }
    }
  }
  
}
