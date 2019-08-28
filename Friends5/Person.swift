//
//  Person.swift
//  Friends5
//
//  Created by Eddie Ahn on 28/08/2019.
//  Copyright © 2019 Eddie Ahn. All rights reserved.
//

import Foundation

struct Person: Codable, Equatable {
    struct Name: Codable, Equatable {
        let title: String
        let first: String
        let last: String
        
        var full: String{
            return (self.title + ". " + self.last + " " + self.first).uppercased()
        }
    }
    struct PictureURL: Codable, Equatable {
        let large: URL
        let medium: URL
        let thumbnail: URL
    }
    let name: Name
    let cell: String
    let pictureURL: PictureURL

    private let nat: String
}

extension Person {
    enum CodingKeys: String, CodingKey {
        case name, cell, nat
        case pictureURL = "picture"
    }
}

extension Person {
    var nationality: String {
            return nat.uppercased()
    }
}

// Best Friends JSON File URL
extension Person {
    private static let bestFriendFileName: String = "best_firends.json"
    private static var bestFriendFileURL: URL? {
        let fileManager: FileManager = FileManager.default
        let documentURL: URL
        do {
            documentURL =
                try fileManager.url(for: FileManager.SearchPathDirectory.applicationSupportDirectory, in: FileManager.SearchPathDomainMask.userDomainMask, appropriateFor: nil, create: true)
        } catch {
            print("cannot find application support directory")
            print(error.localizedDescription)
            return nil
        }
        let fileURL: URL = documentURL.appendingPathComponent(bestFriendFileName)
        return fileURL
    }
}
// Load Best Friends
extension Person {
    private static func loadBestFriendsFromFile() -> [Person] {
        guard let fileURL: URL = bestFriendFileURL else { return [] }
        
        do {
            let data: Data = try Data(contentsOf: fileURL)
            let decoder : JSONDecoder = JSONDecoder()
            let friends: [Person] = try decoder.decode([Person].self, from: data)
            
            return friends
            
        } catch {
            print("cannot decode JSON")
            print(error.localizedDescription)
        }
    return []
    }
}

// Best Friends Properties
extension Person {
    static var bestFriends: [Person] = Person.loadBestFriendsFromFile()
}

//Save Best Friends
extension Person {
    
    static func saveCurrentBestFriendsToFile() -> Bool {
        guard let fileURL: URL = bestFriendFileURL else { return false }
        let encoder : JSONEncoder = JSONEncoder()
    
        do {
            let data: Data = try encoder.encode(self.bestFriends)
            try data.write(to: fileURL)
            return true
        } catch {
            print("cannot save best friends")
            print(error.localizedDescription)
        }
        return false
    }
}
// Add Best Friends
extension Person {
    static func addBestFriend(_ friend: Person, completion: ((_ isSuccess: Bool) -> Void)? = nil) {
        self.bestFriends.append(friend)
        
        DispatchQueue.main.async {
            completion?(self.saveCurrentBestFriendsToFile())
        }
    }
}

// Find Best Friend Index
extension Person {
    private static func bestFriendIndex(of target: Person) -> Int? {
        guard let index: Int = self.bestFriends.index(where: {
            (friend: Person) -> Bool in
            friend == target
        }) else { return nil }
        return index
    }
}

extension Person {
    static func removeBestFriend(_ friend: Person, completion: ((_ isSuccess: Bool) -> Void)? = nil) {
        if let index: Int = self.bestFriendIndex(of: friend) {
            self.bestFriends.remove(at: index)
            DispatchQueue.main.async {
                completion?(self.saveCurrentBestFriendsToFile())
            }
        } else {
            DispatchQueue.main.async {
                completion?(false)
            }
        }
    }
}
