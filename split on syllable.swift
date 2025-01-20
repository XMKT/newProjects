// Разделение текста на слоги

import Foundation

// ошибки
enum MyError : Error {
    case EscapeFromRange(description : String = "Выход из диапазона")
}


// Возвращает подстроку
func returnSubString(string : String, start_pos : Int, end_pos : Int) throws -> String {
    if start_pos > end_pos || start_pos < 0 || end_pos > string.count{
        throw MyError.EscapeFromRange()
    }
    let start_index = string.index(string.startIndex, offsetBy: start_pos)
    let end_index = string.index(string.startIndex, offsetBy: end_pos)
    let range_substring = start_index ..< end_index
    return String(string[range_substring])
}


// класс, разделяющий слова на слоги
class SplitOnSyllable{
    private var text    : String    = ""
    private var words   : [String]  = []
    private var sounds  : [[Int]]   = []
    var syllables     : [[String]]  = []
    
    // разделяем текст на слова
    private func splitTextOnWords(text:String) -> [String]{
        let regex = try! NSRegularExpression(pattern: "\\S+")
        let all_matches = regex.matches(in: text, range: NSRange(location: 0, length: text.utf16.count))
        var words : [String] = []
        for i in all_matches{
            words.append(try! returnSubString(string: text, start_pos: i.range.lowerBound, end_pos: i.range.upperBound))
        }
        return words
    }
    
    // назначаем по шкале сонорности
    private func setSonority(word : String) -> [Int]{
        let word = word.lowercased()
        let vowels  : [String] = ["а", "е", "ё", "и", "о", "у", "ы", "э", "ю", "я"]
        let sonor   : [String] = ["й","л", "м", "н", "р"]
        let noise   : [String] = ["б", "в", "г", "д", "ж", "з", "к", "п", "с", "т", "ф", "х", "ц", "ч", "ш", "щ"]
        let spliting: [String] = ["ъ", "ь"]
        let sounds  : [[String]] = [spliting, noise, sonor, vowels]
        
        var sounds_array : [Int] = []
    check_char: for char in word{
            for index in 0..<sounds.count{
                for sonor_char in sounds[index]{
                    if sonor_char == String(char){
                        sounds_array.append(index)
                        continue check_char
                    }
                }
            }
            sounds_array.append(-1)
        }

        return sounds_array
    }
    
    // разделение на слоги по правилу восходящей звучности
    private func splitOnSyllable(word:String, sonority_array:[Int]) -> [String]{
        var count_sillable : Int = 0
        var syllables : [String] = []
        
        for i in sonority_array{
            if i == 3{
                count_sillable += 1
            }
        }

        var last_index = 0
        var new_index  = 0
        while(count_sillable > 0){
            var syllable : String = ""
            if count_sillable == 1{
                syllable = try! returnSubString(string: word, start_pos: last_index, end_pos: word.count)
            }else{
                var position_first_vowel    = -1
                var position_second_vowel   = -1
                while(true){
                    if sonority_array[new_index] == 3 && position_first_vowel == -1{
                        position_first_vowel = new_index
                        new_index += 1
                    }else if sonority_array[new_index] == 3 && position_first_vowel > -1{
                        position_second_vowel = new_index
                        break
                    }else{
                        new_index += 1
                    }
                }
                if position_second_vowel - position_first_vowel == 1{
                    new_index = position_first_vowel+1
                }else if position_second_vowel - position_first_vowel == 2{
                    new_index = position_second_vowel - 1
                }else if position_second_vowel - position_first_vowel > 2{
                    var mt : Bool = false
                    for i in position_first_vowel+1..<position_second_vowel{
                        if sonority_array[i] == 0{
                            mt = true
                            new_index = i+1
                            break
                        }
                    }
                    if mt{
                    }else if (sonority_array[position_first_vowel+1] == 2 && sonority_array[position_first_vowel+2] == 1){
                        new_index = position_first_vowel + 2
                    }else if sonority_array[position_first_vowel+1] == 2 && sonority_array[position_first_vowel+2] == 2{
                        new_index = position_first_vowel + 2
                    }else if try! returnSubString(string: word, start_pos: position_first_vowel+1, end_pos: position_first_vowel+2) == "й"{
                        new_index = position_first_vowel + 2
                    }else{
                        new_index = position_first_vowel + 1
                    }
                }
                syllable = try! returnSubString(string: word, start_pos: last_index, end_pos: new_index)
            }
            syllables.append(syllable)
            count_sillable -= 1
            last_index = new_index
        }
        return syllables
    }
    
    
    // инициализация
    init(text : String){
        self.text = text
        self.words = splitTextOnWords(text: self.text)
        for word in self.words{
            sounds.append(setSonority(word: word))
        }
        for index in 0..<words.count{
            self.syllables.append(splitOnSyllable(word: self.words[index], sonority_array: self.sounds[index]))
        }
        
        
    }
}


