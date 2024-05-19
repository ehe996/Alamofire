//
//  MultipartFormData.swift
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

#if os(iOS) || os(watchOS) || os(tvOS)
import MobileCoreServices
#elseif os(macOS)
import CoreServices
#endif

/// Constructs `multipart/form-data` for uploads within an HTTP or HTTPS body. There are currently two ways to encode
/// multipart form data. The first way is to encode the data directly in memory. This is very efficient, but can lead
/// to memory issues if the dataset is too large. The second way is designed for larger datasets and will write all the
/// data to a single file on disk with all the proper boundary segmentation. The second approach MUST be used for
/// larger datasets such as video content, otherwise your app may run out of memory when trying to encode the dataset.
///
/// For more information on `multipart/form-data` in general, please refer to the RFC-2388 and RFC-2045 specs as well
/// and the w3 form documentation.
///
/// - https://www.ietf.org/rfc/rfc2388.txt
/// - https://www.ietf.org/rfc/rfc2045.txt
/// - https://www.w3.org/TR/html401/interact/forms.html#h-17.13
/// 多表单上传参数处理
open class MultipartFormData {
    
    // MARK: - Helper Types

    struct EncodingCharacters {
        static let crlf = "\r\n"
    }

    struct BoundaryGenerator {
        enum BoundaryType {
            case initial, encapsulated, final
        }

        static func randomBoundary() -> String {
            return String(format: "alamofire.boundary.%08x%08x", arc4random(), arc4random())
        }

        static func boundaryData(forBoundaryType boundaryType: BoundaryType, boundary: String) -> Data {
            let boundaryText: String

            switch boundaryType {
            case .initial:
                /// 加到开头
                boundaryText = "--\(boundary)\(EncodingCharacters.crlf)"
            case .encapsulated:
                /// 加到中间
                boundaryText = "\(EncodingCharacters.crlf)--\(boundary)\(EncodingCharacters.crlf)"
            case .final:
                /// 加到结尾
                boundaryText = "\(EncodingCharacters.crlf)--\(boundary)--\(EncodingCharacters.crlf)"
            }

            return boundaryText.data(using: String.Encoding.utf8, allowLossyConversion: false)!
        }
    }

    class BodyPart {
        let headers: HTTPHeaders
        let bodyStream: InputStream
        let bodyContentLength: UInt64
        var hasInitialBoundary = false
        var hasFinalBoundary = false

        init(headers: HTTPHeaders, bodyStream: InputStream, bodyContentLength: UInt64) {
            self.headers = headers
            self.bodyStream = bodyStream
            self.bodyContentLength = bodyContentLength
        }
    }

    // MARK: - Properties

    /// The `Content-Type` header value containing the boundary used to generate the `multipart/form-data`.
    open lazy var contentType: String = "multipart/form-data; boundary=\(self.boundary)"

    /// The content length of all body parts used to generate the `multipart/form-data` not including the boundaries.
    public var contentLength: UInt64 { return bodyParts.reduce(0) { $0 + $1.bodyContentLength } }

    /// 在编码表单数据中用于分离body parts 的边界
    /// The boundary used to separate the body parts in the encoded form data.
    public var boundary: String

    private var bodyParts: [BodyPart]
    private var bodyPartError: AFError?
    private let streamBufferSize: Int

    // MARK: - Lifecycle

    /// Creates a multipart form data object.
    ///
    /// - returns: The multipart form data object.
    public init() {
        self.boundary = BoundaryGenerator.randomBoundary()
        self.bodyParts = []

        ///
        /// The optimal read/write buffer size in bytes for input and output streams is 1024 (1KB). For more
        /// information, please refer to the following article:
        ///   - https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/Streams/Articles/ReadingInputStreams.html
        ///

        self.streamBufferSize = 1024
    }

    // MARK: - Body Parts

