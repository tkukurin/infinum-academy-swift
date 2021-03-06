
import UIKit
import Unbox

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var mainStoryboard: UIStoryboard!
    var navigationController: UINavigationController!

    func application(application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        setupSharedContainer()
        setupInitialWindows()
        
        getLocalUserData()
            .ifPresent(showPokemonListScreen)
            .orElseDo(showLoginScreen)
        
        return true
    }
    
    func setupSharedContainer() {
        let storageAdapter = LocalStorageAdapter()
        let serverRequestor = ServerRequestor()
        let sharedImageCache = ImageCache.sharedInstance
        let sharedRequestCache = RequestCache.sharedInstance
        
        Container.putServices([
            (key: UserDataLocalStorage.self, value: { storageAdapter }),
            (key: ImageCache.self, value: { sharedImageCache }),
            (key: ServerRequestor.self, value: { serverRequestor }),
            (key: RequestCache.self, value: { sharedRequestCache }),
            (key: ApiUserRequest.self, value: { ApiUserRequest() }),
            (key: ApiPhotoRequest.self, value: { ApiPhotoRequest() }),
            (key: ApiCommentListRequest.self, value: { ApiCommentListRequest()}),
            (key: ApiCommentPostRequest.self, value: { ApiCommentPostRequest() }),
            (key: ApiPokemonListRequest.self, value: { ApiPokemonListRequest() }),
            (key: ApiPokemonCreateRequest.self, value: { ApiPokemonCreateRequest() })
        ])
    }
    
    func setupInitialWindows() {
        mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        navigationController = (mainStoryboard.instantiateInitialViewController() as! UINavigationController)
        window = UIWindow(frame: UIScreen.mainScreen().bounds)
        window?.rootViewController = navigationController
    }
    
    private func getLocalUserData() -> Result<UserLoginData> {
        return Container.sharedInstance.get(UserDataLocalStorage.self).loadUser()
    }
    
    private func showPokemonListScreen(userLoginData: UserLoginData) {
        Container.sharedInstance.get(ApiUserRequest.self)
            .setSuccessHandler(loadUserAndShowPokemonListScreen)
            .setFailureHandler(showLoginScreen)
            .doLogin(userLoginData)
    }
    
    private func loadUserAndShowPokemonListScreen(user: User) {
        let loginViewController = mainStoryboard.instantiateViewControllerWithIdentifier("LoginViewController") as! LoginViewController
        let pokemonListViewController = mainStoryboard.instantiateViewControllerWithIdentifier("PokemonListViewController") as! PokemonListViewController
        
        pokemonListViewController.loggedInUser = user
        navigationController.pushViewController(loginViewController, animated: false)
        loginViewController.navigationController?.pushViewController(pokemonListViewController, animated: false)
    }
    
    private func showLoginScreen() {
        let loginViewController = mainStoryboard.instantiateViewControllerWithIdentifier("LoginViewController") as! LoginViewController
        navigationController.pushViewController(loginViewController, animated: true)
    }

}

