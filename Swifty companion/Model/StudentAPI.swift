//
//  StudentAPI.swift
//  Swifty companion
//
//  Created by Mac Developer on 2/15/19.
//  Copyright © 2019 Viktoriia LIKHOTKINA. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class StudentAPI {
    
    enum Endpoint {
        case authentication
        case getStudent
        
        var url : URL {
            return URL(string : self.stringURL)!
        }
        var stringURL : String {
            switch self {
            case .authentication:
                return "https://api.intra.42.fr/oauth/token"
            case .getStudent:
                return "https://api.intra.42.fr/v2/users/"
            }
        }
    }
    
    class func makeAuthentication() {
        let credentialsString = "\(client_id):\(client_secret)"
        let credentialsData = (credentialsString as String).data(using: String.Encoding.utf8)
        let base64String = credentialsData!.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
        let headers = ["Authorization": "Basic \(base64String)", "Content-Type": "application/x-www-form-urlencoded;charset=UTF-8"]
        let params: [String : Any] = ["grant_type": "client_credentials", "scope": "public profile"]
        let token_uri = "https://api.intra.42.fr/oauth/token"
        Alamofire.request(token_uri, method: .post, parameters: params, encoding: URLEncoding.default, headers: headers)
            .responseJSON { response in switch response.result {
            case .success(let JSON):
                let response = JSON as! [String:AnyObject]
                let userModel = response
                print("Authentication request success")
                print(userModel)
                token = userModel["access_token"] as? String
                expiresIn = userModel["expires_in"] as! Int
                DispatchQueue.main.asyncAfter(deadline: .now() + Double(expiresIn)) {
                    StudentAPI.makeAuthentication()
                }
            case .failure(let error):
                print("Request failed with error: \(error)")
                }
        }
    }
    
    class func fillValidateProjects(studentInfo : inout Student) {
        
        let res = studentInfo.projects.filter({$0.status == "finished" && $0.cursus_ids.count > 0 && $0.cursus_ids[0] == 1})
        var parents = res.filter({$0.projectNameStruct.parent_id == nil})
        let childs = res.filter({$0.projectNameStruct.parent_id != nil})
        for child in childs {
            for (j, parent) in parents.enumerated() {
                if parent.projectNameStruct.id == child.projectNameStruct.parent_id {
                    parents[j].childProjects.append(child)
                    parents[j].headerStatus = .close
                    break
                }
            }
        }
        studentInfo.validatedProjects = parents
    }
    
    class func getUserData(login : String, completionHandler : @escaping (Student?, Error?) -> Void)
    {
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(token!)",
            "Accept": "application/json"
        ]
        Alamofire.request("https://api.intra.42.fr/v2/users/\(login)", headers: headers).responseJSON { response in
            //print("response")
            //print(response.request as Any)
            //print(response.response as Any)
            //print(response.data as Any)
            //print(response.result)
            //print("response")
            switch response.result {
            case .success:
                let userModel = JSON(data: response.data!)
                print("userModel with swiftyJSON")
                print(userModel)
                let decoder = JSONDecoder()
                let studentInfo = try? decoder.decode(Student.self, from: response.data!)
                print("Decodable student info")
                print(studentInfo as Any)
                print("VALIDATED PROJECTS")
                print(studentInfo?.validatedProjects as Any)
                completionHandler(studentInfo, nil)
            case .failure(let error):
                completionHandler(nil, error)
            }
        }
    }
}
