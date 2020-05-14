//
//  FileManage.swift
//  FileManage
//
//  Created by piyush sinroja on 14/05/20.
//  Copyright © 2018 piyush. All rights reserved.
//

import Foundation
import UIKit

/// filemange class is used to manage file opearation related stuff
class FileManage: NSObject {
    
    // MARK: - Documents Directory
    ///Document Directory
    class func documentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    // MARK: - Check File Exist In Document Directory
    class func isFileExistDocumentDir(fileName: String?, directoryName: String?) -> (Bool, URL?) {
        guard let fileNewName = fileName, let dirName = directoryName else {
            return (false, nil)
        }
        let documentsPath = FileManage.documentsDirectory().appendingPathComponent(dirName)
        let file = documentsPath.appendingPathComponent(fileNewName)
        let fileExists = FileManager.default.fileExists(atPath: file.path)
        return (fileExists, file)
    }
    
    class func isFileExistDocumentDir(fileName: String?) -> (Bool, URL?) {
         guard let fileNewName = fileName else {
         return (false, nil)
        }
        let documentsPath = FileManage.documentsDirectory().appendingPathComponent(fileNewName)
        let fileExists = FileManager.default.fileExists(atPath: documentsPath.path)
        return (fileExists, documentsPath)
    }
    
    // MARK: - Remove From Document Directory
    class func removeAllFilesFromDocumentDirectory(subFolder: [String]) {
        var documentDirectory = FileManage.documentsDirectory()
        if subFolder.count > 0 {
            for folderName in subFolder {
                documentDirectory = documentDirectory.appendingPathComponent(folderName)
                removeFromDocumentDirectory(documentDirectory: documentDirectory)
            }
        } else {
            removeFromDocumentDirectory(documentDirectory: documentDirectory)
        }
    }
    
    /// remove single file from document dir
    /// - Parameter fileName: filename which you want to remove
    class func removeSingleFileFromDocumentDir(fileName: String) {
        let documentDirectory = FileManage.documentsDirectory()
        removeFileFromDocumentDirectory(documentDirectory: documentDirectory, path: fileName)
    }
    
    /// remove file from document dir
    /// - Parameters:
    ///   - documentDirectory: document dir path
    ///   - path: path in string
    fileprivate class func removeFileFromDocumentDirectory(documentDirectory: URL, path: String) {
        let fileManager = FileManager.default
        let deletePath = documentDirectory.appendingPathComponent(path)
        do {
            try fileManager.removeItem(at: deletePath)
        } catch {
            // Non-fatal: file probably doesn't exist
        }
    }
    
    /// remove all file from document dir
    /// - Parameter documentDirectory: document dir url
    fileprivate class func removeFromDocumentDirectory(documentDirectory: URL)  {
        let fileManager = FileManager.default
        do {
            let fileUrls = try fileManager.contentsOfDirectory(atPath: documentDirectory.path)
            for path in fileUrls {
                removeFileFromDocumentDirectory(documentDirectory: documentDirectory, path: path)
            }
        } catch {
            print("Error while enumerating files \(documentDirectory.path): \(error.localizedDescription)")
        }
    }
    
    // MARK: - Save Image To Document Directory
    class func saveImgToDocumentDir(imgName: String, img: UIImage, compressionQuality: CGFloat) -> String? {
        let documentsPath = FileManage.documentsDirectory()
        var filepath: String? = nil
        let fileURL = documentsPath.appendingPathComponent(imgName)
        if let data = img.jpegData(compressionQuality: compressionQuality) {
            if !FileManager.default.fileExists(atPath: fileURL.path) {
                do {
                    try data.write(to: fileURL)
                    print("img saved")
                    filepath = fileURL.path
                } catch {
                    print("error saving image:", error)
                }
            } else {
                filepath = fileURL.path
            }
        }
        return filepath
    }
    
    // MARK: - Create Folder To Document Directory
    class func createFolderInDocumentDir(folderName: String) -> URL? {
        let fileManager = FileManager.default
        let documentDirectory = FileManage.documentsDirectory()
        let filePath = documentDirectory.appendingPathComponent(folderName)
        if !fileManager.fileExists(atPath: filePath.path) {
            do {
                try fileManager.createDirectory(atPath: filePath.path, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print(error.localizedDescription)
                return nil
            }
        }
        return filePath
    }
    
    // MARK: - All File List From Document Directory
    class func allFileListFromDocumentDir(whichExtension: String?) -> [URL]? {
        let fileManager = FileManager.default
        let documentDirectory = FileManage.documentsDirectory()
        do {
            let fileUrls = try fileManager.contentsOfDirectory(at: documentDirectory, includingPropertiesForKeys: nil, options: [])
            if let pathExtension = whichExtension {
                let specificFiles = fileUrls.filter{ $0.pathExtension == pathExtension }
                return specificFiles
            } else {
                return fileUrls
            }
        } catch {
            print("Error while enumerating files \(documentDirectory.path): \(error.localizedDescription)")
            return nil
        }
    }
    
