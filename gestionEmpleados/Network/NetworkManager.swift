//
//  NetworkManager.swift
//  gestionEmpleados
//
//  Created by Jonathan Miguel onrubia on 5/2/22.
//

import Foundation
import UIKit

enum NetworkError : Error {
    case invalidToken, badData, errorURL, errorConnection
}

final class NetworkManager {
    
    static let shared = NetworkManager()
    private init() {}
    
    private var imageCache = NSCache<NSString, UIImage>()

    var loginUserURL = "login"
    var registerUserURL = "registro?api_token="
    var recoverPassURL = "recoverPass"
    var getEmployeeListURL = "listado_empleados?api_token="
    var getEmployeeProfileURL = "ver_perfil?api_token="
    var editUserDataURL =  "modificar_datos/"
    var editProfileImageURL = "uploadImage?api_token="
    var editEmployeeImageURL = "uploadEmployeeImage/"
    
    func registerUser(apiToken: String, params: [String: Any]?, completion: @escaping (Response?, NetworkError?) -> Void) {
        
        Connection().connect(httpMethod: "PUT", to: registerUserURL + apiToken, params: params) {
            data, error in
            
            guard let data = data else {
                print("error al convertir a data")
                completion(nil, .badData)
                return
            }
            
            guard error == nil else {
                completion(nil, .badData)
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let response = try decoder.decode(Response.self, from: data)
                completion(response, nil)

            } catch {
                print("error al decodificar")
                completion(nil, .badData)
            }
        }
    }
    
    func recoverPassword(params: [String: Any]?, completion: @escaping (Response?, NetworkError?) -> Void){
        
        Connection().connect(httpMethod: "PUT", to: recoverPassURL, params: params) {
            data, error in
            
            guard let data = data else {
                print("error al convertir a data")
                completion(nil, .badData)
                return
            }
            guard error == nil else {
                completion(nil, .badData)
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let response = try decoder.decode(Response.self, from: data)
                completion(response, nil)

            } catch {
                print("error al decodificar")
                completion(nil, .badData)
            }
        }
    }
    
    func login(params: [String: Any]?, completion: @escaping (Response?, NetworkError?) -> Void){
        
        Connection().connect(httpMethod: "POST", to: loginUserURL, params: params) {
            data, error in
            
            guard let data = data else {
                print("error al convertir a data")
                completion(nil, .badData)
                return
            }
            
            guard error == nil else {
                completion(nil, .badData)
                return
            }

            do {
                let decoder = JSONDecoder()
                let response = try decoder.decode(Response.self, from: data)
                completion(response, nil)

            } catch {
                print("error al decodificar")
                completion(nil, .badData)
            }
        }
    }
    
    func getEmployeeList(apiToken: String ,completion: @escaping (Response?, NetworkError?) -> Void){
        
        Connection().connectGetData(to: getEmployeeListURL + apiToken){
            data, error in
            
            guard let data = data else {
                completion(nil, .badData)
                return
            }
            
            guard error == nil else {
                completion(nil, .badData)
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let response = try decoder.decode(Response.self, from: data)
                DispatchQueue.main.asyncAfter(deadline: .now() + 1){
                    completion(response, nil)
                }
            } catch {
                completion(nil, .badData)
                print("error al decodificar")
            }
            
        }

    }
    
    func getEmployeeProfile(apiToken: String ,completion: @escaping (Response?, NetworkError?) -> Void){
        
        Connection().connectGetData(to: getEmployeeProfileURL + apiToken){
            data, error in
            
            guard let data = data else {
                completion(nil, .badData)
                return
            }
            
            guard error == nil else {
                completion(nil, .badData)
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let response = try decoder.decode(Response.self, from: data)
                DispatchQueue.main.asyncAfter(deadline: .now() + 1){
                    completion(response, nil)
                }
            } catch {
                completion(nil, .badData)
                print("error al decodificar")
            }
            
        }
     
    }
    
    func editUserData(id : String ,apiToken: String, params: [String: Any]?, completion: @escaping (Response?, NetworkError?) -> Void) {
        
        Connection().connect(httpMethod: "POST", to: editUserDataURL + id + "?api_token=" + apiToken, params: params) {
            data, error in
            
            guard let data = data else {
                print("error al convertir a data")
                completion(nil, .badData)
                return
            }
            
            guard error == nil else {
                print("error al obtener los datos")
                completion(nil, .badData)
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let response = try decoder.decode(Response.self, from: data)
                DispatchQueue.main.asyncAfter(deadline: .now() + 1){
                    completion(response, nil)
                }

            } catch {
                print("error al decodificar")
                completion(nil, .badData)
            }
        }
    }
    
    func uploadProfileImage(apiToken: String, params: [String: Any]?, completion: @escaping (Response?, NetworkError?) -> Void) {
        
        Connection().connect(httpMethod: "POST", to: editProfileImageURL + apiToken, params: params) {
            data, error in
            
            guard let data = data else {
                print("error al convertir a data")
                completion(nil, .badData)
                return
            }
            
            guard error == nil else {
                print("error al obtener los datos")
                completion(nil, .badData)
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let response = try decoder.decode(Response.self, from: data)
                completion(response, nil)

            } catch {
                print("error al decodificar")
                completion(nil, .badData)
            }
        }
  
    }
    
    func uploadEmployeeImage(id : String, apiToken: String, params: [String: Any]?, completion: @escaping (Response?, NetworkError?) -> Void) {
        
        Connection().connect(httpMethod: "POST", to: editEmployeeImageURL + id + "?api_token=" + apiToken, params: params) {
            data, error in
            
            guard let data = data else {
                print("error al convertir a data")
                completion(nil, .badData)
                return
            }
            
            guard error == nil else {
                print("error al obtener los datos")
                completion(nil, .badData)
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let response = try decoder.decode(Response.self, from: data)
                completion(response, nil)

            } catch {
                print("error al decodificar")
                completion(nil, .badData)
            }
        }
  
    }
    
    func getImageFrom(imageUrl: String, completion: @escaping (UIImage?) -> Void) {

        let cacheKey = NSString(string: imageUrl)
        if let image = imageCache.object(forKey: cacheKey) {
            completion(image)
            return
        }

        guard let url = URL(string: imageUrl) else {
            completion(nil)
            return
        }

        let urlRequest = URLRequest(url: url)
        let networkTask = URLSession.shared.dataTask(with: urlRequest) {

            data, response, error in
            guard error == nil else {
                completion(nil)
                return
            }

            guard let data = data else {
                completion(nil)
                return
            }

            guard let image = UIImage(data: data) else {
                completion(nil)
                return
            }

            self.imageCache.setObject(image, forKey: cacheKey)
            completion(image)
        }
        networkTask.resume()

    }
    
    
    
    
    
}
