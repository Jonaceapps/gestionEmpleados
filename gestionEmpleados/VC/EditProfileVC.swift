//
//  EditProfileVC.swift
//  gestionEmpleados
//
//  Created by Jonathan Miguel onrubia on 26/2/22.
//

import UIKit
import Photos
import Network

class EditProfileVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, UITextViewDelegate  {
    
    enum PuestosTrabajo {
        case empleado, RRHH , direccion
        var value: (rawValue: Int, texto: String) {
                switch self {
                case .empleado:
                    return (0, "Empleado")
                case .RRHH:
                    return (1, "RRHH")
                case .direccion:
                    return (2, "Direccion")
                }
            }
    }
    
    var emplado : PuestosTrabajo = .empleado
    var rrhh : PuestosTrabajo = .RRHH
    var direccion : PuestosTrabajo = .direccion
    
    @IBOutlet weak var indicatorView: UIView!
    @IBOutlet weak var salaryTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var biographyTextView: UITextView!
    @IBOutlet weak var segmentedControlJob: UISegmentedControl!
    @IBOutlet weak var imageProfile: UIImageView!
    @IBOutlet weak var saveChangesButton: UIButton!
    
    let networkMonitor = NWPathMonitor()
    var response : Response?
    var employeeData : Response?
    var params : [String : Any]?
    var puestoTrabajo : String?
    var imageToChange : UIImage?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        indicatorView.isHidden = true
        salaryTextField.delegate = self
        usernameTextField.delegate = self
        biographyTextView.delegate = self
        biographyTextView.layer.cornerRadius = 5
        
