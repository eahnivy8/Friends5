import UIKit


//image to use for placeholder
let placeHolderImage: UIImage? = UIImage(named: "placeholder")

//JSON Model for API Response
struct Response: Codable {
    let friends: [Person]
    
    enum CodingKeys: String, CodingKey {
        case friends = "results"
    }
}
// API 요청을 담당할 구조체
struct Request {
    // private properties
    private static let friendsURL: URL = URL(string: "https://randomuser.me/api/1.1/?inc=name,nat,cell,picture&format=json&results=50&noinfo")!
    //이미지 다운로드 디스패치 큐
    private static let imageDispatchQueue: DispatchQueue = DispatchQueue(label: "image")
    //이미지 메모리 캐쉬를 위한 딕셔너리
    private static var cachedImage: [URL: UIImage] = [:]
}

extension Request {
    //friend list request
    static func friends(_ completion: @escaping (_ friends: [Person]?) -> Void) {
        let session: URLSession = URLSession(configuration: URLSessionConfiguration.default)
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        let dataTask : URLSessionDataTask = session.dataTask(with: friendsURL) {
            (data: Data?, response: URLResponse?, error: Error?) in
            defer {
                DispatchQueue.main.async {
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                }
            }
            guard let data = data else {
                print("전달받은 데이터 없음")
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }
            let decoder:JSONDecoder = JSONDecoder()
            do {
                let decodedResponse: Response = try decoder.decode(Response.self, from: data)
                DispatchQueue.main.async {
                    completion(decodedResponse.friends)
                }
            } catch {
                print("응답 디코딩 실패")
                print(error.localizedDescription)
                dump(error)
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }
        dataTask.resume()
    }
}

extension Request {
    static func image(_ url: URL, completion: @escaping (_ image: UIImage?) -> Void) {
        
        if let cachedImage: UIImage = self.cachedImage[url] {
            DispatchQueue.main.async {
                completion(cachedImage)
                return
            }
        }
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        imageDispatchQueue.async {
            defer {
                DispatchQueue.main.async {
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                }
            }
            
            guard let data: Data = try? Data(contentsOf: url) else {
                print("데이터 - 이미지 변환 실패")
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }
            
            let image: UIImage? = UIImage(data: data)
            cachedImage[url] = image
            DispatchQueue.main.async {
                completion(image)
            }
        }
    }
}
