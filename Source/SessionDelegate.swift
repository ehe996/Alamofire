//
//  SessionDelegate.swift
//
//  Copyright (c) 2014 Alamofire Software Foundation (http://alamofire.org/)
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import Foundation

/// Responsible for handling all delegate callbacks for the underlying session.
/// 在这里处理 URLSession所有的代理方法
open class SessionDelegate: NSObject {

    // MARK: URLSessionDelegate Overrides
    /// 这些闭包，都是提供给外界一个入口，当URLSessionDelegate 代理方法被调用时，这些相应的闭包也会被调用
    /// - 闭包调用分2种情况：
    /// 1. 如果用户在外面定义了某个闭包，那么就不走框架内部代理方法默认实现逻辑，就完全交给用户自定义处理； if else 二选一的关系；
    /// 2. 既调用闭包告诉用户代理方法调用了，又走框架内部默认处理逻辑； 共存的关系

    /// - 会话级别的代理回调
    /// Overrides default behavior for URLSessionDelegate method `urlSession(_:didBecomeInvalidWithError:)`.
    open var sessionDidBecomeInvalidWithError: ((URLSession, Error?) -> Void)?

    /// Overrides default behavior for URLSessionDelegate method `urlSession(_:didReceive:completionHandler:)`.
    open var sessionDidReceiveChallenge: ((URLSession, URLAuthenticationChallenge) -> (URLSession.AuthChallengeDisposition, URLCredential?))?

    /// Overrides all behavior for URLSessionDelegate method `urlSession(_:didReceive:completionHandler:)` and requires the caller to call the `completionHandler`.
    open var sessionDidReceiveChallengeWithCompletion: ((URLSession, URLAuthenticationChallenge, @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) -> Void)?

    /// Overrides default behavior for URLSessionDelegate method `urlSessionDidFinishEvents(forBackgroundURLSession:)`.
    open var sessionDidFinishEventsForBackgroundURLSession: ((URLSession) -> Void)?

    // MARK: URLSessionTaskDelegate Overrides

    /// Overrides default behavior for URLSessionTaskDelegate method `urlSession(_:task:willPerformHTTPRedirection:newRequest:completionHandler:)`.
    open var taskWillPerformHTTPRedirection: ((URLSession, URLSessionTask, HTTPURLResponse, URLRequest) -> URLRequest?)?

    /// Overrides all behavior for URLSessionTaskDelegate method `urlSession(_:task:willPerformHTTPRedirection:newRequest:completionHandler:)` and
    /// requires the caller to call the `completionHandler`.
    open var taskWillPerformHTTPRedirectionWithCompletion: ((URLSession, URLSessionTask, HTTPURLResponse, URLRequest, @escaping (URLRequest?) -> Void) -> Void)?

    /// Overrides default behavior for URLSessionTaskDelegate method `urlSession(_:task:didReceive:completionHandler:)`.
    open var taskDidReceiveChallenge: ((URLSession, URLSessionTask, URLAuthenticationChallenge) -> (URLSession.AuthChallengeDisposition, URLCredential?))?

    /// Overrides all behavior for URLSessionTaskDelegate method `urlSession(_:task:didReceive:completionHandler:)` and
    /// requires the caller to call the `completionHandler`.
    open var taskDidReceiveChallengeWithCompletion: ((URLSession, URLSessionTask, URLAuthenticationChallenge, @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) -> Void)?

    /// Overrides default behavior for URLSessionTaskDelegate method `urlSession(_:task:needNewBodyStream:)`.
    open var taskNeedNewBodyStream: ((URLSession, URLSessionTask) -> InputStream?)?

    /// Overrides all behavior for URLSessionTaskDelegate method `urlSession(_:task:needNewBodyStream:)` and
    /// requires the caller to call the `completionHandler`.
    open var taskNeedNewBodyStreamWithCompletion: ((URLSession, URLSessionTask, @escaping (InputStream?) -> Void) -> Void)?

    /// Overrides default behavior for URLSessionTaskDelegate method `urlSession(_:task:didSendBodyData:totalBytesSent:totalBytesExpectedToSend:)`.
    open var taskDidSendBodyData: ((URLSession, URLSessionTask, Int64, Int64, Int64) -> Void)?

    /// Overrides default behavior for URLSessionTaskDelegate method `urlSession(_:task:didCompleteWithError:)`.
    open var taskDidComplete: ((URLSession, URLSessionTask, Error?) -> Void)?

    // MARK: 任务级别的 URLSessionDataDelegate Overrides

    /// Overrides default behavior for URLSessionDataDelegate method `urlSession(_:dataTask:didReceive:completionHandler:)`.
    open var dataTaskDidReceiveResponse: ((URLSession, URLSessionDataTask, URLResponse) -> URLSession.ResponseDisposition)?

    /// Overrides all behavior for URLSessionDataDelegate method `urlSession(_:dataTask:didReceive:completionHandler:)` and
    /// requires caller to call the `completionHandler`.
    open var dataTaskDidReceiveResponseWithCompletion: ((URLSession, URLSessionDataTask, URLResponse, @escaping (URLSession.ResponseDisposition) -> Void) -> Void)?

    /// Overrides default behavior for URLSessionDataDelegate method `urlSession(_:dataTask:didBecome:)`.
    open var dataTaskDidBecomeDownloadTask: ((URLSession, URLSessionDataTask, URLSessionDownloadTask) -> Void)?

    /// Overrides default behavior for URLSessionDataDelegate method `urlSession(_:dataTask:didReceive:)`.
    open var dataTaskDidReceiveData: ((URLSession, URLSessionDataTask, Data) -> Void)?

    /// Overrides default behavior for URLSessionDataDelegate method `urlSession(_:dataTask:willCacheResponse:completionHandler:)`.
    open var dataTaskWillCacheResponse: ((URLSession, URLSessionDataTask, CachedURLResponse) -> CachedURLResponse?)?

