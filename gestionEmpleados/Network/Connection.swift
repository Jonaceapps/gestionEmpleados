//
//  Connection.swift
//  gestionEmpleados
//
//  Created by Jonathan Miguel onrubia on 17/2/22.
//

import Foundation
import UIKit

final class Connection {
    
    let baseURL = "http://empleadosapi.jonacedev.com/gestion_empleados/public/api/usuarios/"
    
    func connect(httpMethod: String, to endpoint: String, params : [String : Any]? , completion : @escaping (Data?, NetworkError?) -> Void) {
        
        guard let url = URL(string: baseURL + endpoint) else {
            completion(nil, .errorURL)
            return
        }
        var urlRequest = URLRequest(url: url, timeoutInterval: 10)
        
        if let params = params {
            guard let paramsData = try? JSONSerialization.data(withJSONObject: params, options: []) else {
                completion(nil, .badData)
                return
            }
           
            urlRequest.httpMethod = httpMethod
            urlRequest.httpBody = paramsData
        }
        let headers = [
            "Content-Type": "application/json",
            "Accept":       "application/json"
        ]
        let sessionConfiguration = URLSessionConfiguration.default
        sessionConfiguration.httpAdditionalHeaders = headers
        let urlSession = URLSession(configuration: sessionConfiguration)
        
        let networkTask = urlSession.dataTask(with: urlRequest) {
            data, response, error in
    
            guard response is HTTPURLResponse else {
                completion(nil, .errorConnection)
                return
            }
            
            guard error == nil else {
                print("error al obtener los datos")
                completion(nil, .badData)
                return
            }
            
            completion(data, nil)
        }
        
        networkTask.resume()
        
    }
    
    func connectGetData(to endpoint: String, completion : @escaping (Data?, NetworkError?) -> Void) {
        
        guard let url = URL(string: baseURL + endpoint) else {
            completion(nil, .errorURL)
            return
        }
        
        let urlRequest = URLRequest(url: url, timeoutInterval: 10)
        let networkTask = URLSession.shared.dataTask(with: urlRequest) {
            data, response, error in
    
            guard response is HTTPURLResponse else {
                completion(nil, .errorConnection)
                return
            }
            
            guard error == nil else {
                print("error al obtener los datos")
                completion(nil, .badData)
                return
            }
            
            completion(data, nil)
        }
        
        networkTask.resume()
        
    }
    
    
    
    
    
    
    
    
}
