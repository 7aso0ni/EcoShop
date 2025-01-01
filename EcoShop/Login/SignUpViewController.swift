import UIKit
import FirebaseAuth
import FirebaseFirestore
import GoogleSignIn
import FirebaseCore

class SignUpViewController: UIViewController {

    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!

    @IBOutlet weak var useGoogle: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
       // navigationController?.setNavigationBarHidden(true, animated: false)
        
        setupUI()
    }

    func setupUI() {
        signUpButton.layer.cornerRadius = 8
        loginButton.layer.cornerRadius = 8
    }

    @IBAction func signUpButtonTapped(_ sender: UIButton) {
        guard let name = nameField.text, !name.isEmpty,
              let email = emailField.text, !email.isEmpty,
              let password = passwordField.text, !password.isEmpty else {
            showAlert(title: "Error", message: "Please fill in all fields")
            return
        }
        
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
            if let error = error {
                self?.showAlert(title: "Registration Failed", message: error.localizedDescription)
                return
            }
            
            guard let user = result?.user else {
                self?.showAlert(title: "Error", message: "User not created")
                return
            }
            
            self?.createUserProfile(for: user, withName: name, email: email)
        }
    }

    func createUserProfile(for user: User, withName name: String, email: String) {
        let db = Firestore.firestore()
        let usersRef = db.collection("users").document(user.uid)
        
        let userData: [String: Any] = [
            "name": name,
            "email": email,
            "userType": "user" 
        ]
        
        usersRef.setData(userData) { [weak self] error in
            if error != nil {
                self?.showAlert(title: "Error", message: "Failed to create user profile")
                return
            }
            
            self?.showAlert(title: "Success", message: "User registered successfully") {
                self?.performSegue(withIdentifier: "toProfileSetup", sender: self)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toProfileSetup" {
            if let profileSetupVC = segue.destination as? ProfileSetupViewController {
                UserDefaults.standard.set(Auth.auth().currentUser?.uid, forKey: "user_uid")
                profileSetupVC.currentUser = Auth.auth().currentUser
            }
        }
        if segue.identifier == "toLogin" {
            if let loginVC = segue.destination as? LoginViewController {
                loginVC.modalPresentationStyle = .fullScreen
            }
        }
    }


    func showAlert(title: String, message: String, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            completion?()
        }))
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func googleButtonTapped(_ sender: UIButton) {
        //for validation and error handling
        print("Google button tapped")
        
        if let filePath = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") {
               print("Found GoogleService-Info.plist at: \(filePath)")
               if let clientID = FirebaseApp.app()?.options.clientID {
                   print("Client ID found: \(clientID)")
               }
           } else {
               print("GoogleService-Info.plist not found in bundle")
           }
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            print("No client ID found")
            return }
        
     
        
        let config = GIDConfiguration(clientID: clientID)
        print("Attempting Google sign in...")
        
        GIDSignIn.sharedInstance.signIn(withPresenting: self) { [weak self] result, error in
            guard let self = self else { return }
            print("Sign in callback received")
            if let error = error {
                self.showAlert(title: "Error", message: error.localizedDescription)
                return
            }
            
            guard let user = result?.user,
                  let idToken = user.idToken?.tokenString else {
                self.showAlert(title: "Error", message: "Failed to get user data")
                return
            }
            
            let credential = GoogleAuthProvider.credential(
                withIDToken: idToken,
                accessToken: user.accessToken.tokenString
            )
            
            // Sign in with Firebase
            Auth.auth().signIn(with: credential) { [weak self] result, error in
                if let error = error {
                    self?.showAlert(title: "Error", message: error.localizedDescription)
                    return
                }
                
                guard let firebaseUser = result?.user else { return }
                
                self?.createUserProfile(
                    for: firebaseUser,
                    withName: user.profile?.name ?? "",
                    email: user.profile?.email ?? ""
                )
            }
        }
    }
    
}