    /// Overrides all behavior for URLSessionDataDelegate method `urlSession(_:dataTask:willCacheResponse:completionHandler:)` and
    /// requires caller to call the `completionHandler`.
    open var dataTaskWillCacheResponseWithCompletion: ((URLSession, URLSessionDataTask, CachedURLResponse, @escaping (CachedURLResponse?) -> Void) -> Void)?

    // MARK: URLSessionDownloadDelegate Overrides

    /// Overrides default behavior for URLSessionDownloadDelegate method `urlSession(_:downloadTask:didFinishDownloadingTo:)`.
    open var downloadTaskDidFinishDownloadingToURL: ((URLSession, URLSessionDownloadTask, URL) -> Void)?

    /// Overrides default behavior for URLSessionDownloadDelegate method `urlSession(_:downloadTask:didWriteData:totalBytesWritten:totalBytesExpectedToWrite:)`.
    open var downloadTaskDidWriteData: ((URLSession, URLSessionDownloadTask, Int64, Int64, Int64) -> Void)?

    /// Overrides default behavior for URLSessionDownloadDelegate method `urlSession(_:downloadTask:didResumeAtOffset:expectedTotalBytes:)`.
    open var downloadTaskDidResumeAtOffset: ((URLSession, URLSessionDownloadTask, Int64, Int64) -> Void)?

    // MARK: URLSessionStreamDelegate Overrides

#if !os(watchOS)

    /// Overrides default behavior for URLSessionStreamDelegate method `urlSession(_:readClosedFor:)`.
    @available(iOS 9.0, macOS 10.11, tvOS 9.0, *)
    open var streamTaskReadClosed: ((URLSession, URLSessionStreamTask) -> Void)? {
        get {
            return _streamTaskReadClosed as? (URLSession, URLSessionStreamTask) -> Void
        }
        set {
            _streamTaskReadClosed = newValue
        }
    }

    /// Overrides default behavior for URLSessionStreamDelegate method `urlSession(_:writeClosedFor:)`.
    @available(iOS 9.0, macOS 10.11, tvOS 9.0, *)
    open var streamTaskWriteClosed: ((URLSession, URLSessionStreamTask) -> Void)? {
        get {
            return _streamTaskWriteClosed as? (URLSession, URLSessionStreamTask) -> Void
        }
        set {
            _streamTaskWriteClosed = newValue
        }
    }

    /// Overrides default behavior for URLSessionStreamDelegate method `urlSession(_:betterRouteDiscoveredFor:)`.
    @available(iOS 9.0, macOS 10.11, tvOS 9.0, *)
    open var streamTaskBetterRouteDiscovered: ((URLSession, URLSessionStreamTask) -> Void)? {
        get {
            return _streamTaskBetterRouteDiscovered as? (URLSession, URLSessionStreamTask) -> Void
        }
        set {
            _streamTaskBetterRouteDiscovered = newValue
        }
    }

    /// Overrides default behavior for URLSessionStreamDelegate method `urlSession(_:streamTask:didBecome:outputStream:)`.
    @available(iOS 9.0, macOS 10.11, tvOS 9.0, *)
    open var streamTaskDidBecomeInputAndOutputStreams: ((URLSession, URLSessionStreamTask, InputStream, OutputStream) -> Void)? {
        get {
            return _streamTaskDidBecomeInputStream as? (URLSession, URLSessionStreamTask, InputStream, OutputStream) -> Void
        }
        set {
            _streamTaskDidBecomeInputStream = newValue
        }
    }

    /// ToUnderstand-❓- 不明白为什么这里他们要设置成为 Any?类型，而不是对应的类型，看看新版本框架有改动吗
    /// 而且这几个变量存在的意义是什么呢？好像不用他们也完全可以
    var _streamTaskReadClosed: Any?
    var _streamTaskWriteClosed: Any?
    var _streamTaskBetterRouteDiscovered: Any?
    var _streamTaskDidBecomeInputStream: Any?

#endif

    // MARK: Properties

    var retrier: RequestRetrier?
    weak var sessionManager: SessionManager?

    /// 建立 URLSessionTask 与 Request 的映射关系，key是 task.taskIdentifier
    var requests: [Int: Request] = [:]
    private let lock = NSLock()

    /// 这里使用类似字典的方式来存储映射关系
    ///
    /// 建立 URLSessionTask 与 Request 的映射关系，这里为什么要建立这个映射关系呢？
    /// - 因为再Request中可以很方便的拿到对应的URLSessionTask，但是通过 URLSessionTask 却没法直接拿到他对应的 Request，
    ///     有了这里的映射关系之后。就可以很方便的通过 URLSessionTask 来拿到对应的 Request；
    ///
    /// 那为什么通过 URLSessionTask 来拿到对应的 Request 这个有什么作用呢？
    ///  - 因为URLSessionDelegate 大部分代理方法参数中，都会带有 URLSessionTask 对象参数，因此当我们在代理方法中想处理一些逻辑的时候，
    ///  就可以很方便的通过 URLSessionTask 对象 来拿到对应的 Request对象，从而来处理他特有的逻辑任务；
    ///
    /// Access the task delegate for the specified task in a thread-safe manner.
    open subscript(task: URLSessionTask) -> Request? {
        get {
            lock.lock() ; defer { lock.unlock() }
            return requests[task.taskIdentifier]
        }
        set {
            lock.lock() ; defer { lock.unlock() }
            requests[task.taskIdentifier] = newValue
        }
    }

    // MARK: Lifecycle

    /// Initializes the `SessionDelegate` instance.
    ///
    /// - returns: The new `SessionDelegate` instance.
    public override init() {
        super.init()
    }