    /// Creates a body part from the data and appends it to the multipart form data object.
    ///
    /// The body part data will be encoded using the following format:
    ///
    /// - `Content-Disposition: form-data; name=#{name}` (HTTP Header)
    /// - Encoded data
    /// - Multipart form boundary
    ///
    /// - parameter data: The data to encode into the multipart form data.
    /// - parameter name: The name to associate with the data in the `Content-Disposition` HTTP header.
    public func append(_ data: Data, withName name: String) {
        let headers = contentHeaders(withName: name)
        /// ToUnderstand-❓-  待搞清楚这个数据流跟 HTTP 之间的关系，是怎样上传的
        /// 文件上传以流的形式处理
        let stream = InputStream(data: data)
        let length = UInt64(data.count)
        
        append(stream, withLength: length, headers: headers)
    }

    /// Creates a body part from the data and appends it to the multipart form data object.
    ///
    /// The body part data will be encoded using the following format:
    ///
    /// - `Content-Disposition: form-data; name=#{name}` (HTTP Header)
    /// - `Content-Type: #{generated mimeType}` (HTTP Header)
    /// - Encoded data
    /// - Multipart form boundary
    ///
    /// - parameter data:     The data to encode into the multipart form data.
    /// - parameter name:     The name to associate with the data in the `Content-Disposition` HTTP header.
    /// - parameter mimeType: The MIME type to associate with the data content type in the `Content-Type` HTTP header.
    public func append(_ data: Data, withName name: String, mimeType: String) {
        let headers = contentHeaders(withName: name, mimeType: mimeType)
        let stream = InputStream(data: data)
        let length = UInt64(data.count)

        append(stream, withLength: length, headers: headers)
    }

    /// Creates a body part from the data and appends it to the multipart form data object.
    ///
    /// The body part data will be encoded using the following format:
    ///
    /// - `Content-Disposition: form-data; name=#{name}; filename=#{filename}` (HTTP Header)
    /// - `Content-Type: #{mimeType}` (HTTP Header)
    /// - Encoded file data
    /// - Multipart form boundary
    ///
    /// - parameter data:     The data to encode into the multipart form data.
    /// - parameter name:     The name to associate with the data in the `Content-Disposition` HTTP header.
    /// - parameter fileName: The filename to associate with the data in the `Content-Disposition` HTTP header.
    /// - parameter mimeType: The MIME type to associate with the data in the `Content-Type` HTTP header.
    public func append(_ data: Data, withName name: String, fileName: String, mimeType: String) {
        let headers = contentHeaders(withName: name, fileName: fileName, mimeType: mimeType)
        let stream = InputStream(data: data)
        let length = UInt64(data.count)

        append(stream, withLength: length, headers: headers)
    }

    /// Creates a body part from the file and appends it to the multipart form data object.
    ///
    /// The body part data will be encoded using the following format:
    ///
    /// - `Content-Disposition: form-data; name=#{name}; filename=#{generated filename}` (HTTP Header)
    /// - `Content-Type: #{generated mimeType}` (HTTP Header)
    /// - Encoded file data
    /// - Multipart form boundary
    ///
    /// The filename in the `Content-Disposition` HTTP header is generated from the last path component of the
    /// `fileURL`. The `Content-Type` HTTP header MIME type is generated by mapping the `fileURL` extension to the
    /// system associated MIME type.
    ///
    /// - parameter fileURL: The URL of the file whose content will be encoded into the multipart form data.
    /// - parameter name:    The name to associate with the file content in the `Content-Disposition` HTTP header.
    public func append(_ fileURL: URL, withName name: String) {
        let fileName = fileURL.lastPathComponent
        let pathExtension = fileURL.pathExtension

        if !fileName.isEmpty && !pathExtension.isEmpty {
            let mime = mimeType(forPathExtension: pathExtension)
            append(fileURL, withName: name, fileName: fileName, mimeType: mime)
        } else {
            setBodyPartError(withReason: .bodyPartFilenameInvalid(in: fileURL))
        }
    }

