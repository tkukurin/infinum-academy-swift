import UIKit
import Unbox

class PokemonListViewController: UITableViewController {
    
    var user : User!
    var items : PokemonList!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Pokedex"
        
        initBackButton()
        initCreateNewPokemonButton()
        fetchPokemons()
    }
    
    func initBackButton() {
        // self.navigationItem.leftBarButtonItem.action = backToLoginScreenAction
    }
    
    func initCreateNewPokemonButton() {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "+",
            style: UIBarButtonItemStyle.Plain,
            target: self,
            action: #selector(PokemonListViewController.newPokemonAction))
    }
    
    func newPokemonAction() {
        /*let createPokemonViewController = self.storyboard?.instantiateViewControllerWithIdentifier("CreatePokemonViewController") as! CreatePokemonViewController
        createPokemonViewController.user = user
        createPokemonViewController.createdPokemonDelegate = self
        
        self.navigationController?.pushViewController(createPokemonViewController, animated: true)*/
    }
    
    func backToLoginScreenAction(sender: AnyObject) {
        ServerRequestor.doDelete(RequestEndpoint.USER_ACTION_CREATE_OR_DELETE)
        
        let loginViewController = self.storyboard?.instantiateViewControllerWithIdentifier("LoginViewController") as! LoginViewController
        self.navigationController?.pushViewController(loginViewController, animated: true)
        
    }
    
    func fetchPokemons() {
        ProgressHud.show()
        ServerRequestor.doGet(
            RequestEndpoint.POKEMON_ACTION,
            requestingUser: user,
            callback: serverActionCallback)
    }
}

extension PokemonListViewController {
    override func willMoveToParentViewController(parent: UIViewController?) {
        super.willMoveToParentViewController(parent)
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items?.pokemons.count ?? 0
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let pokemon = items.pokemons[indexPath.row]
        let singlePokemonViewController = self.storyboard?.instantiateViewControllerWithIdentifier("singlePokemonViewController")
            as! SinglePokemonViewController
        
        singlePokemonViewController.pokemon = pokemon
        self.navigationController?.pushViewController(singlePokemonViewController, animated: true)
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("pokemonTableCell", forIndexPath: indexPath) as! PokemonTableCell
        cell.displayPokemon(self.items.pokemons[indexPath.row])
        
        return cell
    }
}

extension PokemonListViewController {
    
    func serverActionCallback(response: ServerResponse<AnyObject>) {
        response
            .ifSuccessfulDo(loadPokemonsFromServerResponse)
            .ifFailedDo({ _ in ProgressHud.indicateFailure("Uh-oh... The Pokemons could not be loaded!") })
    }
    
    func loadPokemonsFromServerResponse(data: NSData) throws {
        let fetchedData: PokemonList = try Unbox(data)
        self.items = fetchedData
        self.tableView.reloadData()
        ProgressHud.indicateSuccess()
    }
}