    // MARK: NSObject Overrides

    /// Returns a `Bool` indicating whether the `SessionDelegate` implements or inherits a method that can respond
    /// to a specified message.
    ///
    /// - parameter selector: A selector that identifies a message.
    ///
    /// - returns: `true` if the receiver implements or inherits a method that can respond to selector, otherwise `false`.
    open override func responds(to selector: Selector) -> Bool {
        /// 判断外界有没有实现这些代理方法的闭包回调，
        /// 所以下面这些case 是通过判断闭包是否为nil来决定是否要响应代理方法；因为外面只能通过闭包来接收这些代理回调，
        /// 如果外面没有定义这些闭包，那么也就不需要响应该代理方法；
        /// 因为框架内部不需要用到这些代理方法，如果外面也没有人用到，那自然就不需要再去响应了
        /// 也就是这些代理方法，完全就转发出去，如果外面没有人用，我就不转发了（当responds返回false，就不会响应该代理方法了）
        #if !os(macOS)
            if selector == #selector(URLSessionDelegate.urlSessionDidFinishEvents(forBackgroundURLSession:)) {
                return sessionDidFinishEventsForBackgroundURLSession != nil
            }
        #endif

        #if !os(watchOS)
            if #available(iOS 9.0, macOS 10.11, tvOS 9.0, *) {
                switch selector {
                case #selector(URLSessionStreamDelegate.urlSession(_:readClosedFor:)):
                    return streamTaskReadClosed != nil
                case #selector(URLSessionStreamDelegate.urlSession(_:writeClosedFor:)):
                    return streamTaskWriteClosed != nil
                case #selector(URLSessionStreamDelegate.urlSession(_:betterRouteDiscoveredFor:)):
                    return streamTaskBetterRouteDiscovered != nil
                case #selector(URLSessionStreamDelegate.urlSession(_:streamTask:didBecome:outputStream:)):
                    return streamTaskDidBecomeInputAndOutputStreams != nil
                default:
                    break
                }
            }
        #endif

        switch selector {
        case #selector(URLSessionDelegate.urlSession(_:didBecomeInvalidWithError:)):
            return sessionDidBecomeInvalidWithError != nil
        case #selector(URLSessionDelegate.urlSession(_:didReceive:completionHandler:)):
            return (sessionDidReceiveChallenge != nil  || sessionDidReceiveChallengeWithCompletion != nil)
        case #selector(URLSessionTaskDelegate.urlSession(_:task:willPerformHTTPRedirection:newRequest:completionHandler:)):
            return (taskWillPerformHTTPRedirection != nil || taskWillPerformHTTPRedirectionWithCompletion != nil)
        case #selector(URLSessionDataDelegate.urlSession(_:dataTask:didReceive:completionHandler:)):
            return (dataTaskDidReceiveResponse != nil || dataTaskDidReceiveResponseWithCompletion != nil)
        default:
            /// 这个是NSOBject的特性，可以用 instancesRespond 来判断 某个类的实例是否实现了某个方法；
            /// 原理应该就是查方法列表
            return type(of: self).instancesRespond(to: selector)
        }
    }
}

// MARK: - URLSessionDelegate

/// URLSessionDelegate协议继承自NSObjectProtocol协议，URLSessionDelegate : NSObjectProtocol
/// URLSessionDelegate 里面只有下面3个代理方法
extension SessionDelegate: URLSessionDelegate {
    /**
     注释内容：
     会话接收到的最后一条消息。会话只会因为系统错误或显式失效而失效，在这种情况下，error参数为nil。
     */
    /// Tells the delegate that the session has been invalidated.
    ///
    /// - parameter session: The session object that was invalidated.
    /// - parameter error:   The error that caused invalidation, or nil if the invalidation was explicit.
    open func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {
        sessionDidBecomeInvalidWithError?(session, error)
    }

    /*
     注释内容：
     如果实现，当发生连接级身份验证挑战时，此委托将有机会向底层连接提供身份验证凭据。
     某些类型的身份验证将应用于到服务器的给定连接上的多个请求(SSL服务器信任挑战)。如果没有实现此委托消息，则行为将使用默认处理，这可能涉及用户交互。
     */
    /// 从代理请求凭据，以响应来自远程服务器的会话级身份验证请求
    /// Requests credentials from the delegate in response to a session-level authentication request from the
    /// remote server.
    ///
    /// - parameter session:           The session containing the task that requested authentication.
    /// - parameter challenge:         An object that contains the request for authentication.
    /// - parameter completionHandler: A handler that your delegate method must call providing the disposition
    ///                                and credential.
    open func urlSession(
        _ session: URLSession,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void)
    {
        guard sessionDidReceiveChallengeWithCompletion == nil else {
            sessionDidReceiveChallengeWithCompletion?(session, challenge, completionHandler)
            return
        }

        var disposition: URLSession.AuthChallengeDisposition = .performDefaultHandling
        var credential: URLCredential?

        if let sessionDidReceiveChallenge = sessionDidReceiveChallenge {
            (disposition, credential) = sessionDidReceiveChallenge(session, challenge)
        } else if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust {
            let host = challenge.protectionSpace.host

            if
                let serverTrustPolicy = session.serverTrustPolicyManager?.serverTrustPolicy(forHost: host),
                let serverTrust = challenge.protectionSpace.serverTrust
            {
                if serverTrustPolicy.evaluate(serverTrust, forHost: host) {
                    disposition = .useCredential
                    credential = URLCredential(trust: serverTrust)
                } else {
                    disposition = .cancelAuthenticationChallenge
                }
            }
        }

        completionHandler(disposition, credential)
    }

#if !os(macOS)

