//
//  EmployeeCell.swift
//  gestionEmpleados
//
//  Created by Jonathan Miguel onrubia on 9/2/22.
//

import UIKit

class EmployeeCell: UITableViewCell {
    @IBOutlet weak var employeeNameTF: UILabel!
    @IBOutlet weak var employeeJobTF: UILabel!
    @IBOutlet weak var employeeSalaryTF: UILabel!
    @IBOutlet weak var employeeImage: UIImageView!
    
    var employee: Employee? {
        didSet { renderUI() }
    }
    
    private func renderUI() {
        guard employee != nil else {return}
        employeeNameTF.text = employee?.nombre?.capitalized
        employeeJobTF.text = employee?.puesto_trabajo
        employeeSalaryTF.text = "\(employee?.salario ?? 0)$"
        
        NetworkManager.shared.getImageFrom(imageUrl: employee?.imagen ?? ""){
            image in DispatchQueue.main.async {
                if let image = image {
                    self.employeeImage.image = image
                    self.employeeImage.layer.cornerRadius = self.employeeImage.bounds.size.width / 2.0
                } else {
                    //Si el usuario del cual obtenemos los datos no tiene imagen de perfil en la base de datos se le asignara na por defecto.
                    self.employeeImage.image = UIImage(named: "perfil")!
                }
              
            }
        }
    }

}
