//
//  URLSessionHTTPClientTests.swift
//  EssentialFeedLoaderTests
//
//  Created by Ayaz Rahman on 27/6/21.
//

import XCTest
import EssentialFeedLoader

class URLSessionHTTPClientTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        URLProtocolStub.startInterceptingRequests()
    }
    
    override func tearDown() {
        super.tearDown()
        URLProtocolStub.stopInterceptingRequests()
        
    }
    
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
    
    func test_getFromURL_performGETRequestWithURL(){
        
        let url = anyURL()
        let exp1 = expectation(description: "Wait for a request")
        //exp1.expectedFulfillmentCount = 2   // This is not clear
        //let exp2 = expectation(description: "Wait for request completion") // Only fixes from the client side
        
        
        URLProtocolStub.observeRequests{ request in
            XCTAssertEqual(request.url, url)
            XCTAssertEqual(request.httpMethod, "GET")
            exp1.fulfill()
        }
        
        makeSUT().get(from: url) { _ in  }
        
        wait(for: [exp1], timeout: 1)
        
    }
    
    func test_getFromURL_failsOnRequestError(){
        
        let requestError = anyNSError()
        let receivedError = resultErrorFor(data: nil, response: nil, error: requestError) as NSError?
        
        XCTAssertEqual(receivedError?.domain, requestError.domain)
        XCTAssertEqual(receivedError?.code, requestError.code)
        
    }
    
    func test_getFromURL_failsOnAllInvalidRepresentationCases(){
        
        XCTAssertNotNil(resultErrorFor(data: nil, response: nil, error: nil))
        XCTAssertNotNil(resultErrorFor(data: nil, response: nonHTTPURLResponse(), error: nil))
        //XCTAssertNotNil(resultErrorFor(data: nil, response: anyHTTPURLResponse(), error: nil))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: nil, error: nil))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: nil, error: anyNSError()))
        XCTAssertNotNil(resultErrorFor(data: nil, response: nonHTTPURLResponse(), error: anyNSError()))
        XCTAssertNotNil(resultErrorFor(data: nil, response: anyHTTPURLResponse(), error: anyNSError()))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: nonHTTPURLResponse(), error: anyNSError()))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: anyHTTPURLResponse(), error: anyNSError()))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: nonHTTPURLResponse(), error: nil))
        
    }
    
    func test_getFromURL_succeedsOnHTTPURLResponseWithData(){
        let data = anyData()
        let response = anyHTTPURLResponse()
        
        let receivedValues = resultValuesFor(data: data, response: response, error: nil)

        XCTAssertEqual(receivedValues?.data, data)
        XCTAssertEqual(receivedValues?.reponse.url, response.url)
        XCTAssertEqual(receivedValues?.reponse.statusCode, response.statusCode)
    }
    
    func test_getFromURL_succeedsWithEmptyDataOnHTTPURLResponseWithNilData(){
        let response = anyHTTPURLResponse()
        let receivedValues = resultValuesFor(data: nil, response: response, error: nil)

        let emptyData = Data()
        XCTAssertEqual(receivedValues?.data, emptyData)
        XCTAssertEqual(receivedValues?.reponse.url, response.url)
        XCTAssertEqual(receivedValues?.reponse.statusCode, response.statusCode)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> HTTPClient {
        let sut = URLSessionHTTPClient()
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
    
    private func anyURL() -> URL {
        return URL(string: "http://any-url.com")!
    }
    
    private func anyData() -> Data {
        return Data("any Data".utf8)
    }
    
    private func anyNSError() -> NSError {
        return NSError(domain: "any Error", code: 0)
    }
    
    private func anyHTTPURLResponse() -> HTTPURLResponse {
        return HTTPURLResponse(url: anyURL(), statusCode: 200, httpVersion: nil, headerFields: nil)!
    }
    
    private func nonHTTPURLResponse() -> URLResponse {
        return URLResponse(url: anyURL(), mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
    }
    
    private func resultValuesFor(data: Data?, response: URLResponse?, error: Error?, file: StaticString = #filePath, line: UInt = #line) -> (data: Data, reponse: HTTPURLResponse)? {
        let result = resultFor(data: data, response: response, error: error, file: file, line: line)
        
        switch result{
        case let .success(data, response):
            return (data, response)
        default:
            XCTFail("Expected success, got \(result) instead")
            return nil
        }
        
    }
    
    private func resultErrorFor(data: Data?, response: URLResponse?, error: Error?, file: StaticString = #filePath, line: UInt = #line) -> Error? {
        let result = resultFor(data: data, response: response, error: error, file: file, line: line)
        
        switch result{
        case let .failure(error):
            return error
        default:
            XCTFail("Expected failure, got \(result) instead")
            return nil
        }

    }
    
    private func resultFor(data: Data?, response: URLResponse?, error: Error?, file: StaticString = #filePath, line: UInt = #line) -> HTTPClientResult{
        URLProtocolStub.stub(data: data, response: response, error: error)
        
        let sut = makeSUT(file: file, line: line)
        let exp = expectation(description: "Wait for completions")
        
        var receivedResult: HTTPClientResult!
        sut.get(from: anyURL()){ result in
            receivedResult = result
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1)
        return receivedResult
    }
    
    private class URLProtocolStub: URLProtocol{
        //var receivedURLS = [URL]()
        private static var stub: Stub?
        private static var requestObserver: ((URLRequest) -> Void)? = nil
        
        private struct Stub {
            let data: Data?
            let response: URLResponse?
            let error: Error?
        }
        
        static func stub(data: Data?, response: URLResponse?, error: Error?){
            stub = Stub(data: data, response: response, error: error)
        }
        
        static func observeRequests(observer: @escaping (URLRequest) -> Void){
            requestObserver = observer
        }
        
        static func startInterceptingRequests() {
            URLProtocol.registerClass(URLProtocolStub.self)
        }
        
        static func stopInterceptingRequests() {
            URLProtocol.unregisterClass(URLProtocolStub.self)
            stub = nil
            requestObserver = nil
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
            
            if let requestObserver = URLProtocolStub.requestObserver {
                client?.urlProtocolDidFinishLoading(self)
                return requestObserver(request)
            }
            
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