    /*
     方法注释内容：
     如果应用程序收到了-application:handleEventsForBackgroundURLSession:completionHandler: 消息，
     则session delegate将收到此消息，表明之前为此会话排队的所有消息已经交付。
     此时，可以安全地调用之前存储的completion处理程序，或者开始任何内部更新，从而调用completion处理程序。
     */
    /// Tells the delegate that all messages enqueued for a session have been delivered.
    ///
    /// - parameter session: The session that no longer has any outstanding requests.
    open func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        sessionDidFinishEventsForBackgroundURLSession?(session)
    }
    
    

#endif
}


// MARK: - 代理方法类关系概括
/**
 
 URLSession 与 URLSessionTask的关系：
 - 一对多的关系，一个 URLSession 可以对应管理多个 URLSessionTask
 - 每个URLRequest，都需要一个 URLSessionTask
 - 在这个框架中，每个Request都对应着一个 URLSessionTask 和 TaskDelegate
 
 
 下面这些代理方法处理逻辑，总结下来大部分就是下面几个特点：
 1. 首先看外界有没有实现自定义闭包，如果有，那么让外界接管处理，调用闭包；
 2. 如果没有，就让框架内部自己处理，让代理方法转发给任务代理 TaskDelegate；
 
 个别代理方法有外界闭包调用和 TaskDelegate转发并存的逻辑，
 
 
 继承关系概括如下：
 
 URLSessionDelegate 是会话级别的代理
 
 URLSessionTaskDelegate: URLSessionDelegate 是任务级别代理，继承自 URLSessionDelegate
 
 根据功能的不同，代理分的更细，分为 data、Download、Stream，要注意：没有单独的upload的Delegate，
 URLSessionTaskDelegate中的 didSendBodyData bytesSent: Int64 方法，就是上传进度方法回调
 
 
 URLSessionDataDelegate : URLSessionTaskDelegate，继承自 URLSessionTaskDelegate
 URLSessionDownloadDelegate : URLSessionTaskDelegate，继承自 URLSessionTaskDelegate
 URLSessionStreamDelegate : URLSessionTaskDelegate，继承自 URLSessionTaskDelegate
 
 还有个 URLSessionWebSocketDelegate，也是继承自 URLSessionTaskDelegate，当前框架没有用到；
 URLSessionWebSocketDelegate : URLSessionTaskDelegate，继承自 URLSessionTaskDelegate
 */

// MARK: - URLSessionTaskDelegate

/// URLSessionTaskDelegate协议继承了URLSessionDelegate协议，URLSessionTaskDelegate : URLSessionDelegate
extension SessionDelegate: URLSessionTaskDelegate {
    /**
     注释内容：
     HTTP请求试图重定向到不同的URL。你必须调用完成例程来允许重定向，允许重定向修改后的请求，或者将nil传递给completionHandler，
     以导致重定向响应的主体作为请求的有效载荷传递。默认是遵循重定向。对于后台会话中的任务，重定向将始终遵循，并且不会调用此方法。
     */
    /// Tells the delegate that the remote server requested an HTTP redirect.
    ///
    /// - parameter session:           The session containing the task whose request resulted in a redirect.
    /// - parameter task:              The task whose request resulted in a redirect.
    /// - parameter response:          An object containing the server’s response to the original request.
    /// - parameter request:           A URL request object filled out with the new location.
    /// - parameter completionHandler: A closure that your handler should call with either the value of the request
    ///                                parameter, a modified URL request object, or NULL to refuse the redirect and
    ///                                return the body of the redirect response.
    open func urlSession(
        _ session: URLSession,
        task: URLSessionTask,
        willPerformHTTPRedirection response: HTTPURLResponse,
        newRequest request: URLRequest,
        completionHandler: @escaping (URLRequest?) -> Void)
    {
        guard taskWillPerformHTTPRedirectionWithCompletion == nil else {
            taskWillPerformHTTPRedirectionWithCompletion?(session, task, response, request, completionHandler)
            return
        }

        var redirectRequest: URLRequest? = request

        if let taskWillPerformHTTPRedirection = taskWillPerformHTTPRedirection {
            redirectRequest = taskWillPerformHTTPRedirection(session, task, response, request)
        }

        completionHandler(redirectRequest)
    }

    /**
     注释内容：
     日志含义任务收到特定身份验证挑战请求。
     如果没有实现此委托，则特定于会话的身份验证挑战将* *不会* *被调用，行为将与使用默认处理处置相同。
     */
    /// 向委托请求凭据，以响应来自远程服务器的身份验证请求。
    /// Requests credentials from the delegate in response to an authentication request from the remote server.
    ///
    /// - parameter session:           The session containing the task whose request requires authentication.
    /// - parameter task:              The task whose request requires authentication.
    /// - parameter challenge:         An object that contains the request for authentication.
    /// - parameter completionHandler: A handler that your delegate method must call providing the disposition
    ///                                and credential.
    open func urlSession(
        _ session: URLSession,
        task: URLSessionTask,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void)
    {
        guard taskDidReceiveChallengeWithCompletion == nil else {
            taskDidReceiveChallengeWithCompletion?(session, task, challenge, completionHandler)
            return
        }

        if let taskDidReceiveChallenge = taskDidReceiveChallenge {
            let result = taskDidReceiveChallenge(session, task, challenge)
            completionHandler(result.0, result.1)
        } else if let delegate = self[task]?.delegate {
            /// 转发给 TaskDelegate 对象来处理
            delegate.urlSession(
                session,
                task: task,
                didReceive: challenge,
                completionHandler: completionHandler
            )
        } else {
            urlSession(session, didReceive: challenge, completionHandler: completionHandler)
        }
    }
    
