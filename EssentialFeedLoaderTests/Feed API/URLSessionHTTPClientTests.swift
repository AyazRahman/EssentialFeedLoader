//
//  URLSessionHTTPClientTests.swift
//  EssentialFeedLoaderTests
//
//  Created by Ayaz Rahman on 27/6/21.
//

import XCTest
import EssentialFeedLoader

// Remove to use the URLProtocol
//protocol HTTPSession {
//    func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> HTTPSessionTask
//}
//
//protocol HTTPSessionTask {
//    func resume()
//}

class URLSessionHTTPClient {
    private let session: URLSession
    
    init(session: URLSession = .shared){
        self.session = session
    }
    
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
        session.dataTask(with: url) { _, _, error in
            if let error = error {
                completion(.failure(error))
            }
        }.resume()
    }
}

class URLSessionHTTPClientTests: XCTestCase {
    
//    Not Needed anymore
//    func test_getFromURL_createsDataTaskWithURL() {
//        let url = URL(string: "http://any-url.com")!
//        let session = URLSessionSpy()
//        let sut = URLSessionHTTPClient(session: session)
//
//
//        sut.get(from: url)
//
//        XCTAssertEqual(session.receivedURLS, [url])
//    }
    
//    Task not needed anymore
//    func test_getFromURL_resumesDataTaskWithURL() {
//            let url = URL(string: "http://any-url.com")!
//            let session = HTTPSessionSpy()
//
//            session.stub(url: url, task: task)
//
//            let sut = URLSessionHTTPClient()
//
//            sut.get(from: url) { _ in }
//
//            XCTAssertEqual(task.resumeCallCount, 1)
//        }
    
    func test_getFromURL_failsOnRequestError(){
        URLProtocolStub.startInterceptingRequests()
        let url = URL(string: "http://any-url.com")!
        let error = NSError(domain: "any error", code: 1)
        URLProtocolStub.stub(data: nil, response: nil, error: error)
        
        let sut = URLSessionHTTPClient()
        
        let exp = expectation(description: "Wait for completion")
        
        sut.get(from: url){ result in
            switch result{
            case let .failure(receivedError as NSError):
                XCTAssertEqual(receivedError.domain, error.domain)
                XCTAssertEqual(receivedError.code, error.code)
            default:
                XCTFail("Expected failue with error \(error), got \(result) instead")
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1)
        URLProtocolStub.stopInterceptingRequests()
    }
    
    // MARK: - Helpers
    
    private class URLProtocolStub: URLProtocol{
        //var receivedURLS = [URL]()
        private static var stub: Stub?
        
        private struct Stub {
            let data: Data?
            let response: URLResponse?
            let error: Error?
        }
        
        static func stub(data: Data?, response: URLResponse?, error: Error?){
            stub = Stub(data: data, response: response, error: error)
        }
        
        static func startInterceptingRequests() {
            URLProtocol.registerClass(URLProtocolStub.self)
        }
        
        static func stopInterceptingRequests() {
            URLProtocol.unregisterClass(URLProtocolStub.self)
            stub = nil
        }
        
//        Not needed anymore
//        func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> HTTPSessionTask {
//            //receivedURLS.append(url)
//            //return stubs[url]?.task ?? FakeURLSessionDataTask()
//
//            guard let stub = stubs[url] else {
//                fatalError("Could not find stub for \(url)")
//            }
//            completionHandler(nil, nil, stub.error)
//            return stub.task
//        }
        
        
        
        override class func canInit(with request: URLRequest) -> Bool {
            return true
        }
        
        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            return request
        }
        
        override func startLoading() {
            
            
            if let data = URLProtocolStub.stub?.data {
                client?.urlProtocol(self, didLoad: data)
            }
            
            if let reponse = URLProtocolStub.stub?.response {
                client?.urlProtocol(self, didReceive: reponse, cacheStoragePolicy: .notAllowed)
            }
            
            if let error = URLProtocolStub.stub?.error {
                client?.urlProtocol(self, didFailWithError: error)
            }
            
            client?.urlProtocolDidFinishLoading(self)
        }
        
        override func stopLoading() {}
    }
    
    // Not Needed anymore
//    private class FakeURLSessionDataTask: HTTPSessionTask{
//        func resume() {
//
//        }
//    }
//
//    private class URLSessionDataTaskSpy: HTTPSessionTask{
//        var resumeCallCount = 0
//
//        func resume() {
//            resumeCallCount += 1
//        }
//    }

}
