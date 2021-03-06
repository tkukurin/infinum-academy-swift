
import Foundation

struct ApiRequestConstants {
    
    static let ID = "id"
    static let DATA = "data"
    static let ATTRIBUTES = "attributes"
    static let TYPE = "type"
    
    static let CREATED_AT = "created-at"
    static let UPDATED_AT = "updated-at"
    
    static let DATE_FORMATTER: NSDateFormatter = {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "YYYY-MM-dd'T'HH:mm:ss.SSSZ"
        return formatter
    }()
    
    struct UserAttributes {
        private init() {}
        
        static let AUTH_TOKEN = "auth-token"
        static let USERNAME = "username"
        static let PASSWORD = "password"
        static let CONFIRMED_PASSWORD = "password_confirmation"
        static let EMAIL = "email"
    }
    
    struct Pokemon {
        private init() {}
        
        static let LINKS = "links"
    }
    
    struct PokeAttributes {
        private init() {}
        
        static let NAME = "name"
        static let BASE_EXPERIENCE = "base-experience"
        static let IS_DEFAULT = "is-default"
        static let ORDER = "order"
        static let HEIGHT = "height"
        static let WEIGHT = "weight"
        static let IMAGE_URL = "image-url"
        static let DESCRIPTION = "description"
        static let TOTAL_VOTE_COUNT = "total-vote-count"
        static let GENDER = "gender"
        static let GENDER_ID = "gender-id"
    }
    
    struct PokeListLinks {
        private init() {}
        
        static let CURRENT = "self"
        static let PREV = "last"
        static let NEXT = "next"
    }
    
    struct Comment {
        private init() {}
        
        static let CONTENT = "content"
        static let USER_ID_PATH = "relationships.author.data.id"
    }
}