    /**
     注释内容：
     如果任务需要新的、未打开的body流，则发送。当涉及正文流的任何请求的身份验证失败时，这可能是必要的。
     */
    /// 告诉委托任务何时需要将新的请求体流发送到远程服务器。
    /// Tells the delegate when a task requires a new request body stream to send to the remote server.
    ///
    /// - parameter session:           The session containing the task that needs a new body stream.
    /// - parameter task:              The task that needs a new body stream.
    /// - parameter completionHandler: A completion handler that your delegate method should call with the new body stream.
    open func urlSession(
        _ session: URLSession,
        task: URLSessionTask,
        needNewBodyStream completionHandler: @escaping (InputStream?) -> Void)
    {
        guard taskNeedNewBodyStreamWithCompletion == nil else {
            taskNeedNewBodyStreamWithCompletion?(session, task, completionHandler)
            return
        }

        if let taskNeedNewBodyStream = taskNeedNewBodyStream {
            completionHandler(taskNeedNewBodyStream(session, task))
        } else if let delegate = self[task]?.delegate {
            delegate.urlSession(session, task: task, needNewBodyStream: completionHandler)
        }
    }

    /**
     注释内容：
     定期发送，以通知upload进度。这些信息也可以作为任务的属性。
     */
    /// 定期通知代理向服务器发送正文内容的进度。
    /// Periodically informs the delegate of the progress of sending body content to the server.
    ///
    /// - parameter session:                  The session containing the data task.
    /// - parameter task:                     The data task.
    /// - parameter bytesSent:                The number of bytes sent since the last time this delegate method was called.
    /// - parameter totalBytesSent:           The total number of bytes sent so far.
    /// - parameter totalBytesExpectedToSend: The expected length of the body data.
    open func urlSession(
        _ session: URLSession,
        task: URLSessionTask,
        didSendBodyData bytesSent: Int64,
        totalBytesSent: Int64,
        totalBytesExpectedToSend: Int64)
    {
        /// 先看外面使用者是否有自己的实现，也就是实现了这个闭包回调，如果有，就走用户自己的实现逻辑，调用闭包
        /// 如果没有，就走 Delegate转发，交给 Alamofire框架内部默认实现来处理
        if let taskDidSendBodyData = taskDidSendBodyData {
            taskDidSendBodyData(session, task, bytesSent, totalBytesSent, totalBytesExpectedToSend)
            /// ToCompare("看看新版里下方代码的写法有没有优化🏷")
        } else if let delegate = self[task]?.delegate as? UploadTaskDelegate {
            /// 通过 URLSessionDataTask 拿到 UploadRequest，将事件转发给对应的 UploadRequest 对象的deletate去处理对应的逻辑
            delegate.URLSession(
                session,
                task: task,
                didSendBodyData: bytesSent,
                totalBytesSent: totalBytesSent,
                totalBytesExpectedToSend: totalBytesExpectedToSend
            )
        }
    }

#if !os(watchOS)

    /// Tells the delegate that the session finished collecting metrics for the task.
    ///
    /// - parameter session: The session collecting the metrics.
    /// - parameter task:    The task whose metrics have been collected.
    /// - parameter metrics: The collected metrics.
    @available(iOS 10.0, macOS 10.12, tvOS 10.0, *)
    @objc(URLSession:task:didFinishCollectingMetrics:)
    open func urlSession(_ session: URLSession, task: URLSessionTask, didFinishCollecting metrics: URLSessionTaskMetrics) {
        self[task]?.delegate.metrics = metrics
    }

#endif

    /**
     注释内容：
     作为与特定任务相关的最后一条消息发送。Error可以是nil，表示没有发生错误，任务完成。
     */
    /// Tells the delegate that the task finished transferring data.
    /// 告诉委托任务已完成传输数据。
    ///
    /// - parameter session: The session containing the task whose request finished transferring data.
    /// - parameter task:    The task whose request finished transferring data.
    /// - parameter error:   If an error occurred, an error object indicating how the transfer failed, otherwise nil.
    open func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        /// Executed after it is determined that the request is not going to be retried
        /// 在确定不会重试请求之后执行 下面这个 completeTask 闭包
        let completeTask: (URLSession, URLSessionTask, Error?) -> Void = { [weak self] session, task, error in
            guard let strongSelf = self else { return }
            
            /**
             这里跟其他地方（其他地方2者是if else的关系，只会走一个）不一样的是，这里2个逻辑都走了：
             - 这里既会调用 外面的闭包
             - 也会调用 request.delegate 的方法，来处理Alamofire内部的默认实现逻辑（也就是处理Response回调，框架内部必须实现的逻辑）
             */
            /// 执行闭包回调告诉外界
            strongSelf.taskDidComplete?(session, task, error)

            /// 通过 URLSessionDataTask 拿到 Request，将事件转发给对应的 Request 对象的deletate去处理对应的逻辑
            /// 告诉Request他任务完成，从而处理Response回调逻辑
            strongSelf[task]?.delegate.urlSession(session, task: task, didCompleteWithError: error)

            var userInfo: [String: Any] = [Notification.Key.Task: task]

            if let data = (strongSelf[task]?.delegate as? DataTaskDelegate)?.data {
                userInfo[Notification.Key.ResponseData] = data
            }

            NotificationCenter.default.post(
                name: Notification.Name.Task.DidComplete,
                object: strongSelf,
                userInfo: userInfo
            )
            /// 移除 task 与 Request的绑定关系
            strongSelf[task] = nil
        }

        guard let request = self[task], let sessionManager = sessionManager else {
            completeTask(session, task, error)
            return
        }

        // Run all validations on the request before checking if an error occurred
        request.validations.forEach { $0() }

        // Determine whether an error has occurred
        var error: Error? = error

        if request.delegate.error != nil {
            error = request.delegate.error
        }

