//
//  EmployeeDetailVC.swift
//  gestionEmpleados
//
//  Created by Jonathan Miguel onrubia on 5/2/22.
//

import UIKit
import Photos

class EmployeeDetailVC: UIViewController,UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, UITextViewDelegate {

    @IBOutlet weak var indicatorView: UIView!
    @IBOutlet weak var employeeNameTextField: UITextField!
    @IBOutlet weak var employeeBiographyTV: UITextView!
    @IBOutlet weak var jobTextField: UITextField!
    @IBOutlet weak var salaryTextField: UITextField!
    @IBOutlet weak var employeeImage: UIImageView!
    
    var response : Response?
    var employee : Employee?
    var params: [String: Any]?
    var imageToChange : UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        employeeImage.image = nil
        employeeNameTextField.delegate = self
        employeeBiographyTV.delegate = self
        jobTextField.delegate = self
        salaryTextField.delegate = self
        indicatorView.isHidden = true
        employeeBiographyTV.layer.cornerRadius = 5
        self.employeeImage.layer.cornerRadius = self.employeeImage.bounds.size.width / 2.0
        
        //Pintar los datos del usuario seleccionado:
        employeeNameTextField.text = employee?.nombre?.capitalized
        employeeBiographyTV.text = employee?.biografia
        jobTextField.text = employee?.puesto_trabajo
        salaryTextField.text = "\(employee?.salario ?? 0)$"
        