    /// Creates a body part from the file and appends it to the multipart form data object.
    ///
    /// The body part data will be encoded using the following format:
    ///
    /// - Content-Disposition: form-data; name=#{name}; filename=#{filename} (HTTP Header)
    /// - Content-Type: #{mimeType} (HTTP Header)
    /// - Encoded file data
    /// - Multipart form boundary
    ///
    /// - parameter fileURL:  The URL of the file whose content will be encoded into the multipart form data.
    /// - parameter name:     The name to associate with the file content in the `Content-Disposition` HTTP header.
    /// - parameter fileName: The filename to associate with the file content in the `Content-Disposition` HTTP header.
    /// - parameter mimeType: The MIME type to associate with the file content in the `Content-Type` HTTP header.
    public func append(_ fileURL: URL, withName name: String, fileName: String, mimeType: String) {
        let headers = contentHeaders(withName: name, fileName: fileName, mimeType: mimeType)

        //============================================================
        //                 Check 1 - is file URL?
        //============================================================

        guard fileURL.isFileURL else {
            setBodyPartError(withReason: .bodyPartURLInvalid(url: fileURL))
            return
        }

        //============================================================
        //              Check 2 - is file URL reachable?
        //============================================================

        do {
            let isReachable = try fileURL.checkPromisedItemIsReachable()
            guard isReachable else {
                setBodyPartError(withReason: .bodyPartFileNotReachable(at: fileURL))
                return
            }
        } catch {
            setBodyPartError(withReason: .bodyPartFileNotReachableWithError(atURL: fileURL, error: error))
            return
        }

        //============================================================
        //            Check 3 - is file URL a directory?
        //============================================================

        var isDirectory: ObjCBool = false
        let path = fileURL.path

        guard FileManager.default.fileExists(atPath: path, isDirectory: &isDirectory) && !isDirectory.boolValue else {
            setBodyPartError(withReason: .bodyPartFileIsDirectory(at: fileURL))
            return
        }

        //============================================================
        //          Check 4 - can the file size be extracted?
        //============================================================

        let bodyContentLength: UInt64

        do {
            guard let fileSize = try FileManager.default.attributesOfItem(atPath: path)[.size] as? NSNumber else {
                setBodyPartError(withReason: .bodyPartFileSizeNotAvailable(at: fileURL))
                return
            }

            bodyContentLength = fileSize.uint64Value
        }
        catch {
            setBodyPartError(withReason: .bodyPartFileSizeQueryFailedWithError(forURL: fileURL, error: error))
            return
        }

        //============================================================
        //       Check 5 - can a stream be created from file URL?
        //============================================================

        guard let stream = InputStream(url: fileURL) else {
            setBodyPartError(withReason: .bodyPartInputStreamCreationFailed(for: fileURL))
            return
        }
        /// 这里可以看出，即使参数是文件URL，最终也转换成为了 InputStream 来处理
        append(stream, withLength: bodyContentLength, headers: headers)
    }

    /// 上面这些append方法最终都来到了这里
    /// 从流中创建主体部分，并将其附加到multipart表单数据对象。
    /// Creates a body part from the stream and appends it to the multipart form data object.
    ///
    /// The body part data will be encoded using the following format:
    ///
    /// - `Content-Disposition: form-data; name=#{name}; filename=#{filename}` (HTTP Header)
    /// - `Content-Type: #{mimeType}` (HTTP Header)
    /// - Encoded stream data
    /// - Multipart form boundary
    ///
    /// - parameter stream:   The input stream to encode in the multipart form data.
    /// - parameter length:   The content length of the stream.
    /// - parameter name:     The name to associate with the stream content in the `Content-Disposition` HTTP header.
    /// - parameter fileName: The filename to associate with the stream content in the `Content-Disposition` HTTP header.
    /// - parameter mimeType: The MIME type to associate with the stream content in the `Content-Type` HTTP header.
    public func append(
        _ stream: InputStream,
        withLength length: UInt64,
        name: String,
        fileName: String,
        mimeType: String)
    {
        let headers = contentHeaders(withName: name, fileName: fileName, mimeType: mimeType)
        append(stream, withLength: length, headers: headers)
    }