        /// 如果发生错误并且设置了检索器，异步询问检索器是否应该重试请求。否则，通过通知任务委托来完成任务。
        /// If an error occurred and the retrier is set, asynchronously ask the retrier if the request
        /// should be retried. Otherwise, complete the task by notifying the task delegate.
        if let retrier = retrier, let error = error {
            retrier.should(sessionManager, retry: request, with: error) { [weak self] shouldRetry, timeDelay in
                guard shouldRetry else { completeTask(session, task, error) ; return }

                DispatchQueue.utility.after(timeDelay) { [weak self] in
                    guard let strongSelf = self else { return }

                    let retrySucceeded = strongSelf.sessionManager?.retry(request) ?? false

                    if retrySucceeded, let task = request.task {
                        strongSelf[task] = request
                        return
                    } else {
                        completeTask(session, task, error)
                    }
                }
            }
        } else {
            completeTask(session, task, error)
        }
    }
}

// MARK: - URLSessionDataDelegate

/// URLSessionDataDelegate协议是继承URLSessionTaskDelegate协议的； URLSessionDataDelegate : URLSessionTaskDelegate
extension SessionDelegate: URLSessionDataDelegate {
    
    /**
     注释内容：
     任务已经收到响应，并且在调用completion块之前不会再收到其他消息。配置允许您取消请求或将数据任务转换为ownload任务。
     此委托消息是可选的——如果您没有实现它，则可以将响应作为任务的属性。
     他的方法不会被后台上传任务(不能转换为下载任务)调用。
     */
    /// 告诉委托数据任务收到了来自服务器的初始回复(标头)。
    /// Tells the delegate that the data task received the initial reply (headers) from the server.
    ///
    /// - parameter session:           The session containing the data task that received an initial reply.
    /// - parameter dataTask:          The data task that received an initial reply.
    /// - parameter response:          A URL response object populated with headers.
    /// - parameter completionHandler: A completion handler that your code calls to continue the transfer, passing a
    ///                                constant to indicate whether the transfer should continue as a data task or
    ///                                should become a download task.
    open func urlSession(
        _ session: URLSession,
        dataTask: URLSessionDataTask,
        didReceive response: URLResponse,
        completionHandler: @escaping (URLSession.ResponseDisposition) -> Void)
    {
        /// 实现里可以看出，这里提供了 2个闭包来通知外界，为什么是2个呢？不重复了吗？（猜测写法2是写法1的升级优化版本）
        /// 讨论2中写法的话，写法2显然更优秀：
        /// - 写法1将决定权完全交给外界，最终completionHandler闭包也传给了外界，
        /// 问题就是如果外界实现了 dataTaskDidReceiveResponseWithCompletion 闭包，但是却没有调用 completionHandler，那结果就不对了
        /// 因为 completionHandler是必须调用的；
        guard dataTaskDidReceiveResponseWithCompletion == nil else {
            dataTaskDidReceiveResponseWithCompletion?(session, dataTask, response, completionHandler)
            return
        }

        var disposition: URLSession.ResponseDisposition = .allow
        
        /// 写法2的闭包就没有这个问题，因为这里获取的本身也就是一个同步的结果，所以不需要将completionHandler闭包暴漏出去，
        /// 只需要让外界返回 ResponseDisposition 这个结果就行了，这也是这里需要的；
        /// 写法1的问题在于暴漏给外界太多信息，更灵活但是也不安全；
        /// 写法2外界不需要的信息不暴漏，completionHandler逻辑写在了当前方法内部实现，更合理；
        /// 但是如果 completionHandler 的逻辑是个异步的，写法2就不行了，就需要写法1，将 completionHandler 暴漏出去
        if let dataTaskDidReceiveResponse = dataTaskDidReceiveResponse {
            disposition = dataTaskDidReceiveResponse(session, dataTask, response)
        }

        completionHandler(disposition)
    }

    /**
     注释内容：
     通知数据任务已成为download task。以后不会有任何消息发送到data Task。
     */
    /// 告诉委托数据任务已更改为下载任务。
    /// Tells the delegate that the data task was changed to a download task.
    ///
    /// - parameter session:      The session containing the task that was replaced by a download task.
    /// - parameter dataTask:     The data task that was replaced by a download task.
    /// - parameter downloadTask: The new download task that replaced the data task.
    open func urlSession(
        _ session: URLSession,
        dataTask: URLSessionDataTask,
        didBecome downloadTask: URLSessionDownloadTask)
    {
        if let dataTaskDidBecomeDownloadTask = dataTaskDidBecomeDownloadTask {
            dataTaskDidBecomeDownloadTask(session, dataTask, downloadTask)
        } else {
            /// 更改为 DownloadTask之后，在这里更新 Request对应的 TaskDelegate 为 DownloadTaskDelegate
            self[downloadTask]?.delegate = DownloadTaskDelegate(task: downloadTask)
        }
    }

