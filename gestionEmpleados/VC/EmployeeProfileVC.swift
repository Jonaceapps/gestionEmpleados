//
//  EmployeeProfileVC.swift
//  gestionEmpleados
//
//  Created by Jonathan Miguel onrubia on 5/2/22.
//

import UIKit
import Photos

class EmployeeProfileVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var employeeData : Response?
    var response : Response?
    var params : [String : Any]?
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var biographyTextView: UITextView!
    @IBOutlet weak var jobTextField: UITextField!
    @IBOutlet weak var salaryTextField: UITextField!
    @IBOutlet weak var imageProfile: UIImageView!
    @IBOutlet weak var indicatorView: UIView!
    @IBOutlet weak var editProfileButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageProfile.image = nil
        usernameTextField.text = nil
        emailTextField.text = nil
        biographyTextView.text = nil
        salaryTextField.text = nil
        jobTextField.text = nil
        editProfileButton.layer.cornerRadius = 8
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadProfileData), name: Notification.Name("reloadProfileData"), object: nil)
        
        checkPermissions() //Si el usuario no tiene permisos para editar su perfil se deshabilitara el boton de editar perfil.
        loadProfileData() //Funcion para cargar los datos del usuario.
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //En caso de error de conexion, al ir  a otra vista y volver tratara de recargar los datos.
        checkPermissions()
        loadProfileData()
    }
    
    @objc func reloadProfileData (notification: NSNotification){
        //Esta funcion sirve para recargar los datos del usaurio desde la vista de editar cuando el usaurio guarde los cambios.
        self.indicatorView.isHidden = false
        loadProfileData()
    }
    
    func checkPermissions(){
        if Session.shared.puestoTrabajo != "Direccion" {
            editProfileButton.isEnabled = false
        }
    }
    
    func loadProfileData(){
        
        NetworkManager.shared.getEmployeeProfile(apiToken: Session.shared.api_token!){
            response , errors in DispatchQueue.main.async{
                self.employeeData = response
                
                if response?.status == 1 {
                    
                    self.usernameTextField.text = response?.datos_perfil?.nombre?.capitalized ?? "Jonathan Miguel"
                    self.jobTextField.text = response?.datos_perfil?.puesto_trabajo ?? "Default"
                    self.emailTextField.text = response?.datos_perfil?.email ?? "jonacedev@gmail.com"
                    self.biographyTextView.text = response?.datos_perfil?.biografia ?? "Biografia por defecto"
                    self.salaryTextField.text = "\(response?.datos_perfil?.salario ?? 0)$"
                    
                    Session.shared.puestoTrabajo = response?.datos_perfil?.puesto_trabajo ?? ""
                    self.checkPermissions()
                    
                    //Cargar Imagen de perfil.
                    NetworkManager.shared.getImageFrom(imageUrl: response?.datos_perfil?.imagen ?? ""){
                        image in DispatchQueue.main.async {
                            if let image = image {
                                self.imageProfile.image = image
                                self.imageProfile.layer.cornerRadius = self.imageProfile.bounds.size.width / 2.0
                                self.indicatorView.isHidden = true
                            } else {
                                //Si el usuario no tiene imagen de perfil se le asignara una por defecto.
                                self.imageProfile.image = UIImage(named: "perfil")!
                                self.indicatorView.isHidden = true
                            }
                        }
                    }
                    
                } else if response?.status == 0 {
                    self.indicatorView.isHidden = true
                    self.displayAlert(title: "Error", message: "\(response?.msg ?? "Se ha producido un error, intentalo mas tarde.")")
                    
                } else if errors == .badData || errors == .errorConnection {
                    self.indicatorView.isHidden = true
                    self.displayAlert(title: "Error", message: "Ha habido un error, vuelve a intentarlo mas tarde.")
                    
                } else {
                    self.indicatorView.isHidden = true
                    self.displayAlert(title: "Error", message: "Ha habido un error, vuelve a intentarlo mas tarde.")
                }
            }
        }
    }
    
    @IBAction func editButtonTapped(_ sender: Any) {
        if let detailModalView = storyboard?.instantiateViewController(identifier: "EditProfileVC") as? EditProfileVC {
            detailModalView.modalTransitionStyle = UIModalTransitionStyle.coverVertical
            detailModalView.modalPresentationStyle = .overFullScreen
            if let datos = self.employeeData {
                detailModalView.employeeData = datos
            }
            self.present(detailModalView, animated: true, completion: nil)
        }
        
    }
    //Al pulsar boton de cerrar sesion el usuario volvera al login y se eliminara el api_token.
    @IBAction func logOutButton(_ sender: Any) {
        if let loginVC = storyboard?.instantiateViewController(withIdentifier: "LoginVC") as? LoginVC {
            Session.clean()
            loginVC.modalPresentationStyle = .fullScreen
            loginVC.modalTransitionStyle = .crossDissolve
            self.present(loginVC, animated: true, completion: nil)
        }
    }
    
    @objc func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            view.endEditing(true)
    }
    
    func displayAlert(title: String, message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
}
