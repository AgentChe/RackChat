//class ChatViewController: UIViewController, ChatViewProtocol {
//
//    var menuView: MenuViewProtocol = DKMenuCell()
//
//    var noView: ChatNoViewProtocol = NoViewDep()
//
//    var presenter: ChatPresenterProtocol?
//
//    var tableView: UITableView = UITableView()
//
//    var textInputView: DKChatBottomView = DKChatBottomView()
//
//    var configurator: ChatConfiguratorProtocol = DKChatConfigurator()
//
//    var menuImageView: UIImageView!
//
//    @IBOutlet weak var input: DKChatBottomView!
//    @IBOutlet weak var menuCell: DKMenuCell!
//    @IBOutlet weak var inputContainerViewBottom: NSLayoutConstraint!
//    @IBOutlet weak var noInternetView: UIView!
//    @IBOutlet weak var noInternetHeight: NSLayoutConstraint!
//    @IBOutlet weak var noMessageView: UIStackView!
//    @IBOutlet weak var userImageView: UIImageView!
//    @IBOutlet weak var noMessagesTitleLabel: UILabel!
//    @IBOutlet weak var inputContainerView: UIView!
//    @IBOutlet weak var table: UITableView!
//
//    @IBOutlet var navView: UIView!
//    @IBOutlet var partnerNameLabel: UILabel!
//    @IBOutlet var partnerPhotosImageViews: [UIImageView]!
//
//    private var barItem: UIBarButtonItem?
//    private var image: UIImage!
//    private var currentChat: ChatItem!
//    private let imagePicker = UIImagePickerController()
//    private var userData: UserShow?
//
//    @objc func handleMatch() {
//        performSegue(withIdentifier: "search", sender: MatchScreenState.foundet)
//    }
//
//    // MARK: - life cycle
//
//    func config(with chatItem: ChatItem) {
//
//        currentChat = chatItem
//    }
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        if #available(iOS 13.0, *) {
//            overrideUserInterfaceStyle = .light
//        }
//
//        NotificationCenter.default.addObserver(self, selector: #selector(handleMatch), name: NotificationManager.kMatchNotify, object: nil)
//
//        NotificationCenter.default.addObserver(self, selector: #selector(self.close), name: ReportViewController.reportNotify, object: nil)
//
//        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
//
//        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
//
//        navigationItem.titleView = navView
//        navigationItem.largeTitleDisplayMode = .never
//        noMessageView.alpha = 0.0
//
//        tableView = table
//        textInputView = input
//        menuView = menuCell
//        tableView.re.delegate = self
//
////        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboad))
//
////        view.addGestureRecognizer(tap)
//        configurator.configurate(view: self)
//        guard presenter != nil else { return }
//        textInputView.sendButton.addTarget(self, action: #selector(tapOnSend), for: .touchUpInside)
//        guard presenter != nil else { return }
//        tableView.re.dataSource = presenter?.tableDataSource
//        tableView.re.delegate = self
//
//        navigationItem.largeTitleDisplayMode = .never
//
//        menuImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 48, height: 48))
//        let widthConstraint = NSLayoutConstraint(item: menuImageView!,
//                                                 attribute: NSLayoutConstraint.Attribute.width,
//                                                 relatedBy: NSLayoutConstraint.Relation.equal,
//                                                 toItem: nil,
//                                                 attribute: NSLayoutConstraint.Attribute.notAnAttribute,
//                                                 multiplier: 1,
//                                                 constant: 48)
//        let heightConstraint = NSLayoutConstraint(item: menuImageView!,
//                                                 attribute: NSLayoutConstraint.Attribute.height,
//                                                 relatedBy: NSLayoutConstraint.Relation.equal,
//                                                 toItem: nil,
//                                                 attribute: NSLayoutConstraint.Attribute.notAnAttribute,
//                                                 multiplier: 1,
//                                                 constant: 48)
//        menuImageView.addConstraints([widthConstraint, heightConstraint])
//        load(imageUrl: currentChat.partnerAvatarString, into: menuImageView)
//
//        let tg = UITapGestureRecognizer(target: self, action: #selector(showUnmachAndReport))
//        menuImageView.addGestureRecognizer(tg)
//
//        barItem = UIBarButtonItem(customView: menuImageView)
//        DispatchQueue.main.async { [weak self] in
//            self!.navigationItem.setRightBarButton(self!.barItem, animated: true)
//        }
//    }
//
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//
//        noMessagesTitleLabel.text = "You matched with " + currentChat.partnerName
//    }
//
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//
//        Amplitude.instance()?.log(event: .chatScr, with: ["user_id" : String(DatingKit.user.userData!.id),
//                                                          "user_email" : DatingKit.user.userData!.email,
//                                                          "companion_id" : currentChat.chatID])
//        ScreenManager.shared.chatItemOnScreen = currentChat
//        guard presenter != nil else { return }
//        guard currentChat != nil else { return }
//        presenter?.configure(chat: currentChat)
//    }
//
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//        presenter?.disconnect()
//        ScreenManager.shared.chatItemOnScreen = nil
//    }
//
//    private func load(imageUrl: String, into imageView: UIImageView) {
//
//        imageView.alpha = 0.0
//        imageView.isHidden = true
//
//        guard let urlString = imageUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
//            return
//        }
//
//        imageView.isHidden = false
//        imageView.downloaded(from: urlString) { }
//
//        UIView.animate(withDuration: 0.4) {
//            imageView.alpha = 1.0
//        }
//
//    }
//
//
//    // MARK: - interface
//
//    func reload() {
//        tableView.reloadData()
//    }
//
//    func openPaygate() {
//
//        performSegue(withIdentifier: "paygate", sender: nil)
//    }
//
//    func setScreen() {
//
//    }
//
//    func showNoView(_ show: Bool) {
//        UIView.animate(withDuration: 0.2) {
//            self.noMessageView.alpha = show ? 1.0 : 0.0
//        }
//    }
//
//    func addMessage(at indexPath: IndexPath) {
//        self.tableView.beginUpdates()
//        self.tableView.re.insertRows(at: [indexPath], with: .top)
//        self.tableView.endUpdates()
//    }
//
//    func deleteMessage(at indexPath: IndexPath) {
//
//    }
//
//    func showNoInternetConnection(_ show: Bool) {
//        showNoInternet(show: show)
//    }
//
//    func showError(with message: Message) {
//        let actionSheet: UIAlertController = UIAlertController(title: nil, message: "Your message was not sent. Tap “Try Again” to send this message.", preferredStyle: .actionSheet)
//        actionSheet.addAction(UIAlertAction(title: "Try again", style: .destructive, handler: { [weak self] (action) in
//            self?.presenter?.send(message: message)
//        }))
//
//        actionSheet.addAction(UIAlertAction(title: "Delete Message", style: .destructive, handler: { [weak self] (action) in
//            self?.presenter?.deleteUnsendet(message: message)
//        }))
//
//
//        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
//        if let popoverController = actionSheet.popoverPresentationController {
//            popoverController.sourceView = self.view
//        }
//        present(actionSheet, animated: true, completion: nil)
//    }
//
//    //MARK: - actions
//
//
//    @objc func hideKeyboad() {
//        view.endEditing(true)
//    }
//
//    @objc func close() {
//        self.navigationController?.popViewController(animated: true)
//    }
//
//    @objc func showUnmachAndReport() {
//        view.endEditing(true)
//        let actionSheet: UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
//        actionSheet.addAction(UIAlertAction(title: "Unmatch", style: .default, handler: { (action) in
//            self.performSegue(withIdentifier: "unmatch", sender: nil)
//        }))
//        actionSheet.addAction(UIAlertAction(title: "Report", style: .default, handler: { (action) in
//            self.performSegue(withIdentifier: "report", sender: nil)
//        }))
//        actionSheet.addAction(UIAlertAction(title: "Done", style: .cancel, handler: nil))
//        actionSheet.view.tintColor = #colorLiteral(red: 1, green: 0.3303741813, blue: 0.3996370435, alpha: 1)
//        if let popoverController = actionSheet.popoverPresentationController {
//            popoverController.barButtonItem = barItem
//        }
//        present(actionSheet, animated: true, completion: nil)
//    }
//
//
//    @IBAction func showMenuView(_ sender: DKChatMenuView) {
//        imagePicker.allowsEditing = false
//        imagePicker.sourceType = .photoLibrary
//        imagePicker.delegate = self
////        view.endEditing(true)
//        present(imagePicker, animated: true, completion: nil)
//    }
//
//    @objc func tapOnSend() {
//        guard presenter != nil else {return}
//        guard let user: UserShow = presenter?.user else {return}
//        guard currentChat != nil else {return}
//        if input.text.trimmingCharacters(in: .whitespaces).isEmpty {
//            return
//        }
//
//        presenter?.send(message: Message(text: input.text, sender: user.id, matchID: currentChat.chatID))
//        input.text = ""
//    }
//
//
//
//    @IBAction func tapOnPhoto(_ sender: Any) {
//
//    }
//
//
//    @objc func keyboardWillHide(_ sender: Notification) {
//        if let userInfo = (sender as NSNotification).userInfo {
//            if let _ = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.size.height {
//                //key point 0,
//                self.inputContainerViewBottom.constant =  0
//                UIView.animate(withDuration: 0.25, animations: { () -> Void in self.view.layoutIfNeeded() })
//            }
//        }
//    }
//
//
//    @objc func keyboardWillShow(_ sender: Notification) {
//        if let userInfo = (sender as NSNotification).userInfo {
//            if var keyboardHeight = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.size.height {
//                debugPrint(UIDevice.modelName.contains("X"))
//                if UIDevice.modelName.contains("X") {
//                    keyboardHeight = keyboardHeight - 35
//                }
//                self.inputContainerViewBottom.constant = keyboardHeight
//                UIView.animate(withDuration: 0.25, animations: { () -> Void in
//                    self.view.layoutIfNeeded()
//                })
//            }
//        }
//    }
//
//
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "report" {
//            let reportController: ReportViewController = segue.destination as! ReportViewController
//            reportController.config(chat: currentChat)
//        }
//
//        if segue.identifier == "unmatch" {
//            if let unmatchVC: UnmatchViewController = segue.destination as! UnmatchViewController {
//                unmatchVC.config(avatar: menuImageView!.image!, and: currentChat.partnerName, chatItem: currentChat)
//                unmatchVC.delegate = self
//            }
//        }
//        if segue.identifier == "paygate" {
//            let paygate: PaymentViewController = segue.destination as! PaymentViewController
//            paygate.delegate = self
//
//        }
//
//        if segue.identifier == "search" {
//            let searchView: MatchViewController = segue.destination as! MatchViewController
//            if let startFromNewSearchButton: MatchScreenState = sender as? MatchScreenState {
//                if startFromNewSearchButton == .foundet {
//                    if let match: DKMatch = ScreenManager.shared.match {
//                        searchView.config(state: startFromNewSearchButton, match: match)
//                    } else {
//                        searchView.config(state: .searchng)
//                    }
//
//                } else {
//                    searchView.config(state: startFromNewSearchButton)
//                }
//
//            }
//
//        }
//    }
//
//}
//
//extension ChatViewController: UnmatchViewControllerDelegate {
//    func wasRepoerted() {
//        self.navigationController?.popViewController(animated: true)
//    }
//
//
//}
//
//extension ChatViewController: PaymentViewControllerDelegate {
//
//    func wasPurchased() {
//
//    }
//
//    func wasClosed() {
//    }
//
//}
//
//
//extension ChatViewController: UITableViewDelegate {
//
//    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
//        if tableView.isEditing {
//            return .delete
//        }
//
//        return .none
//    }
//
//
//    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//        guard presenter != nil else { return }
//        presenter?.pagintaion(for: indexPath)
//    }
//
//}
//
//extension ChatViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
//
//    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
//
//        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
//
//            guard presenter != nil else { return }
//            guard let user: UserShow = presenter?.user else {
//                return
//            }
//
//            var newMessage: Message = Message(image: pickedImage, forSender: user.id, matchID: currentChat.chatID)
//            newMessage.base64Image = pickedImage.ConvertImageToBase64String()
//            newMessage.sendetImage = pickedImage
//            presenter?.send(message: newMessage)
//
//        }
//        dismiss(animated: true, completion: nil)
//    }
//
//    private func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
//
//    }
//
//    private func imagePickerControllerDidCancel(picker: UIImagePickerController) {
//        dismiss(animated: true, completion: nil)
//    }
//}
//
//class NoViewDep: UIView, ChatNoViewProtocol {
//
//    var icon: UIImage = UIImage()
//
//    var title: String = ""
//
//    var subTitle: String = ""
//
//
//}
//
//extension UIImage {
//    enum JPEGQuality: CGFloat {
//        case lowest  = 0
//        case low     = 0.25
//        case medium  = 0.5
//        case high    = 0.75
//        case highest = 1
//    }
//
//    func jpeg(_ jpegQuality: JPEGQuality) -> Data? {
//        return jpegData(compressionQuality: jpegQuality.rawValue)
//    }
//}
