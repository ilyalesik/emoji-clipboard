//
//  Emojis.swift
//  TouchBarEmojis
//
//  Created by Gabriel Lorin
//

import Foundation
import Smile

struct EmojiItem {
    var type: String;
    var value: String;
    
    init(type: String, value: String) {
        self.type = type;
        self.value = value;
    }
    
}

extension String {
    func capitalizingFirstLetter() -> String {
        return prefix(1).uppercased() + self.lowercased().dropFirst()
    }
    
    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
}

struct Emojis {
    // array containing the emojis:
    static var arrayEmojis = [EmojiItem]()
    static var allEmojis = Smile.emojiCategories
    static var emojiCategories = ["people", "nature", "foods", "activity", "places", "objects", "symbols", "flags"]


    
    static func getFrequentlyUsedEmojis() -> [String] {
        
        // initiate the array containing the most recently used/frequently used emojis:
        var frequentlyUsedEmojis = [String]()
        
        // path to most commonly used emojis, new location (10.13):
        let pathFrequentlyUsedEmojis = NSHomeDirectory()+"/Library/Preferences/com.apple.EmojiPreferences.plist"
        
        // it's a dic:
        if let dic = NSDictionary(contentsOfFile: pathFrequentlyUsedEmojis) as? [String: Any] {
            
            // check key EMFDefaultsKey:
            if let EMFDefaultsKey = dic["EMFDefaultsKey"] as! NSDictionary? {
                
                // then check key EMFRecentsKey, which contains emojis ordered by most frequently used:
                if let EMFRecentsKey = EMFDefaultsKey["EMFRecentsKey"] as! [String]? {
                    for oneEmoji in EMFRecentsKey {
                        // add items to our array:
                        frequentlyUsedEmojis.append(oneEmoji)
                    }
                }
                
            }
            
        }
        
        // if array is empty, it means we probably don't have the new 10.13 emoji preferences file:
        if(frequentlyUsedEmojis.count == 0) {
            
            // retrieve frequently used emojis from 10.12 (and older) location:
            let pathFrequentlyUsedEmojis = NSHomeDirectory()+"/Library/Preferences/com.apple.CharacterPicker.plist"
            
            // a dic, with different structure from 10.13:
            if let dic = NSDictionary(contentsOfFile: pathFrequentlyUsedEmojis) as? [String: Any] {
                
                if let arrayDic: [String] = dic["Recents:com.apple.CharacterPicker.DefaultDataStorage"] as? [String] {
                    
                    for item in arrayDic {
                        if(item.components(separatedBy: "com.apple.cpk:").count > 1) {
                            let jsonText = item.components(separatedBy: "com.apple.cpk:")[1]
                            
                            // convert the String to utf8 encoded Data for json serializing:
                            if let data = jsonText.data(using: String.Encoding.utf8) {
                                
                                do {
                                    
                                    // serialize the JSON data object into a dic:
                                    let jsonDic = try JSONSerialization.jsonObject(with: data, options: [.allowFragments]) as? [String:AnyObject] as NSDictionary?
                                    
                                    // from the serialized object, we try to get the value for char:
                                    if let oneEmojiItem = jsonDic?["char"] as? String {
                                        // add it to the array of recently used emojis:
                                        frequentlyUsedEmojis.append(oneEmojiItem)
                                    }
                                    
                                } catch {
                                    // error with serialization
                                }
                            }
                        }
                    }
                }
                
                
            }
            
        }
        
        return frequentlyUsedEmojis
    }
    
    static func getAllEmojis() -> [EmojiItem] {
        var result = [EmojiItem]();
        let frequentEmojis = getFrequentlyUsedEmojis();
        if (frequentEmojis.count > 0) {
            result.append(EmojiItem(type: "group", value: "Recent: "));
            for c in frequentEmojis {
                result.append(EmojiItem(type: "item", value: c));
            }
        }
        
        for groupEmojiName in emojiCategories {
            result.append(EmojiItem(type: "group", value: groupEmojiName.capitalizingFirstLetter() + ":"))
            let groupEmojiArray = allEmojis[groupEmojiName] ?? []
            for c in groupEmojiArray {
                result.append(EmojiItem(type: "item", value: c));
            }
        }
        
        return result;
    }
}
