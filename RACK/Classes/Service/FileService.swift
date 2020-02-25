//
//  FileService.swift
//  RACK
//
//  Created by Andrey Chernyshev on 25/02/2020.
//  Copyright © 2020 fawn.team. All rights reserved.
//

import Alamofire
import RxSwift
import UIKit

final class FileService {
    typealias UploadedFilePath = String
    
    static func send(image: UIImage) -> Single<UploadedFilePath?> {
        guard let imageData = image.jpegData(compressionQuality: 0.5), let appKeyData = GlobalDefinitions.ChatService.appKey.data(using: .utf8) else {
            return .just(nil)
        }
        
        return Single<UploadedFilePath?>.create { event in
            Alamofire.upload(multipartFormData: { formData in
                formData.append(imageData, withName: "file", fileName: "file.jpg", mimeType: "image/jpeg")
                formData.append(appKeyData, withName: "app_key")
            }, to: GlobalDefinitions.ChatService.restDomain + "/api/v1/data/uploadFile") { result in
                switch result {
                case .success(let upload, _, _):
                    upload.responseJSON { response in
                        switch response.result {
                        case .success(let json):
                            event(.success(FileService.map(response: json)))
                        case .failure(_):
                            event(.error((response.response?.statusCode ?? -1) == 401 ? ApiError.unauthorized : ApiError.serverNotAvailable))
                        }
                    }
                case .failure(_):
                    event(.error(ApiError.serverNotAvailable))
                }
            }
            
            return Disposables.create()
        }
    }
    
    private static func map(response: Any) -> UploadedFilePath? {
        guard let json = response as? [String: Any] else {
            return nil
        }
        
        return json["result"] as? String
    }
}