        NetworkManager.shared.getImageFrom(imageUrl: employee?.imagen ?? ""){
            image in DispatchQueue.main.async {
                if let image = image {
                    self.employeeImage.image = image
                } else {
                    //Si el usuario del cual obtenemos los datos no tiene imagen de perfil en la base de datos se le asignara na por defecto.
                    self.employeeImage.image = UIImage(named: "perfil")!
                }
            }
        }
    }
    
    //Guardar cambios realizados a un empleado.
    @IBAction func saveChangesButtonTapped(_ sender: Any) {
        indicatorView.isHidden = false
                
        params = [
            "nombre" : employeeNameTextField.text ?? "",
            "puesto_trabajo" : jobTextField.text ?? "",
            "salario" : salaryTextField.text!.replacingOccurrences(of: "$", with: ""),
            "biografia" : employeeBiographyTV.text ?? ""
        ]
        
        if (!employeeNameTextField.text!.isEmpty && !jobTextField.text!.isEmpty && !salaryTextField.text!.isEmpty && !employeeBiographyTV.text!.isEmpty){
            
            NetworkManager.shared.editUserData(id: String(employee?.id ?? 0), apiToken: Session.shared.api_token!, params: params!){
                response, errors in DispatchQueue.main.async {
                    self.indicatorView.isHidden = true
                    self.response = response
                    
                    if response?.status == 1 {
                        //Si el usuario ha editado su foto de perfil pues la subiremos aqui.
                        if let imageChanged = self.imageToChange {
                            self.uploadProfileImage(imageToUpload: imageChanged)
                        } else {
                            self.indicatorView.isHidden = true
                            self.displayAlert(title: "Cambios realizados", message: "Se han realizado los cambios correctamente")
                        }
                     
                    } else if response?.status == 0 {
                        //Si ha fallado algo al editar algun dato el servidor nos devolvera el fallo aqui y se mostrara en un alert.
                        self.displayAlert(title: "Error", message: "\(response?.msg ?? "Se ha producido un error")")
                        
                    } else if errors == .badData || errors == .errorConnection {
                        self.displayAlert(title: "Error", message: "Ha habido un error, vuelve a intentarlo mas tarde.")
                        
                    } else {
                        self.displayAlert(title: "Error", message: "Ha habido un error, vuelve a intentarlo mas tarde.")
                    }
                }
            }
        } else {
            self.indicatorView.isHidden = true
            self.displayAlert(title: "Error", message: "Rellena los campos vacios")
        }    
    }
    
    //Funciones para cambiar la imagen de perfil y subirla al servidor.
    @IBAction func employeeImageTapped(_ sender: Any) {
        
        let ac = UIAlertController(title: "Añade una foto de perfil", message: "Selecciona una imagen desde:", preferredStyle: .actionSheet)
        let cameraBtn = UIAlertAction(title: "Camera", style: .default) { (_)  in
            self.checkCameraPermissions()
        }
        let galleryBtn = UIAlertAction(title: "Galeria", style: .default) { (_)  in
            self.checkPhotoLibraryPermissions()
        }
        let cancelBtn = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        ac.addAction(cameraBtn)
        ac.addAction(galleryBtn)
        ac.addAction(cancelBtn)
        self.present(ac, animated: true, completion: nil)
    }
    
    func checkCameraPermissions(){
        switch AVCaptureDevice.authorizationStatus(for: .video) {
            case .authorized:
                self.showImagePicker(selectedSource: .camera)
            case .notDetermined:
                AVCaptureDevice.requestAccess(for: .video) { granted in
                        if granted {
                            self.showImagePicker(selectedSource: .camera)
                        }
                    }
            case .denied:
                displayAlert(title: "Permisos", message: "Los permisos para acceder a la camara han sido denegados, puedes cambiarlos desde ajustes.")
            case .restricted:
                displayAlert(title: "Permisos", message: "Los permisos para acceder a la camara han sido restringidos, puedes cambiarlos desde ajustes.")
        @unknown default:
                displayAlert(title: "Permisos", message: "Ha habido un error")
        }
    }
    
    func checkPhotoLibraryPermissions(){
        switch PHPhotoLibrary.authorizationStatus(for: .readWrite){
            case .authorized:
                self.showImagePicker(selectedSource: .photoLibrary)
            case .notDetermined:
                PHPhotoLibrary.requestAuthorization { status in
                    if status == .authorized {
                        self.showImagePicker(selectedSource: .photoLibrary)
                    }
                }
            case .denied:
                displayAlert(title: "Permisos", message: "Los permisos para acceder a la galeria han sido denegados, puedes cambiarlos desde ajustes.")
            case .restricted:
                displayAlert(title: "Permisos", message: "Los permisos para acceder a la galeria han sido restringidos, puedes cambiarlos desde ajustes.")
            case .limited:
                displayAlert(title: "Permisos", message: "Los permisos para acceder a la galeria estan limitados, puedes cambiarlos desde ajustes.")
            @unknown default:
                displayAlert(title: "Permisos", message: "Ha habido un error")
            }
    }
    
    func showImagePicker(selectedSource: UIImagePickerController.SourceType){
        guard UIImagePickerController.isSourceTypeAvailable(selectedSource) else {
            self.displayAlert(title: "Error", message: "El medio seleccionado no esta disponible, intentalo mas tarde.")
            return
        }
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = selectedSource
        imagePickerController.allowsEditing = true
        self.present(imagePickerController, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        //Se mostrara la imagen como preview y se almacenara en una variable, pero no se guardara hasta que el usuario guarde los cambios.
        if let selectedImage = info[.editedImage] as? UIImage{
            employeeImage.image = selectedImage
            imageToChange = selectedImage //Aqui almacenamos la imagen para subirla si el usuario guarda los cambios.
        
        } else if let selectedImage = info[.originalImage] as? UIImage {
            employeeImage.image = selectedImage
            imageToChange = selectedImage //Aqui almacenamos la imagen para subirla si el usuario guarda los cambios.
            
        } else {
            self.displayAlert(title: "Error", message: "Ha habido un error")
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    //Solo se llama a esta funcion cuando el usuario pulsa el boton de guardar cambios.
    func uploadProfileImage(imageToUpload : UIImage){
       
        let imageStringData = convertImageToBase64(image: imageToUpload)
        params = [
            "image" : imageStringData,
        ]
        
        NetworkManager.shared.uploadEmployeeImage(id: String((employee?.id)!) ,apiToken: Session.shared.api_token!, params: params){
            response, errors in DispatchQueue.main.async {
                self.indicatorView.isHidden = true
                self.response = response
                
                if response?.status == 1 {
                    self.displayAlert(title: "Cambios realizados", message: "Se han realizado los cambios correctamente")
                } else if response?.status == 0 {
                    //Si hay algun fallo a la hora de subir la imagen se le mostrara al usuario mediante un alert.
                    self.displayAlert(title: "Error", message: "\(response?.msg ?? "Se ha producido un error al subir la imagen.")")
                    
                } else if errors == .badData || errors == .errorConnection {
                    self.displayAlert(title: "Error", message: "Ha habido un error, intentalo mas tarde")
                    
                } else {
                    self.displayAlert(title: "Error", message: "Ha habido un error, intentalo mas tarde")
                }
            }
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    //Funcion para convertir imagen a base64 con el fin de enviarlo posteriormente al servidor donde se almacenara.
    func convertImageToBase64(image: UIImage) -> String {
            let imageData = image.jpegData(compressionQuality: 0.6)!
            return imageData.base64EncodedString(options: Data.Base64EncodingOptions.lineLength64Characters)
    }
    
    //Funcion para ocultar el teclado.
    @objc func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            view.endEditing(true)
    }
    
    func displayAlert(title: String, message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

}