    /**
     注释内容：
     当委托可以使用数据时发送。由于数据可能是不连续的，你应该使用[NSData enumerateByteRangesUsingBlock:]来访问它。
     */
    /// 告诉委托数据任务已收到一些预期的数据。
    /// Tells the delegate that the data task has received some of the expected data.
    ///
    /// - parameter session:  The session containing the data task that provided data.
    /// - parameter dataTask: The data task that provided data.
    /// - parameter data:     A data object containing the transferred data.
    open func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        /// 先看外面使用者是否有自己的实现，也就是实现了这个闭包回调，如果有，就走用户自己的实现逻辑，调用闭包
        /// 如果没有，就走 Delegate转发，交给 Alamofire框架内部默认实现来处理
        if let dataTaskDidReceiveData = dataTaskDidReceiveData {
            dataTaskDidReceiveData(session, dataTask, data)
        } else if let delegate = self[dataTask]?.delegate as? DataTaskDelegate {
            /// 通过 URLSessionDataTask 拿到 DataRequest，将事件转发给对应的 DataRequest 对象的deletate去处理对应的逻辑
            delegate.urlSession(session, dataTask: dataTask, didReceive: data)
        }
    }

    /**
     注释内容：
     使用有效的NSCachedURLResponse调用完成例程，以允许结果数据被缓存，或者传递nil以防止缓存。
     请注意，不能保证会对给定的资源尝试缓存，您不应该依赖此消息来接收资源数据。
     */
    /// 询问委托数据(或上传)任务是否应该将响应存储在缓存中。
    /// Asks the delegate whether the data (or upload) task should store the response in the cache.
    ///
    /// - parameter session:           The session containing the data (or upload) task.
    /// - parameter dataTask:          The data (or upload) task.
    /// - parameter proposedResponse:  The default caching behavior. This behavior is determined based on the current
    ///                                caching policy and the values of certain received headers, such as the Pragma
    ///                                and Cache-Control headers.
    /// - parameter completionHandler: A block that your handler must call, providing either the original proposed
    ///                                response, a modified version of that response, or NULL to prevent caching the
    ///                                response. If your delegate implements this method, it must call this completion
    ///                                handler; otherwise, your app leaks memory.
    open func urlSession(
        _ session: URLSession,
        dataTask: URLSessionDataTask,
        willCacheResponse proposedResponse: CachedURLResponse,
        completionHandler: @escaping (CachedURLResponse?) -> Void)
    {
        /// 这里2种闭包写法的，问题分析跟前面的 didReceive response: URLResponse 方法中2种闭包写法的分析是一样的；
        /// 应该是 写法2是写法1的优化升级
        guard dataTaskWillCacheResponseWithCompletion == nil else {
            dataTaskWillCacheResponseWithCompletion?(session, dataTask, proposedResponse, completionHandler)
            return
        }

        /// 先看外面使用者是否有自己的实现，也就是实现了这个闭包回调，如果有，就走用户自己的实现逻辑，调用闭包
        /// 如果没有，就走 Delegate转发，交给 Alamofire框架内部默认实现来处理
        if let dataTaskWillCacheResponse = dataTaskWillCacheResponse {
            completionHandler(dataTaskWillCacheResponse(session, dataTask, proposedResponse))
        } else if let delegate = self[dataTask]?.delegate as? DataTaskDelegate {
            /// 通过 URLSessionDataTask 拿到 DataRequest，将事件转发给对应的 DataRequest 对象的deletate去处理对应的逻辑
            delegate.urlSession(
                session,
                dataTask: dataTask,
                willCacheResponse: proposedResponse,
                completionHandler: completionHandler
            )
        } else {
            completionHandler(proposedResponse)
        }
    }
}

// MARK: - URLSessionDownloadDelegate

/// URLSessionDownloadDelegate继承自URLSessionTaskDelegate协议，URLSessionDownloadDelegate : URLSessionTaskDelegate
extension SessionDelegate: URLSessionDownloadDelegate {
    /**
     注释内容：
     当下载任务完成下载时发送。委托应将给定位置的文件复制或移动到新位置，因为委托消息返回时文件将被删除。
     URLSession:task:didCompleteWithError:仍然会被调用。
     */
    /// 告诉委托下载任务已完成下载。
    /// Tells the delegate that a download task has finished downloading.
    ///
    /// - parameter session:      The session containing the download task that finished.
    /// - parameter downloadTask: The download task that finished.
    /// - parameter location:     A file URL for the temporary file. Because the file is temporary, you must either
    ///                           open the file for reading or move it to a permanent location in your app’s sandbox
    ///                           container directory before returning from this delegate method.
    open func urlSession(
        _ session: URLSession,
        downloadTask: URLSessionDownloadTask,
        didFinishDownloadingTo location: URL)
    {
        /// 先看外面使用者是否有自己的实现，也就是实现了这个闭包回调，如果有，就走用户自己的实现逻辑，调用闭包
        /// 如果没有，就走 Delegate转发，交给 Alamofire框架内部默认实现来处理
        if let downloadTaskDidFinishDownloadingToURL = downloadTaskDidFinishDownloadingToURL {
            downloadTaskDidFinishDownloadingToURL(session, downloadTask, location)
        } else if let delegate = self[downloadTask]?.delegate as? DownloadTaskDelegate {
            /// 通过 URLSessionDataTask 拿到 DownloadRequest，将事件转发给对应的 DownloadRequest 对象的deletate去处理对应的逻辑
            delegate.urlSession(session, downloadTask: downloadTask, didFinishDownloadingTo: location)
        }
    }

    /// 定期通知委托下载的进度。
    /// Periodically informs the delegate about the download’s progress.
    ///
    /// - parameter session:                   The session containing the download task.
    /// - parameter downloadTask:              The download task.
    /// - parameter bytesWritten:              The number of bytes transferred since the last time this delegate
    ///                                        method was called.
    /// - parameter totalBytesWritten:         The total number of bytes transferred so far.
    /// - parameter totalBytesExpectedToWrite: The expected length of the file, as provided by the Content-Length
    ///                                        header. If this header was not provided, the value is
    ///                                        `NSURLSessionTransferSizeUnknown`.
    open func urlSession(
        _ session: URLSession,
        downloadTask: URLSessionDownloadTask,
        didWriteData bytesWritten: Int64,
        totalBytesWritten: Int64,
        totalBytesExpectedToWrite: Int64)
    {
        /// 先看外面使用者是否有自己的实现，也就是实现了这个闭包回调，如果有，就走用户自己的实现逻辑，调用闭包
        /// 如果没有，就走 Delegate转发，交给 Alamofire框架内部默认实现来处理
        if let downloadTaskDidWriteData = downloadTaskDidWriteData {
            downloadTaskDidWriteData(session, downloadTask, bytesWritten, totalBytesWritten, totalBytesExpectedToWrite)
        } else if let delegate = self[downloadTask]?.delegate as? DownloadTaskDelegate {
            /// 通过 URLSessionDataTask 拿到 DownloadRequest，将事件转发给对应的 DownloadRequest 对象的deletate去处理对应的逻辑
            delegate.urlSession(
                session,
                downloadTask: downloadTask,
                didWriteData: bytesWritten,
                totalBytesWritten: totalBytesWritten,
                totalBytesExpectedToWrite: totalBytesExpectedToWrite
            )
        }
    }

