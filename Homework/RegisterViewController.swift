

import UIKit
import Unbox

typealias UserRegisterData = (email:String,
                              username: String,
                              password: String,
                              confirmedPassword: String)

class RegisterViewController : UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    
    private var userDataLocalStorage: UserDataLocalStorage!
    private var registerRequest: ApiUserRequest!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userDataLocalStorage = Container.sharedInstance.get(UserDataLocalStorage.self)
        registerRequest = Container.sharedInstance.get(ApiUserRequest.self)
        
        emailTextField.text = "nottestmail@email.com"
        usernameTextField.text = "nottestuser"
        passwordTextField.text = "longpassword"
        confirmPasswordTextField.text = "longpassword"
    }
}

extension  RegisterViewController {
    
    @IBAction func didTapSignUpButton(sender: UIButton) {
        sender.enabled = false
        
        requireFilledTextFields()
            .ifPresent(sendRegisterRequest)
            .orElseDo({
                ProgressHud.indicateFailure("Please fill out all the fields.")
                sender.enabled = true
            })
    }
    
    private func requireFilledTextFields() -> Result<UserRegisterData> {
        var values = [String]()
        var didCollectAllRequiredValues = true
        
        getRequiredFields().forEach({ field in
            // TODO functional
            if let content = field.text where !content.isEmpty {
                values.append(content)
            } else {
                didCollectAllRequiredValues = false
                AnimationUtils.shakeFieldAnimation(field)
            }
        })
        
        return didCollectAllRequiredValues
            ? Result.of(arrayToRegisterData(values))
            : Result.error()
    }
    
    // TODO separate into collection
    
    private func getRequiredFields() -> [UITextField] {
        return [ emailTextField,
                 usernameTextField,
                 passwordTextField,
                 confirmPasswordTextField ]
    }
    
    // TODO would work better as a String:String hashMap
    
    private func arrayToRegisterData(values: [String]) -> UserRegisterData {
        return (email: values[0],
                username: values[1],
                password: values[2],
                confirmedPassword: values[3])
    }
    
    // TODO if registerRequest fails, button should be reset to enabled.
    
    private func sendRegisterRequest(userData: UserRegisterData) {
        ProgressHud.show()
        
        registerRequest
            .setSuccessHandler(persistUserAndGoToHomescreen)
            .setFailureHandler({ ProgressHud.indicateFailure("Could not send data to server") })
            .doRegister(userData)
    }
    
    private func persistUserAndGoToHomescreen(user: User) {
        ProgressHud.indicateSuccess("Successfully logged in!")
        
        userDataLocalStorage.persistUser(emailTextField.text!, passwordTextField.text!)
        pushController(PokemonListViewController.self, injecting: { $0.loggedInUser = user })
    }
    
}