    /// Creates a body part with the headers, stream and length and appends it to the multipart form data object.
    ///
    /// The body part data will be encoded using the following format:
    ///
    /// - HTTP headers
    /// - Encoded stream data
    /// - Multipart form boundary
    ///
    /// - parameter stream:  The input stream to encode in the multipart form data.
    /// - parameter length:  The content length of the stream.
    /// - parameter headers: The HTTP headers for the body part.
    public func append(_ stream: InputStream, withLength length: UInt64, headers: HTTPHeaders) {
        /// 将这些参数封装成一个对象
        let bodyPart = BodyPart(headers: headers, bodyStream: stream, bodyContentLength: length)
        /// 装入 bodyParts 数组容器中，等待后面编码成为data
        bodyParts.append(bodyPart)
    }

    // MARK: - Data Encoding

    /// 这个方法将 bodyParts数组 转换成 data
    /// Encodes all the appended body parts into a single `Data` value.
    ///
    /// It is important to note that this method will load all the appended body parts into memory all at the same
    /// time. This method should only be used when the encoded data will have a small memory footprint. For large data
    /// cases, please use the `writeEncodedDataToDisk(fileURL:completionHandler:)` method.
    ///
    /// - throws: An `AFError` if encoding encounters an error.
    ///
    /// - returns: The encoded `Data` if encoding is successful.
    public func encode() throws -> Data {
        if let bodyPartError = bodyPartError {
            throw bodyPartError
        }

        var encoded = Data()

        bodyParts.first?.hasInitialBoundary = true
        bodyParts.last?.hasFinalBoundary = true

        /// 遍历 bodyParts，然后将里面的封装的元素转换 data，然后data拼接到一起
        for bodyPart in bodyParts {
            /// 转成data的关键就在下面这个 encode 方法的调用
            let encodedData = try encode(bodyPart)
            encoded.append(encodedData)
        }

        return encoded
    }

    /// 将附加的正文部分写入给定的文件URL。
    /// 这个过程可以通过读写输入流和输出流来实现。因此，这种方法非常节省内存，应该用于大型 body part数据。
    /// Writes the appended body parts into the given file URL.
    ///
    /// This process is facilitated by reading and writing with input and output streams, respectively. Thus,
    /// this approach is very memory efficient and should be used for large body part data.
    ///
    /// - parameter fileURL: The file URL to write the multipart form data into.
    ///
    /// - throws: An `AFError` if encoding encounters an error.
    public func writeEncodedData(to fileURL: URL) throws {
        if let bodyPartError = bodyPartError {
            throw bodyPartError
        }

        if FileManager.default.fileExists(atPath: fileURL.path) {
            throw AFError.multipartEncodingFailed(reason: .outputStreamFileAlreadyExists(at: fileURL))
        } else if !fileURL.isFileURL {
            throw AFError.multipartEncodingFailed(reason: .outputStreamURLInvalid(url: fileURL))
        }

        guard let outputStream = OutputStream(url: fileURL, append: false) else {
            throw AFError.multipartEncodingFailed(reason: .outputStreamCreationFailed(for: fileURL))
        }

        outputStream.open()
        defer { outputStream.close() }

        self.bodyParts.first?.hasInitialBoundary = true
        self.bodyParts.last?.hasFinalBoundary = true

        for bodyPart in self.bodyParts {
            try write(bodyPart, to: outputStream)
        }
    }

    // MARK: - Private - Body Part Encoding

