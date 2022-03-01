//
//  Session.swift
//  gestionEmpleados
//
//  Created by Jonathan Miguel onrubia on 8/2/22.
//

import Foundation
import UIKit

final class Session : Codable {
    
    static let shared = Session()
    private init(){
        if let data = UserDefaults.standard.object(forKey: "sessionKey") as? Data {
            if let savedSession = try? PropertyListDecoder().decode(Session.self, from: data){
                api_token = savedSession.api_token
                puestoTrabajo = savedSession.puestoTrabajo
                id = savedSession.id
            }
        }
    }
    
    var id : Int?
    var api_token : String?
    var puestoTrabajo : String?
   
    
    static func save(){
        if let data = try? PropertyListEncoder().encode(shared){
            UserDefaults.standard.set(data, forKey: "sessionKey")
        }
    }
    
    static func clean(){
        UserDefaults.standard.removeObject(forKey: "sessionKey")
        shared.api_token = nil
        shared.puestoTrabajo = nil
        shared.id = nil
    }
    
    
}
