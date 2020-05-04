import Foundation

class ThreadedDataRequester {
    static let queue = DispatchQueue(label: "ThreadedDataRequester")
    
    static func requestData(generateData: @escaping () -> (Any), callback: @escaping (Any) -> ()) {
        queue.async {
            let data = generateData()
            
            DispatchQueue.main.async {
                callback(data)
            }
        }
    }
}
