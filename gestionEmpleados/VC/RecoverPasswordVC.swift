//
//  ForgotPasswordVC.swift
//  gestionEmpleados
//
//  Created by Jonathan Miguel onrubia on 6/2/22.
//

import UIKit

class RecoverPasswordVC: UIViewController, UITextFieldDelegate {
    
  
    @IBOutlet weak var indicatorView: UIView!
    @IBOutlet weak var emailTextField: UITextField!
    var response : Response?
    var params: [String: Any]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailTextField.delegate = self
        indicatorView.isHidden = true

    }
 
    //Cuando el usaurio pulsa el boton de enviar email de recuperacion de contraseña.
    @IBAction func sendButtonTapped(_ sender: UIButton) {
        indicatorView.isHidden = false
        params = [
            "email" : emailTextField.text ?? ""
        ]
        
        if !emailTextField.text!.isEmpty && emailTextField.text != nil {
            
            NetworkManager.shared.recoverPassword(params: params){
                response, error in DispatchQueue.main.async {
                    self.indicatorView.isHidden = true
                    self.response = response
                    
                    if response?.status == 1 {
                        self.displayAlert(title: "Email enviado", message: "\(response?.msg ?? "Email enviado")")
                        
                    } else if response?.status == 0 {
                        //Si ha fallado algo al editar algun dato el servidor nos devolvera el fallo aqui y se mostrara en un alert.
                        self.displayAlert(title: "Error", message: "\(response?.msg ?? "Se ha producido un error")")
                        
                    } else if error == .errorConnection || error == .badData {
                        self.displayAlert(title: "Error", message: "Se ha producido un error, vuelve a intentarlo mas tarde.")
                        
                    } else {
                        self.displayAlert(title: "Error", message: "Se ha producido un error, vuelve a intentarlo mas tarde.")
                    }
                }
            }
        } else {
            self.indicatorView.isHidden = true
            self.displayAlert(title: "Error", message: "El campo email no puede estar vacio")
        }
    }
    
    //Si el usaurio pulsa el boton de volver, ira al login.
    @IBAction func backToLoginTapped(_ sender: UIButton) {
        if let loginVC = storyboard?.instantiateViewController(identifier: "LoginVC") as? LoginVC {
        loginVC.modalPresentationStyle = .fullScreen
        loginVC.modalTransitionStyle = .crossDissolve
        self.present(loginVC, animated: true, completion: nil)
        }
    }
    
    //Para ocultar el teclado
    @objc func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            view.endEditing(true)
    }
    
    func displayAlert(title: String, message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
