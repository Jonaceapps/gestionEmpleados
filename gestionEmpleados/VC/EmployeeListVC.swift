//
//  EmployeeListVC.swift
//  gestionEmpleados
//
//  Created by Jonathan Miguel onrubia on 5/2/22.
//

import UIKit

class EmployeeListVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var employeeTableView: UITableView!
    @IBOutlet weak var noPermisionsView: UIView!
    @IBOutlet weak var labelNoPermisionsView: UILabel!
    @IBOutlet weak var indicatorView: UIView!
    var listado : Response?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkApiToken()
        labelNoPermisionsView.text = nil
        employeeTableView.delegate = self
        employeeTableView.dataSource = self

        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)
        employeeTableView.refreshControl = refreshControl
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if Session.shared.puestoTrabajo == "Empleado" {
            hideList(textToShow: "No tienes los permisos necesarios para ver el listado de empleados.")
        }
    }
    
    func checkApiToken(){
        if Session.shared.api_token != nil {
            //Si el apitoken no es nulo significa que el usuario esta logueado y cargamos los datos del listado que se mostraran solo si el usuario tiene los permisos.
            loadData()
        } else {
            //Si el api token es nulo por que no se ha iniciado sesion o se ha cerrado sesion, iremos a la vista login.
            if let loginVC = storyboard?.instantiateViewController(identifier: "LoginVC") as? LoginVC {
            loginVC.modalPresentationStyle = .fullScreen
            loginVC.modalTransitionStyle = .crossDissolve
            self.present(loginVC, animated: true, completion: nil)
            }
        }
    }
    
    func loadData(){
        
        self.indicatorView.isHidden = false
        NetworkManager.shared.getEmployeeList(apiToken: Session.shared.api_token!){
            response, error in DispatchQueue.main.async {
                self.listado = response

                if response?.status == 1 && response?.msg == "Listado obtenido"{
                    self.showList()
                } else if response?.status == 0 && Session.shared.puestoTrabajo == "Empleado" {
                    self.hideList(textToShow: "No tienes los permisos necesarios para ver el listado de empleados.")
                    self.indicatorView.isHidden = true
                } else if error == .badData {
                    self.displayAlert(title: "Error", message: "Ha habido un error, intentalo mas tarde.")
                    self.indicatorView.isHidden = true
                } else if error == .errorConnection {
                    self.displayAlert(title: "Error", message: "Ha ocurrido un error, intentalo mas tarde.")
                    self.indicatorView.isHidden = true
                }
            }
        }
    }
    
    func showList(){
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5){
            self.indicatorView.isHidden = true
        }
        self.employeeTableView.reloadData()
    }
    func hideList(textToShow: String){
        self.noPermisionsView.isHidden = false
        self.labelNoPermisionsView.text = textToShow
    }
    
    //Si el usuario hace pull en el table view se refrescara la vista haciendo otra vez la peticion de obtencion de datos y recargando la tabla.
    @objc func didPullToRefresh() {
        //comprobar
        indicatorView.isHidden = true
        loadData()
        DispatchQueue.main.async {
            self.employeeTableView.refreshControl?.endRefreshing()
        }
    }
    
    //Table view functions
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listado?.listado_empleados?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EmployeeCell", for: indexPath) as! EmployeeCell
        cell.employee = listado?.listado_empleados![indexPath.row]
        
        if cell.employee != nil {
            return cell
        } else {
            return UITableViewCell()
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if let detailEmployeeVC = self.storyboard?.instantiateViewController(identifier: "EmployeeDetailVC") as? EmployeeDetailVC {
            detailEmployeeVC.employee = listado?.listado_empleados?[indexPath.row]
            self.navigationController?.pushViewController(detailEmployeeVC, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Empleados"
    }
    
    func displayAlert(title: String, message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
        alert.addAction(UIAlertAction(title: "Intentarlo de nuevo", style: UIAlertAction.Style.default, handler: {(action) in self.loadData() }))
                                      
        self.present(alert, animated: true, completion: nil)
    }
}