    /// 将 BodyPart 转化成为值定格式的 data
    private func encode(_ bodyPart: BodyPart) throws -> Data {
        var encoded = Data()

        /// 开始按固定格式拼接，也就是将 BodyPart 转换成固定格式 data
        let initialData = bodyPart.hasInitialBoundary ? initialBoundaryData() : encapsulatedBoundaryData()
        
        /// 拼接初始信息，头或者中间
        encoded.append(initialData)

        /// 拼接header
        let headerData = encodeHeaders(for: bodyPart)
        encoded.append(headerData)

        /// 拼接 stream data数据
        let bodyStreamData = try encodeBodyStream(for: bodyPart)
        encoded.append(bodyStreamData)

        /// 如果是结尾，再拼接结尾数据
        if bodyPart.hasFinalBoundary {
            encoded.append(finalBoundaryData())
        }

        return encoded
    }

    /// 将header 转换成为 data
    private func encodeHeaders(for bodyPart: BodyPart) -> Data {
        var headerText = ""
        /// 拼接header 信息
        for (key, value) in bodyPart.headers {
            headerText += "\(key): \(value)\(EncodingCharacters.crlf)"
        }
        headerText += EncodingCharacters.crlf

        return headerText.data(using: String.Encoding.utf8, allowLossyConversion: false)!
    }

    /// 从stream中读取所有数据，然后返回
    private func encodeBodyStream(for bodyPart: BodyPart) throws -> Data {
        let inputStream = bodyPart.bodyStream
        inputStream.open()
        defer { inputStream.close() }

        var encoded = Data()

        /// ToUnderstand-❓-
        /// 这里我理解的是，打开 stream之后，然后每次读取 streamBufferSize 大小的数据，然后拼接起来
        /// 不理解的是：这样如果是一个很大的文件，那么最终拼接完整的这个data不就会很大吗？不会非常占用内存吗？
        ///
        /// 解答：注意看下面的buffer，在创建的时候申请的空间大小已经限制在了 streamBufferSize，
        /// 每次从 stream中读取数据大小不超过streamBufferSize
        while inputStream.hasBytesAvailable {
            var buffer = [UInt8](repeating: 0, count: streamBufferSize)
            let bytesRead = inputStream.read(&buffer, maxLength: streamBufferSize)

            if let error = inputStream.streamError {
                throw AFError.multipartEncodingFailed(reason: .inputStreamReadFailed(error: error))
            }

            if bytesRead > 0 {
                encoded.append(buffer, count: bytesRead)
            } else {
                break
            }
        }

        return encoded
    }

    // MARK: - Private - Writing Body Part to Output Stream

    private func write(_ bodyPart: BodyPart, to outputStream: OutputStream) throws {
        /// 按顺序将各个部分的data写入 outputStream
        try writeInitialBoundaryData(for: bodyPart, to: outputStream)
        try writeHeaderData(for: bodyPart, to: outputStream)
        try writeBodyStream(for: bodyPart, to: outputStream)
        try writeFinalBoundaryData(for: bodyPart, to: outputStream)
    }

    private func writeInitialBoundaryData(for bodyPart: BodyPart, to outputStream: OutputStream) throws {
        let initialData = bodyPart.hasInitialBoundary ? initialBoundaryData() : encapsulatedBoundaryData()
        return try write(initialData, to: outputStream)
    }

    private func writeHeaderData(for bodyPart: BodyPart, to outputStream: OutputStream) throws {
        let headerData = encodeHeaders(for: bodyPart)
        return try write(headerData, to: outputStream)
    }

    private func writeBodyStream(for bodyPart: BodyPart, to outputStream: OutputStream) throws {
        let inputStream = bodyPart.bodyStream

        inputStream.open()
        defer { inputStream.close() }

        /// 从 inputStream 中每次读取 streamBufferSize 大小的数据，然后写入 outputStream 中
        /// 分片读取，然后写入本地，节省内存
        while inputStream.hasBytesAvailable {
            var buffer = [UInt8](repeating: 0, count: streamBufferSize)
            let bytesRead = inputStream.read(&buffer, maxLength: streamBufferSize)

            if let streamError = inputStream.streamError {
                throw AFError.multipartEncodingFailed(reason: .inputStreamReadFailed(error: streamError))
            }

            if bytesRead > 0 {
                if buffer.count != bytesRead {
                    buffer = Array(buffer[0..<bytesRead])
                }

                try write(&buffer, to: outputStream)
            } else {
                break
            }
        }
    }