        checkInternetConnection()
    }

    func checkInternetConnection(){
        networkMonitor.pathUpdateHandler = { path in
            if path.status == .satisfied {
                DispatchQueue.main.async {
                    if let _ = self.employeeData {
                        self.loadProfileData()
                        self.networkMonitor.cancel()
                    } else {
                        self.errorConnectionAlert(title: "Error", message: "No se han podido cargar los datos, intentalo mas tarde.")
                        self.networkMonitor.cancel()
                    }
                }

            } else {
                DispatchQueue.main.async {
                    self.noConnection()
                    self.networkMonitor.cancel()
                }
            }
        }
        let queue = DispatchQueue.global(qos: .background)
            networkMonitor.start(queue: queue)
    }
    
    func noConnection(){
            saveChangesButton.isEnabled = false
            indicatorView.isHidden = false
            errorConnectionAlert(title: "Error de conexion", message: "No se han podido cargar los datos, intentalo mas tarde.")
    }
    
    func loadProfileData(){
        
            usernameTextField.text = employeeData?.datos_perfil?.nombre?.capitalized ?? ""
            biographyTextView.text = employeeData?.datos_perfil?.biografia ?? ""
            salaryTextField.text = "\(employeeData?.datos_perfil?.salario ?? 0)$"
            segmentedControlJob.selectedSegmentIndex = obtenerIndexJob(puestoTrabajo: employeeData?.datos_perfil?.puesto_trabajo ?? "Empleado")
        
            //Cargar Imagen de perfil.
            NetworkManager.shared.getImageFrom(imageUrl: employeeData?.datos_perfil?.imagen ?? ""){
                image in DispatchQueue.main.async {
                    if let image = image {
                        self.imageProfile.image = image
                        self.imageProfile.layer.cornerRadius = self.imageProfile.bounds.size.width / 2.0
                    } else {
                        //Si el usuario no tiene imagen de perfil se le asignara una por defecto.
                        self.imageProfile.image = UIImage(named: "perfil")!
                    }
                }
            }
    }
    
    func obtenerIndexJob(puestoTrabajo : String) -> Int{
        
        switch puestoTrabajo {
        case emplado.value.texto:
            return 0
        case rrhh.value.texto:
            return 1
        case direccion.value.texto:
            return 2
        default:
            return 0
        }
    }
    
    func puestoSeleccionado () -> String{
        
        switch segmentedControlJob.selectedSegmentIndex {
        case emplado.value.rawValue:
            puestoTrabajo = "Empleado"
        case rrhh.value.rawValue:
            puestoTrabajo = "RRHH"
        case direccion.value.rawValue:
            puestoTrabajo = "Direccion"
        default:
            puestoTrabajo = "Empleado"
        }
        return puestoTrabajo ?? "Empleado"
    }
    
    //Boton de guardar cambios hechos en el perfil. Solo aparecera este boton si el usuario es directivo.
    @IBAction func saveChangesButtonTapped(_ sender: Any) {
        
        indicatorView.isHidden = false
        params = [
            "nombre" : usernameTextField.text ?? "",
            "puesto_trabajo" : puestoSeleccionado(),
            "salario" : salaryTextField.text!.replacingOccurrences(of: "$", with: ""),
            "biografia" : biographyTextView.text ?? ""
        ]
        
   
        if (!usernameTextField.text!.isEmpty || !biographyTextView.text!.isEmpty || !salaryTextField.text!.isEmpty){
            
            NetworkManager.shared.editUserData(id: String(Session.shared.id!), apiToken: Session.shared.api_token!, params: params!){
                response, errors in DispatchQueue.main.async {
                    self.response = response
                    
                    if response?.status == 1 {
                        //Si el usuario ha editado su foto de perfil la subiremos aqui, de lo contrario se volvera al perfil refescando los datos.
                        if let imageChanged = self.imageToChange {
                            self.uploadProfileImage(imageToUpload: imageChanged)
                        } else {
                            NotificationCenter.default.post(name: Notification.Name("reloadProfileData"), object: nil)
                            self.indicatorView.isHidden = true
                            self.dismiss(animated: true, completion: nil)
                        }
                        
                    } else if response?.status == 0 {
                        //Si ha fallado algo al editar algun dato el servidor nos devolvera el fallo aqui y se mostrara en un alert.
                        self.displayAlert(title: "Error", message: "\(response?.msg ?? "Se ha producido un error, intentalo mas tarde.")")
                        self.indicatorView.isHidden = true
                        
                    } else if errors == .badData || errors == .errorConnection {
                        self.displayAlert(title: "Error", message: "Ha habido un error, vuelve a intentarlo mas tarde.")
                        self.indicatorView.isHidden = true
                        
                    } else {
                        self.displayAlert(title: "Error", message: "Ha habido un error, vuelve a intentarlo mas tarde.")
                        self.indicatorView.isHidden = true
                        
                    }
                }
            }
            
        } else {
            self.displayAlert(title: "Error", message: "Rellena los campos vacios")
        }
    }
    
    //Funciones para cambiar la imagen de perfil y subirla al servidor.
    @IBAction func imageChangeTapped(_ sender: Any) {
        
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
            imageProfile.image = selectedImage
            imageToChange = selectedImage //Aqui almacenamos la imagen para subirla si el usuario guarda los cambios.

        } else if let selectedImage = info[.originalImage] as? UIImage {
            imageProfile.image = selectedImage
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
        
        NetworkManager.shared.uploadProfileImage(apiToken: Session.shared.api_token!, params: params){
            response, errors in DispatchQueue.main.async {
                self.indicatorView.isHidden = true
                self.response = response
                
                if response?.status == 1 {
                    NotificationCenter.default.post(name: Notification.Name("reloadProfileData"), object: nil)
                    self.dismiss(animated: true, completion: nil)
                    
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
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    //Funcion para ocultar el teclado.
    @objc func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            view.endEditing(true)
    }
    

    
    func errorConnectionAlert(title: String, message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: {(action) in self.dismiss(animated: true, completion: nil) }))
        //Si hay error de conexion se mostrara este alert y a la vez se cerrara la vista modal de editar.
        self.present(alert, animated: true, completion: nil)
    }
    
    func displayAlert(title: String, message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    

    

}
