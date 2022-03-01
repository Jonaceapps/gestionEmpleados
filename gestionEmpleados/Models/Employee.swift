//
//  Employee.swift
//  gestionEmpleados
//
//  Created by Jonathan Miguel onrubia on 28/2/22.
//

import Foundation

struct Employee : Codable {
    var id : Int?
    var nombre : String?
    var email : String?
    var pass : String?
    var puesto_trabajo : String?
    var salario : Float?
    var biografia : String?
    var imagen : String?
}
