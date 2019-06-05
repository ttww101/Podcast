
import UIKit
import SwiftyJSON
import NVActivityIndicatorView
import FacebookLogin
import FacebookCore
import GoogleSignIn

class LoginViewController: UIViewController, GIDSignInUIDelegate {

    var googleLoginButton: UIButton!
    var facebookLoginButton: UIButton!
    var loadingActivityIndicator: NVActivityIndicatorView!
    var loginBackgroundGradientView: LoginBackgroundGradientView!
    var podcastLogoView: LoginPodcastLogoView!
    var podcastGridView: UIImageView!
    
    
    // MARK: Constants
    var signInButtonTopPadding: CGFloat = 72
    var signInButtonWidth: CGFloat = 205
    var signInButtonHeight: CGFloat = 42
    var signInButtonSmallPadding: CGFloat = 12
    let podcastLogoViewMultiplier: CGFloat = 0.25
    var gridViewHeight: CGFloat = 262

    override func viewDidLoad() {
        super.viewDidLoad()

        loginBackgroundGradientView = LoginBackgroundGradientView(frame: view.frame)
        view.addSubview(loginBackgroundGradientView)

        podcastGridView = UIImageView(frame: .zero)
        podcastGridView.image = #imageLiteral(resourceName: "grid")
        podcastGridView.alpha = 0.65
        view.addSubview(podcastGridView)
        
        podcastGridView.snp.makeConstraints { (make) in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(gridViewHeight)
        }
        
        podcastLogoView = LoginPodcastLogoView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height / 4))
        view.addSubview(podcastLogoView)

        podcastLogoView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(podcastLogoViewMultiplier)
            make.top.equalTo(0).inset(view.frame.width * podcastLogoViewMultiplier)
        }

        facebookLoginButton = UIButton()
        facebookLoginButton.setBackgroundImage(#imageLiteral(resourceName: "signinFb"), for: .normal)
        facebookLoginButton.addTarget(self, action: #selector(facebookLoginButtonPress), for: .touchUpInside)
        view.addSubview(facebookLoginButton)

        facebookLoginButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(podcastLogoView.snp.bottom).offset(signInButtonTopPadding)
            make.width.equalTo(signInButtonWidth)
            make.height.equalTo(signInButtonHeight)
        }

        googleLoginButton = UIButton()
        let attributedString = NSMutableAttributedString(string: "Sign in with Google instead", attributes: [
            .font: UIFont._14RegularFont(),
            .foregroundColor: UIColor.offWhite])
        attributedString.addAttribute(.font, value: UIFont._14SemiboldFont(), range: NSRange(location: 12, length: 7))
        googleLoginButton.setAttributedTitle(attributedString, for: .normal)
        googleLoginButton.addTarget(self, action: #selector(googleLoginButtonPress), for: .touchUpInside)
        view.addSubview(googleLoginButton)

        googleLoginButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(facebookLoginButton.snp.bottom).offset(signInButtonSmallPadding)
            make.width.equalTo(signInButtonWidth)
            make.height.equalTo(signInButtonHeight)
        }

        loadingActivityIndicator = LoadingAnimatorUtilities.createLoadingAnimator()
        loadingActivityIndicator.center = view.center
        loadingActivityIndicator.color = .offWhite
        loadingActivityIndicator.startAnimating()
        view.addSubview(loadingActivityIndicator)
        
        hideLoginButtons(isHidden: true)

        // if we have a valid access token for Facebook or Google then sign in silently
        if let _ = Authentication.sharedInstance.facebookAccessToken {
            // try signing in with Facebook
            Authentication.sharedInstance.authenticateUser(signInType: .facebook, success: self.signInSuccess, failure: {
                self.signInFailure(showAlert: false)
            })
        } else if GIDSignIn.sharedInstance().hasAuthInKeychain() {
            Authentication.sharedInstance.signInSilentlyWithGoogle() // Google delegate method will be called when this completes
        } else {
            signInFailure(showAlert: false)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Authentication.sharedInstance.setDelegate(self)
        stylizeNavBar()
    }

    @objc func googleLoginButtonPress() {
        hideLoginButtons(isHidden: true)
        loadingActivityIndicator.startAnimating()
        Authentication.sharedInstance.signIn(with: .google, viewController: self)
    }

    func stylizeNavBar() {
        navigationController?.navigationBar.backgroundColor = .clear
        guard let statusBar = UIApplication.shared.value(forKeyPath: "statusBarWindow.statusBar") as? UIView else { return }
        statusBar.backgroundColor = .clear
    }

    @objc func facebookLoginButtonPress() {
        hideLoginButtons(isHidden: true)
        loadingActivityIndicator.startAnimating()
        Authentication.sharedInstance.signIn(with: .facebook, viewController: self)
    }

    func signInSuccess(isNewUser: Bool) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }

        loadingActivityIndicator.stopAnimating()
        hideLoginButtons(isHidden: false)

        if isNewUser {
            let loginUsernameVC = LoginUsernameViewController()
            loginUsernameVC.user = System.currentUser!
            navigationController?.pushViewController(loginUsernameVC, animated: false)
        } else {
            appDelegate.didFinishAuthenticatingUser()
        }
    }

    func signInFailure(showAlert: Bool) {
        loadingActivityIndicator.stopAnimating()
        hideLoginButtons(isHidden: false)
        if showAlert { present(UIAlertController.somethingWentWrongAlert(), animated: true, completion: nil) }
    }

    func hideLoginButtons(isHidden: Bool) {
        facebookLoginButton.isHidden = isHidden
        googleLoginButton.isHidden = isHidden
    }
}

// MARK: SignInUI Delegate
extension LoginViewController: SignInUIDelegate {

    func signedIn(for type: SignInType, withResult result: SignInResult) {
        switch result {
        case .success:
            Authentication.sharedInstance.authenticateUser(signInType: type, success: self.signInSuccess, failure: { self.signInFailure(showAlert: true) })
        case .cancelled:
            signInFailure(showAlert: false)
        case .failure:
            signInFailure(showAlert: true)
        }
    }

}