    private func writeFinalBoundaryData(for bodyPart: BodyPart, to outputStream: OutputStream) throws {
        if bodyPart.hasFinalBoundary {
            return try write(finalBoundaryData(), to: outputStream)
        }
    }

    // MARK: - Private - Writing Buffered Data to Output Stream

    private func write(_ data: Data, to outputStream: OutputStream) throws {
        var buffer = [UInt8](repeating: 0, count: data.count)
        data.copyBytes(to: &buffer, count: data.count)

        return try write(&buffer, to: outputStream)
    }

    /// 将 buffer 中的数据，通过 outputStream 写入本地
    private func write(_ buffer: inout [UInt8], to outputStream: OutputStream) throws {
        var bytesToWrite = buffer.count

        while bytesToWrite > 0, outputStream.hasSpaceAvailable {
            let bytesWritten = outputStream.write(buffer, maxLength: bytesToWrite)

            if let error = outputStream.streamError {
                throw AFError.multipartEncodingFailed(reason: .outputStreamWriteFailed(error: error))
            }

            bytesToWrite -= bytesWritten

            if bytesToWrite > 0 {
                buffer = Array(buffer[bytesWritten..<buffer.count])
            }
        }
    }

    // MARK: - Private - Mime Type
    /// 关于MIME的详细信息，在本页最底部

    /// 用于根据文件扩展名（pathExtension）获取相应的 MIME 类型（即 Multipurpose Internet Mail Extensions 类型）。
    ///
    /// 这个方法的目的是根据文件扩展名获取相应的 MIME 类型。如果成功获取到了对应的 MIME 类型，则返回该类型；
    /// 否则，返回默认的 application/octet-stream 类型。这个方法利用了 Core Foundation 框架中与文件类型识别相关的函数来实现这一功能
    public func mimeType(forPathExtension pathExtension: String) -> String {
        /// UTTypeCreatePreferredIdentifierForTag: 这个方法尝试根据给定的文件扩展名创建一个与之相关的
        /// 统一类型标识符（Uniform Type Identifier，UTI）。如果成功，它返回一个可选类型的标识符。
        ///
        /// UTTypeCopyPreferredTagWithClass: 这个方法尝试根据给定的 UTI 获取与之相关的 MIME 类型。
        /// 如果成功，它返回一个可选类型的 MIME 类型。
        if
            let id = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, pathExtension as CFString, nil)?.takeRetainedValue(),
            let contentType = UTTypeCopyPreferredTagWithClass(id, kUTTagClassMIMEType)?.takeRetainedValue()
        {
            print("pathExtension=\(pathExtension) ___ id=\(id) ___ contentType=\(contentType)")
            /**
             这里测试结果如下：
             pathExtension=png ___ id=public.png ___ contentType=image/png
             pathExtension=mp3 ___ id=public.mp3 ___ contentType=audio/mpeg
             pathExtension=mp4 ___ id=public.mpeg-4 ___ contentType=video/mp4
             pathExtension=text ___ id=public.plain-text ___ contentType=text/plain
             pathExtension=json ___ id=public.json ___ contentType=application/json
             pathExtension=pdf ___ id=com.adobe.pdf ___ contentType=application/pdf
             */
            return contentType as String
        }
        
