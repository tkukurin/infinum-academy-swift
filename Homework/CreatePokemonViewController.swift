
import UIKit

class CreatePokemonViewController: UITableViewController {
    
    @IBOutlet weak var imageViewComponent: UIImageView!
    @IBOutlet weak var pokemonNameTextField: UITextField!
    @IBOutlet weak var pokemonHeightTextField: UITextField!
    @IBOutlet weak var pokemonWeightTextField: UITextField!
    @IBOutlet weak var pokemonDescriptionTextField: UITextField!
    @IBOutlet weak var genderSegmentedControl: UISegmentedControl!
    
    var loggedInUser: User!
    var createPokemonDelegate: PokemonCreatedDelegate!
    
    private var pickedImage: UIImage!
    private var pokemonCreateRequest: ApiPokemonCreateRequest!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pokemonCreateRequest = Container.sharedInstance.get(ApiPokemonCreateRequest.self)
    }
    
    
    @IBAction func didTapAddImageButton(sender: AnyObject) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = false
        picker.sourceType = .PhotoLibrary
        
        presentViewController(picker, animated: true, completion: nil)
    }
    
    @IBAction func didTapCreatePokemonButton(sender: UIButton) {
        constructPokemonAttributeMap()
            .filter(areWeightAndHeightDoubleValues)
            .ifPresent({ attributes in
                ProgressHud.show()
                sender.enabled = false
                
                self.pokemonCreateRequest
                    .setSuccessHandler(self.closeWindowAndNotifyDelegate)
                    .setFailureHandler({ sender.enabled = true
                                         ProgressHud.indicateFailure() })
                    .doCreate(self.loggedInUser, image: self.pickedImage, attributes: attributes)
            })
    }
    
    func constructPokemonAttributeMap() -> Result<[String: String]> {
        var attributes = [String: String]()
        var fieldsAreValid = true
        
        getTuplesOfRequiredFieldsAndRequestKeys().forEach({ tuple in
            let key = tuple.key
            let field = tuple.field
            
            Result.ofNullable(field)
                .map({ $0.text })
                .filter({ !$0.isEmpty })
                .ifPresent({ attributes[key] = $0 })
                .orElseDo({ fieldsAreValid = false; AnimationUtils.shakeFieldAnimation(field) })
        })
        
        attributes[ApiRequestConstants.PokeAttributes.GENDER_ID] = getGenderIdFromSegmentControl()
        return Result.ofNullable(fieldsAreValid ? attributes : nil)
    }
    
    func getTuplesOfRequiredFieldsAndRequestKeys() -> [(key: String, field: UITextField)] {
        return [ (key: ApiRequestConstants.PokeAttributes.NAME, field: pokemonNameTextField),
                 (key: ApiRequestConstants.PokeAttributes.HEIGHT, field: pokemonHeightTextField),
                 (key: ApiRequestConstants.PokeAttributes.WEIGHT, field: pokemonWeightTextField),
                 (key: ApiRequestConstants.PokeAttributes.DESCRIPTION, field: pokemonDescriptionTextField) ]
    }
    
    func areWeightAndHeightDoubleValues(attributes: [String: String]) -> Bool {
        let dblHeight = tryConvertToDouble(attributes[ApiRequestConstants.PokeAttributes.HEIGHT])
        let dblWeight = tryConvertToDouble(attributes[ApiRequestConstants.PokeAttributes.WEIGHT])
        
        dblWeight.orElseDo({ ProgressHud.indicateFailure("Weight should be a double value") })
        dblHeight.orElseDo({ ProgressHud.indicateFailure("Height should be a double value") })
        
        return dblHeight.isPresent() && dblWeight.isPresent()
    }
    
    func tryConvertToDouble(value: String?) -> Result<Double> {
        return Result.ofNullable(value).map({ Double($0) })
    }
    
    func getGenderIdFromSegmentControl() -> String {
        let segmentIndexToValue = [ "1", "2" ]
        let index = genderSegmentedControl.selectedSegmentIndex
        
        return segmentIndexToValue[index]
    }
    
    func closeWindowAndNotifyDelegate(createdPokemon: PokemonCreatedResponse) -> Void {
        ProgressHud.indicateSuccess()
        
        self.navigationController?.popViewControllerAnimated(true)
        self.createPokemonDelegate.notifyPokemonCreated(
            createdPokemon.pokemon,
            image: self.imageViewComponent.image)
    }
    
}

extension CreatePokemonViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        Result
            .ofNullable(info[UIImagePickerControllerOriginalImage] as? UIImage)
            .ifPresent({ self.imageViewComponent.image = $0
                         self.pickedImage = $0 })
            .orElseDo({ ProgressHud.indicateFailure("Couldn't load image!") })
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
}