    /**
     注释内容：
     当下载被恢复时发送。如果下载失败并报错，错误所在的-userInfo字典将包含一个NSURLSessionDownloadTaskResumeData键，它的值是resume数据。
     */
    /// 告诉委托下载任务已恢复下载。
    /// Tells the delegate that the download task has resumed downloading.
    ///
    /// - parameter session:            The session containing the download task that finished.
    /// - parameter downloadTask:       The download task that resumed. See explanation in the discussion.
    /// - parameter fileOffset:         If the file's cache policy or last modified date prevents reuse of the
    ///                                 existing content, then this value is zero. Otherwise, this value is an
    ///                                 integer representing the number of bytes on disk that do not need to be
    ///                                 retrieved again.
    /// - parameter expectedTotalBytes: The expected length of the file, as provided by the Content-Length header.
    ///                                 If this header was not provided, the value is NSURLSessionTransferSizeUnknown.
    open func urlSession(
        _ session: URLSession,
        downloadTask: URLSessionDownloadTask,
        didResumeAtOffset fileOffset: Int64,
        expectedTotalBytes: Int64)
    {
        /// 先看外面使用者是否有自己的实现，也就是实现了这个闭包回调，如果有，就走用户自己的实现逻辑，调用闭包
        /// 如果没有，就走 Delegate转发，交给 Alamofire框架内部默认实现来处理
        if let downloadTaskDidResumeAtOffset = downloadTaskDidResumeAtOffset {
            downloadTaskDidResumeAtOffset(session, downloadTask, fileOffset, expectedTotalBytes)
        } else if let delegate = self[downloadTask]?.delegate as? DownloadTaskDelegate {
            /// 通过 URLSessionDataTask 拿到 DownloadRequest，将事件转发给对应的 DownloadRequest 对象的deletate去处理对应的逻辑
            delegate.urlSession(
                session,
                downloadTask: downloadTask,
                didResumeAtOffset: fileOffset,
                expectedTotalBytes: expectedTotalBytes
            )
        }
    }
}

// MARK: - URLSessionStreamDelegate

#if !os(watchOS)

/// URLSessionStreamDelegat协议继承自URLSessionTaskDelegate，URLSessionStreamDelegate : URLSessionTaskDelegate
@available(iOS 9.0, macOS 10.11, tvOS 9.0, *)
extension SessionDelegate: URLSessionStreamDelegate {
    /**
     注释内容：
     表示连接的读取端已经关闭。任何优秀的读取都会完成，但以后的读取会立即失败。
     即使没有正在进行的读取，也可能会发送此消息。但是，当接收到此委托消息时，可能仍然有可用的字节。只有当您能够读取到EOF时，您才知道没有更多的字节可用。
     */
    /// 告诉委托连接的读取端已关闭。
    /// Tells the delegate that the read side of the connection has been closed.
    ///
    /// - parameter session:    The session.
    /// - parameter streamTask: The stream task.
    open func urlSession(_ session: URLSession, readClosedFor streamTask: URLSessionStreamTask) {
        streamTaskReadClosed?(session, streamTask)
    }

    /**
     注释内容：
     表示连接的写端已经关闭。
     所有未完成的写操作都已完成，但后续的写操作将立即失败。
     */
    /// 告诉委托连接的写端已经关闭。
    /// Tells the delegate that the write side of the connection has been closed.
    ///
    /// - parameter session:    The session.
    /// - parameter streamTask: The stream task.
    open func urlSession(_ session: URLSession, writeClosedFor streamTask: URLSessionStreamTask) {
        streamTaskWriteClosed?(session, streamTask)
    }

    /**
     注释内容：
     一个通知，表示系统已经检测到到主机的更好的路由(例如，wi-fi接口可用)。这是对委托的一个提示，即可能需要为后续工作创建新任务。
     请注意，不能保证未来的进程能够连接到主机，因此调用者应该做好读写任何新接口失败的准备。
     */
    /// 告诉代理系统已经确定到主机的更好的路由是可用的。
    /// Tells the delegate that the system has determined that a better route to the host is available.
    ///
    /// - parameter session:    The session.
    /// - parameter streamTask: The stream task.
    open func urlSession(_ session: URLSession, betterRouteDiscoveredFor streamTask: URLSessionStreamTask) {
        streamTaskBetterRouteDiscovered?(session, streamTask)
    }

    /**
     注释内容：
     给定的任务已经完成，并且从底层网络连接创建了未打开的NSInputStream和NSOutputStream对象。
     只有在所有排队的IO操作都完成之后(包括必要的握手)，才会调用这个方法。streamTask不会再接收任何委托消息。
     */
    /// 告诉委托流任务已完成，并提供未打开的流对象。
    /// Tells the delegate that the stream task has been completed and provides the unopened stream objects.
    ///
    /// - parameter session:      The session.
    /// - parameter streamTask:   The stream task.
    /// - parameter inputStream:  The new input stream.
    /// - parameter outputStream: The new output stream.
    open func urlSession(
        _ session: URLSession,
        streamTask: URLSessionStreamTask,
        didBecome inputStream: InputStream,
        outputStream: OutputStream)
    {
        streamTaskDidBecomeInputAndOutputStreams?(session, streamTask, inputStream, outputStream)
    }
}

#endif