        return "application/octet-stream"
    }

    // MARK: - Private - Content Headers

    private func contentHeaders(withName name: String, fileName: String? = nil, mimeType: String? = nil) -> [String: String] {
        var disposition = "form-data; name=\"\(name)\""
        if let fileName = fileName { disposition += "; filename=\"\(fileName)\"" }
        /// 设置文件上传的请求头
        var headers = ["Content-Disposition": disposition]
        if let mimeType = mimeType { headers["Content-Type"] = mimeType }

        return headers
    }

    // MARK: - Private - Boundary Encoding

    private func initialBoundaryData() -> Data {
        return BoundaryGenerator.boundaryData(forBoundaryType: .initial, boundary: boundary)
    }

    private func encapsulatedBoundaryData() -> Data {
        return BoundaryGenerator.boundaryData(forBoundaryType: .encapsulated, boundary: boundary)
    }

    private func finalBoundaryData() -> Data {
        return BoundaryGenerator.boundaryData(forBoundaryType: .final, boundary: boundary)
    }

    // MARK: - Private - Errors

    private func setBodyPartError(withReason reason: AFError.MultipartEncodingFailureReason) {
        guard bodyPartError == nil else { return }
        bodyPartError = AFError.multipartEncodingFailed(reason: reason)
    }
}

/**
 每个MIME类型由两部分组成，前面是数据的大类别，例如声音audio、图象image等，后面定义具体的种类。
 七种大类别：
 video
 image
 application
 text
 audio
 multipart
 message
 
 常见的MIME类型(通用型)：
 超文本标记语言文本 .html text/html
 xml文档 .xml text/xml
 XHTML文档 .xhtml application/xhtml+xml
 普通文本 .txt text/plain
 RTF文本 .rtf application/rtf
 PDF文档 .pdf application/pdf
 Microsoft Word文件 .word application/msword
 PNG图像 .png image/png
 GIF图形 .gif image/gif
 JPEG图形 .jpeg,.jpg image/jpeg
 au声音文件 .au audio/basic
 MIDI音乐文件 mid,.midi audio/midi,audio/x-midi
 RealAudio音乐文件 .ra, .ram audio/x-pn-realaudio
 MPEG文件 .mpg,.mpeg video/mpeg
 AVI文件 .avi video/x-msvideo
 GZIP文件 .gz application/x-gzip
 TAR文件 .tar application/x-tar
 任意的二进制数据 application/octet-stream
 
 
 
 MIME（Multipurpose Internet Mail Extensions）是一种在互联网上广泛使用的标准，用于表示多用途 Internet 邮件扩展。除了在电子邮件中使用外，MIME 类型也被用于 HTTP 协议中，用于标识和传输数据的类型。以下是关于 MIME 的一些详细信息：

 ### MIME 类型格式

 MIME 类型通常由两部分组成：主类型（top-level type）和子类型（sub-type），中间用斜杠分隔。例如，`text/html` 中的 `text` 是主类型，`html` 是子类型。主类型表示数据的大类，而子类型则更具体地描述数据的类型。一些常见的 MIME 类型包括：

 - `text/plain`: 纯文本
 - `text/html`: HTML 文档
 - `image/jpeg`: JPEG 图像
 - `application/json`: JSON 数据
 - `application/pdf`: PDF 文件
 - `audio/mp3`: MP3 音频文件
 - `video/mp4`: MP4 视频文件

 ### MIME 类型的作用

 1. **传输数据类型**: 在 HTTP 协议中，MIME 类型用于标识传输的数据类型，服务器和客户端可以根据 MIME 类型来解析数据。

 2. **浏览器行为控制**: 浏览器可以根据接收到的 MIME 类型来决定如何处理数据，比如显示图像、下载文件等。

 3. **文件格式标识**: MIME 类型也用于标识文件的格式，帮助应用程序识别文件类型并选择正确的处理方式。

 ### MIME 类型的重要性

 - **安全性**: MIME 类型有助于防止恶意软件通过伪装文件类型来欺骗用户。
   
 - **互操作性**: 使用标准的 MIME 类型有助于不同系统和应用程序之间的互操作性，确保数据能够正确解析和显示。

 - **Web 开发**: 在 Web 开发中，正确设置 HTTP 响应的 MIME 类型可以确保浏览器正确解释页面内容，避免出现错误或安全问题。

 总的来说，MIME 类型是一种标准化的方式，用于描述和标识数据的类型，对于互联网通信和数据传输非常重要。
 */
