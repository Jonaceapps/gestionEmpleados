//
//  Response.swift
//  gestionEmpleados
//
//  Created by Jonathan Miguel onrubia on 5/2/22.
//

import Foundation

struct Response: Codable {
    var status : Int
    var msg : String
    var api_token : String?
    var listado_empleados : [Employee]?
    var datos_perfil : Employee?

}