    // MARK: - Create File To Document Directory
   class func createTextFileToDocumentDirectory(text: String, fileNameWithExtension: String) -> Bool {
        let documentsDirectory = FileManage.documentsDirectory()
        let fileURL = documentsDirectory.appendingPathComponent(fileNameWithExtension)
        do {
            try text.write(to: fileURL, atomically: false, encoding: .utf8)
            return true
        } catch { return false }
    }
    
    // MARK: - Read File From Document Directory
    class func readTextFileFromDocumentDirectory(fileNameWithExtension: String) -> String? {
        var urlPath: URL?
        var isExist: Bool = false
        var strText: String?
        (isExist, urlPath) = FileManage.isFileExistDocumentDir(fileName: fileNameWithExtension)
        if isExist {
            do {
                strText = try String(contentsOf: urlPath!, encoding: .utf8)
            }
            catch {/* error handling here */}
        }
        return strText
    }
    
    // MARK: - Copy File From Bundle To Document Directory
    class func copyFileFromBundleToDocumentDir(sourceName: String, sourceExtension: String) -> Bool {
        let fileManager = FileManager.default
        guard let bundleFileUrl = Bundle.main.url(forResource: sourceName, withExtension: sourceExtension) else { return false}
        let documentsDirectory = FileManage.documentsDirectory()
        let documentDirectoryFileUrl = documentsDirectory.appendingPathComponent(sourceName+"."+sourceExtension)
        if !fileManager.fileExists(atPath: documentDirectoryFileUrl.path) {
            do {
                try fileManager.copyItem(at: bundleFileUrl, to: documentDirectoryFileUrl)
                return true
            } catch {
                print("Could not copy file: \(error)")
                return false
            }
        } else {
            return false
        }
    }
    
    // MARK: - Copy File From Temp To Document Directory
    class func copyFileFromTempToDocumentDir(fileUrlFromTempDir: URL, isfullUrl: Bool, isDeleteFromTemp: Bool) -> String? {
        let documentsPath = FileManage.documentsDirectory()
        var lastPathComponent = fileUrlFromTempDir.lastPathComponent
        if isfullUrl {
            lastPathComponent = fileUrlFromTempDir.path
            lastPathComponent = lastPathComponent.replacingOccurrences(of: ":", with: "")
            lastPathComponent = lastPathComponent.replacingOccurrences(of: "//", with: "-")
            lastPathComponent = lastPathComponent.replacingOccurrences(of: "/", with: "-")
        }
        let fullPath = documentsPath.appendingPathComponent(lastPathComponent)
        let destinationURL = URL(fileURLWithPath: fullPath.path)
        let fileManager = FileManager.default
        do {
            try fileManager.removeItem(at: destinationURL)
        } catch {
            // Non-fatal: file probably doesn't exist
        }
        do {
            try fileManager.copyItem(at: fileUrlFromTempDir, to: destinationURL)
            if isDeleteFromTemp {
                try fileManager.removeItem(at: fileUrlFromTempDir)
            }
            return destinationURL.path
        } catch let error as NSError {
            print("Could not copy file to disk: \(error.localizedDescription)")
            return nil
        }
    }
    
    // MARK: - Move File From Temp To Document Directory
    class func moveFileFromTempToDocumentDir(fileUrlFromTempDir: URL, isfullUrl: Bool) -> String? {
        let documentsPath = FileManage.documentsDirectory()
        var lastPathComponent = fileUrlFromTempDir.lastPathComponent
        if isfullUrl {
            lastPathComponent = fileUrlFromTempDir.path
            lastPathComponent = lastPathComponent.replacingOccurrences(of: ":", with: "")
            lastPathComponent = lastPathComponent.replacingOccurrences(of: "//", with: "-")
            lastPathComponent = lastPathComponent.replacingOccurrences(of: "/", with: "-")
        }
        let fullPath = documentsPath.appendingPathComponent(lastPathComponent)
        let destinationURL = URL(fileURLWithPath: fullPath.path)
        let fileManager = FileManager.default
        do {
            try fileManager.removeItem(at: destinationURL)
        } catch {
            // Non-fatal: file probably doesn't exist
        }
        do {
            try fileManager.moveItem(at: fileUrlFromTempDir, to: destinationURL)
            return destinationURL.path
        } catch let error as NSError {
            print("Could not copy file to disk: \(error.localizedDescription)")
            return nil
        }
    }
    
    // MARK: - Temp Directory
    ///Temp Directory
    class func tempDirectory() -> URL {
        let tempDirectoryURL = NSURL.fileURL(withPath: NSTemporaryDirectory(), isDirectory: true)
        return tempDirectoryURL
    }
    
    // MARK: - Check File Exist In Temp Directory
    class func isFileExistTempDir(fileName: String?) -> Bool {
        guard let fileNewName = fileName else {
            return false
        }
        let tempDirPath = FileManage.tempDirectory().appendingPathComponent(fileNewName)
        let fileExists = FileManager.default.fileExists(atPath: tempDirPath.path)
        return fileExists
    }
}
