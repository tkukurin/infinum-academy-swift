import UIKit
import Unbox

protocol CreatePokemonDelegate {
    func notify(pokemon: Pokemon)
}

class CreatePokemonViewController: UIViewController {
    
    @IBOutlet weak var imageViewComponent: UIImageView!
    @IBOutlet weak var pokemonNameTextField: UITextField!
    @IBOutlet weak var pokemonHeightTextField: UITextField!
    @IBOutlet weak var pokemonWeightTextField: UITextField!
    @IBOutlet weak var pokemonTypeTextField: UITextField!
    @IBOutlet weak var pokemonDescriptionTextField: UITextField!
    
    var user: User!
    var createPokemonDelegate: CreatePokemonDelegate!
    
    private var pickedImage: UIImage!
    private var alertUtils: AlertUtils!
    private var serverRequestor: ServerRequestor!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        alertUtils = Container.sharedInstance.getAlertUtilities(self)
        serverRequestor = Container.sharedInstance.getServerRequestor()
    }
    
    @IBAction func onCreateButtonPress(sender: AnyObject) {
        ProgressHud.show()
        serverRequestor.doMultipart(RequestEndpoint.POKEMON_ACTION,
                                    user: user,
                                    pickedImage: pickedImage,
                                    attributes: constructPokemonAttributeMap(),
                                    callback: serverActionCallback)
    }
    
    func constructPokemonAttributeMap() -> [String: String] {
        var attributes = [String: String]()
        
        return attributes
    }
    
    private func placeholderToKey(placeholder: String) -> String {
        return placeholder.stringByReplacingOccurrencesOfString(" ", withString: "-").lowercaseString
    }
}

extension CreatePokemonViewController {
    
    func serverActionCallback(response: ServerResponse<String>?) -> Void {
        guard let response = response else {
            ProgressHud.indicateFailure()
            return
        }
        
        response.ifSuccessfulDo({
            let pokemon: Pokemon = try Unbox($0)
            
            ProgressHud.indicateSuccess("Successfully created pokemon!")
            self.createPokemonDelegate.notify(pokemon)
        }).ifFailedDo({ _ in
            ProgressHud.indicateFailure()
        })
    }
    
}


extension CreatePokemonViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func displayImagePicker() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = false
        picker.sourceType = .PhotoLibrary
        
        presentViewController(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imageViewComponent.contentMode = .ScaleAspectFit
            
            let subView = UIImageView(image: pickedImage)
            imageViewComponent.addSubview(subView)
            self.pickedImage = pickedImage
        }
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
}
