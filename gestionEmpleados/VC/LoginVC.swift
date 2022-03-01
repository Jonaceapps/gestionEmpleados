//
//  LoginVC.swift
//  gestionEmpleados
//
//  Created by Jonathan Miguel onrubia on 5/2/22.
//

import UIKit

class LoginVC: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var indicatorView: UIView!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var showHidePassButton: UIButton!
    var params:[String: Any]?
    var response: Response?
    let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailTextField.delegate = self
        passwordTextField.delegate = self
        indicatorView.isHidden = true
    }
    
    //Para ocultar el teclado
    @objc func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            view.endEditing(true)
    }
    
    //Boton de login presionado
    @IBAction func loginButtonTapped(_ sender: Any) {
        indicatorView.isHidden = false
        params = [
            "email" : emailTextField.text ?? "",
            "pass"  : passwordTextField.text ?? ""
        ]
        
        if !emailTextField.text!.isEmpty || !passwordTextField.text!.isEmpty {
            
            NetworkManager.shared.login(params: params){
                response, error in DispatchQueue.main.async {
                    self.indicatorView.isHidden = true
                    self.response = response
                    
                    if response?.status == 1 {
                        Session.shared.api_token = response?.api_token
                        Session.shared.puestoTrabajo = response?.datos_perfil?.puesto_trabajo
                        Session.shared.id = response?.datos_perfil?.id
        
                        let mainTabBarController = self.storyboard!.instantiateViewController(identifier: "MainTabBarController")
                        mainTabBarController.modalPresentationStyle = .fullScreen
                        self.present(mainTabBarController, animated: true, completion: nil)
                    
                    } else if response?.status == 0 {
                        //Si ha fallado algo al editar algun dato el servidor nos devolvera el fallo aqui y se mostrara en un alert.
                        self.displayAlert(title: "Error", message: "\(response?.msg ?? "Se ha producido un error")")
                        
                    } else if error == .badData || error == .errorConnection {
                        self.displayAlert(title: "Error", message: "Ha habido un error, vuelve a intentarlo mas tarde.")
                        
                    } else {
                        //Si las credenciales no son correctas o hay algun otro tipo de error se mostrara un alert.
                        self.displayAlert(title: "Error", message: "Ha habido un error, vuelve a intentarlo mas tarde.")
                    }
                }
            }
        } else {
            self.indicatorView.isHidden = true
            self.displayAlert(title: "Error", message: "Rellena los campos vacios.")
        }
        
    }
    //Boton de he olvidado mi contraseña, llevara al usaurio a una vista donde introduciendo su email podra recuperar su contraseña
    @IBAction func forgotPasswordTapped(_ sender: Any) {
        if let forgotVC = storyboard?.instantiateViewController(identifier: "ForgotVC") as? RecoverPasswordVC {
        forgotVC.modalPresentationStyle = .fullScreen
        forgotVC.modalTransitionStyle = .crossDissolve
        self.present(forgotVC, animated: true, completion: nil)
        }
    }
    
    @IBAction func ShowHidePassButtonTapped(_ sender: Any) {
        showHidePassButton.isSelected = !showHidePassButton.isSelected
        passwordTextField.isSecureTextEntry.toggle()
    }
    
    func displayAlert(title: String, message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
