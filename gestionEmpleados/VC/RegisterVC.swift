//
//  RegisterVC.swift
//  gestionEmpleados
//
//  Created by Jonathan Miguel onrubia on 5/2/22.
//

import UIKit

class RegisterVC: UIViewController, UITextFieldDelegate, UITextViewDelegate {
    
    enum PuestosTrabajo : Int {
        case empleado = 0, RRHH, direccion
    }
    
    var params: [String: Any]?
    var response : Response?
    var puestoTrabajo : String?
    var emplado : PuestosTrabajo = .empleado
    var rrhh : PuestosTrabajo = .RRHH
    var direccion : PuestosTrabajo = .direccion
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var salaryTextField: UITextField!
    @IBOutlet weak var biographyTextView: UITextView!
    @IBOutlet weak var jobSegmentedControl: UISegmentedControl!
    @IBOutlet weak var showHidePassBtn: UIButton!
    @IBOutlet weak var showHidePassBtn2: UIButton!
    @IBOutlet weak var noPermissionsView: UIView!
    @IBOutlet weak var indicatorView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nameTextField.delegate = self
        emailTextField.delegate = self
        passwordTextField.delegate = self
        confirmPasswordTextField.delegate = self
        salaryTextField.delegate = self
        biographyTextView.delegate = self
        biographyTextView.layer.cornerRadius = 5
        indicatorView.isHidden = true
        
        checkPermissions()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        checkPermissions()
    }
  
    
    func checkPermissions(){
        if Session.shared.puestoTrabajo == "Empleado" {
            noPermissionsView.isHidden = false
        } else {
            noPermissionsView.isHidden = true
        }
    }
   
    func puestoSeleccionado () -> String{
        
        switch jobSegmentedControl.selectedSegmentIndex {
        case emplado.rawValue:
            puestoTrabajo = "Empleado"
        case rrhh.rawValue:
            puestoTrabajo = "RRHH"
        case direccion.rawValue:
            puestoTrabajo = "Direccion"
        default:
            puestoTrabajo = "Empleado"
        }
        return puestoTrabajo ?? "Empleado"
    }
    
    @IBAction func registerButtonTapped(_ sender: Any) {
        
        indicatorView.isHidden = false
        params = [
            "nombre" : nameTextField.text ?? "",
            "email" : emailTextField.text ?? "",
            "pass" : passwordTextField.text ?? "",
            "puesto_trabajo" : puestoSeleccionado(),
            "salario" : salaryTextField.text ?? "",
            "biografia" : biographyTextView.text ?? ""
        ]
        //Aqui comparo la contraseña con la confirmacion, si no coinciden saldra un error. El resto de comprobaciones las hace la api y si algun campo falta por relenarse se indicara mediante el response.msg en un alert.
        if passwordTextField.text == confirmPasswordTextField.text {
            
            NetworkManager.shared.registerUser(apiToken: Session.shared.api_token! ,params: params){
                response, error  in DispatchQueue.main.async {
                    self.indicatorView.isHidden = true
                    self.response = response
                    
                    if response?.status == 1 {
                        self.resetTextFields()
                        self.displayAlert(title: "Registro completado", message: "\(response?.msg ?? "Todo OK")")
                        
                    } else if response?.status == 0 {
                        self.displayAlert(title: "Error", message: "\(response?.msg ?? "Ha ocurrido un error, es posible que no tengas permiso para registrar usuarios.")")
                        
                    } else if error == .badData || error == .errorConnection {
                        self.displayAlert(title: "Error", message: "Ha habido un error, intentalo mas tarde.")
                        
                    } else {
                        self.displayAlert(title: "Error", message: "Ha habido un error, intentalo mas tarde.")
                    }
                }
            }
        } else {
            self.indicatorView.isHidden = true
            self.displayAlert(title: "Error", message: "Las contraseñas no coinciden.")
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        textView.textColor = .black
        if textView.text == "Biografia" {
            textView.text = ""
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty{
            textView.text = "Biografia"
            textView.textColor = .tertiaryLabel
        }
    }
    
    
    func resetTextFields(){
        nameTextField.becomeFirstResponder()
        nameTextField.resignFirstResponder()
        nameTextField.text = ""
        emailTextField.text = ""
        passwordTextField.text = ""
        confirmPasswordTextField.text = ""
        salaryTextField.text = ""
        biographyTextView.text = ""
    }
    
    @IBAction func showHidePassTapped(_ sender: Any) {
        showHidePassBtn.isSelected = !showHidePassBtn.isSelected
        passwordTextField.isSecureTextEntry.toggle()
    }
    
    @IBAction func showHidePassTapped2(_ sender: Any) {
        showHidePassBtn2.isSelected = !showHidePassBtn2.isSelected
        confirmPasswordTextField.isSecureTextEntry.toggle()
    }
    
    //Para ocultar el teclado.
    @objc func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            view.endEditing(true)
    }
    
    func displayAlert(title: String, message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
