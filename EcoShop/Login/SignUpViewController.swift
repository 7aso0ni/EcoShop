import UIKit
import FirebaseAuth
import FirebaseFirestore

class SignUpViewController: UIViewController {

    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!

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
    
}
