//
//  MessageViewController.swift
//  PlateChat
//
//  Created by cano on 2018/08/23.
//  Copyright © 2018年 deskplate. All rights reserved.
//

import UIKit
import MessageKit
import Firebase
import MobileCoreServices
import AVFoundation
import SwiftDate
import SafariServices
import Nuke

class ChatMessageViewController: MessagesViewController {

    let cellId = "CellID"
    var messages = [ChatMessage]()
    var chatRoomService = ChatRoomService()
    private var chatMessageService: ChatMessageService!
    var chatRoom: ChatRoom! {
        didSet {
            self.chatMessageService = ChatMessageService(chatRoom)
        }
    }
    var other_uid: String? {
        didSet {
            UserService.getUserInfo(other_uid!, completionHandler: { [weak self] (user, error) in
                if let err = error {
                    self?.showAlert(err.localizedDescription)
                    return
                }
                guard let user = user else{ return }
                self?.title = user.nickname
            })
        }
    }
    private let refreshControl = UIRefreshControl()

    lazy var formatter: DateFormatter = {
        let formatter = DateFormatter()
        //let formatter = DateFormatter(withFormat: "M/d", locale: Locale.current.languageCode ?? "en_US_POSIX")
        //formatter.dateStyle = .medium
        formatter.locale = Locale(identifier: Locale.current.languageCode!)
        formatter.dateFormat = "M/d"
        formatter.timeZone = TimeZone.current
        return formatter
    }()

    lazy var clockFormatter: DateFormatter = {
        let formatter = DateFormatter()
        //let formatter = DateFormatter(withFormat: "M/d", locale: Locale.current.languageCode ?? "en_US_POSIX")
        //formatter.dateStyle = .medium
        formatter.locale = Locale(identifier: Locale.current.languageCode!)
        formatter.dateFormat = "HH:mm"
        formatter.timeZone = TimeZone.current
        return formatter
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

        DispatchQueue.main.async {
            // messageListにメッセージの配列をいれて
            //self.messageList = self.getMessages()
            // messagesCollectionViewをリロードして
            self.messagesCollectionView.reloadData()
            // 一番下までスクロールする
            self.messagesCollectionView.scrollToBottom()
        }
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.messageCellDelegate = self

        messageInputBar.delegate = self
        messageInputBar.sendButton.tintColor = UIColor.lightGray

        // メッセージ入力時に一番下までスクロール
        scrollsToBottomOnKeybordBeginsEditing = true // default false
        maintainPositionOnKeyboardFrameChanged = true // default false
        messagesCollectionView.register(ChatMessageKitCell.self)
        messagesCollectionView.register(ChatPhotoCell.self)

        // メッセージ表示
        self.observeMessages(callbackHandler: { self.messagesCollectionView.scrollToBottom() })
        self.messagesCollectionView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(ChatMessageViewController.refresh(sender:)), for: .valueChanged)

        setupMessageInputBarButtons()
    }

    func setupMessageInputBarButtons() {
        let height: CGFloat = 28  // 送信ボタンと同じ高さ
        let button = InputBarButtonItem().configure {
            $0.setSize(CGSize(width: height, height: height), animated: false)
            $0.isEnabled = true
            $0.setImage(UIImage(named: "text-icon-unselected"), for: .normal)
            }.onTouchUpInside { [weak self] _ in
                //self?.messageInputBar.inputTextView.becomeFirstResponder()
                //button.setImage(UIImage(named: "text-icon-selected"), for: .normal)
                ActionSheet(title: "写真を送る", message: nil)
                    .addAction("写真を撮る") { self?.selectCamera() }
                    .addAction("フォトアルバムから選ぶ") { self?.selectPhotoLibrary() }
                    .setCancelAction("キャンセル")
                    .show(self!)
        }
        messageInputBar.leftStackView.addArrangedSubview(button)
        let spacerView = UIView()
        spacerView.setContentHuggingPriority(.defaultLow, for: .horizontal)
        messageInputBar.leftStackView.addArrangedSubview(spacerView)
        var leftStackViewWidth: CGFloat {
            return self.view.frame.width - ( messageInputBar.padding.left + button.frame.width + messageInputBar.rightStackViewWidthConstant + messageInputBar.padding.right + 200)
        }
        messageInputBar.setLeftStackViewWidthConstant(to: height + leftStackViewWidth, animated: false)
        messageInputBar.setRightStackViewWidthConstant(to: 60, animated: false)
        messageInputBar.inputTextView.placeholder = "Type a message"
        //messageInputBar.inputTextView.delegate = self
        messageInputBar.inputTextView.font = UIFont.systemFont(ofSize: 14.0)
    }

    func observeMessages(callbackHandler: @escaping () -> Void) {
        chatMessageService.bindChatMessage(callbackHandler: { [weak self] (chatMessageModels, error) in
            switch error {
            case .none:
                if let models = chatMessageModels {
                    let preMessageCount = self?.messages.count
                    self?.messages = models + (self?.messages)! // キャッシュのせいかたまに重複することがあるのでユニークにしておく
                    self?.messages = (self?.messages.unique { $0.messageId == $1.messageId }.sorted(by: { $0.sentDate < $1.sentDate}))!

                    if preMessageCount == self?.messages.count {  // 更新数チェック
                        self?.refreshControl.endRefreshing()
                        return
                    }
                    DispatchQueue.main.async {
                        self?.messagesCollectionView.reloadData()
                        callbackHandler()
                    }
                }
            case .some(.error(let error)):
                Log.error(error!)
            case .some(.noExistsError):
                Log.error("データ見つかりません")
            }
            self?.refreshControl.endRefreshing()
        })
    }

    @objc func refresh(sender: UIRefreshControl) {
        if  messages.count == 0 {
            self.refreshControl.endRefreshing()
            return
        }
        self.observeMessages(callbackHandler: { self.refreshControl.endRefreshing() })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        /*
         guard let messagesCollectionView = collectionView as? MessagesCollectionView else {
         fatalError(MessageKitError.notMessagesCollectionView)
         }

         guard let messagesDataSource = messagesCollectionView.messagesDataSource else {
         fatalError(MessageKitError.nilMessagesDataSource)
         }
         */
        //let message = messagesDataSource.messageForItem(at: indexPath, in: messagesCollectionView)
        let message = self.messageForItem(at: indexPath, in: messagesCollectionView)
        switch message.kind {
        case .text, .attributedText, .emoji:
            let cell = messagesCollectionView.dequeueReusableCell(TextMessageCell.self, for: indexPath)
            cell.configure(with: message, at: indexPath, and: messagesCollectionView)
            return cell
        case .photo, .video:
            //let cell = messagesCollectionView.dequeueReusableCell(MediaMessageCell.self, for: indexPath)
            let cell = messagesCollectionView.dequeueReusableCell(ChatPhotoCell.self, for: indexPath)
            cell.configure(with: message, at: indexPath, and: messagesCollectionView)
            return cell
        case .location:
            let cell = messagesCollectionView.dequeueReusableCell(LocationMessageCell.self, for: indexPath)
            cell.configure(with: message, at: indexPath, and: messagesCollectionView)
            return cell
        case .custom:
            //fatalError(MessageKitError.customDataUnresolvedCell)
            return UICollectionViewCell()
        }
    }

}

extension ChatMessageViewController {
    // カメラ選択
    fileprivate func selectCamera() {
        PhotoRequester.requestPhotoFromCamera(self) { [weak self] result in
            switch result {
            case .success(let image):
                self?.showLoading()
                self?.chatMessageService.postImage(image, callbackHandler: {[weak self] error in
                    if let error = error {
                        Log.error(error)
                        self?.hideLoading()
                        return
                    }
                    self?.aftterImagePost()
                })
            case .faild:
                self?.showAlert("カメラへアクセスできません", "設定アプリにてカメラへのアクセス許可してください")
            case .cancel:
                break
            }
        }
    }

    // 画像選択
    fileprivate func selectPhotoLibrary() {
        PhotoRequester.requestPhotoLibrary(self) { [weak self] result in
            switch result {
            case .success(let image):
                self?.showLoading()
                self?.chatMessageService.postImage(image, callbackHandler: {[weak self] error in
                    if let error = error {
                        Log.error(error)
                        self?.hideLoading()
                        return
                    }
                    self?.aftterImagePost()
                })
            case .faild:
                self?.showAlert("フォトアルバムへアクセスできません", "設定アプリにてフォトアルバムへのアクセスを許可してください")
            case .cancel:
                break
            }
        }
    }

    // 画像投稿後にメッセージ画面に戻った場合、下のスクロールが少しずれるので調整
    fileprivate func aftterImagePost() {
        DispatchQueue.main.async {
            self.messagesCollectionView.reloadData()
            self.messagesCollectionView.scrollToBottom()
            self.messageInputBar.inputTextView.becomeFirstResponder()
            self.messageInputBar.inputTextView.resignFirstResponder()
            self.hideLoading()
        }
    }
}

extension ChatMessageViewController: MessagesDataSource {

    func isFromCurrentSender(message: MessageType) -> Bool {
        //return message.sender == currentSender()
        return message.sender.id == (Auth.auth().currentUser?.uid)!
    }

    func currentSender() -> Sender {
        //return Sender(id: "123", displayName: "自分")
        return Sender(id: Auth.auth().currentUser!.uid, displayName: "")
    }

    func otherSender() -> Sender {
        return Sender(id: "", displayName: "")
    }

    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        print("messages.count")
        print(messages.count)
        return messages.count
    }

    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }

    // メッセージの上に文字を表示
    func cellTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        var dateFlg = false
        if indexPath.section % 5 == 0 {
            dateFlg = true
        } else {
            let preMessage = self.messages[indexPath.section-1]
            dateFlg = formatter.string(from: preMessage.sentDate) != formatter.string(from: message.sentDate)
        }
        //if indexPath.section % 3 == 0 {
        if dateFlg {
            let stringAttributes1: [NSAttributedStringKey : Any] = [
                .foregroundColor : UIColor.clear,
                .font : UIFont.systemFont(ofSize: 10.0)
            ]
            let string1 = NSMutableAttributedString(string: "----------", attributes: stringAttributes1)
            string1.addAttribute(NSAttributedStringKey.strikethroughStyle, value: NSUnderlineStyle.styleSingle.rawValue, range: NSRange(location: 0, length: 10))
            string1.addAttribute(NSAttributedStringKey.strikethroughColor, value: UIColor.lightGray, range: NSRange(location: 0, length: 10))
            let calendar = Calendar(identifier: .gregorian)
            let weekdayIndex = calendar.component(Calendar.Component.weekday, from: message.sentDate)-1
            let string2 = NSAttributedString(
                string: " \(formatter.string(from: message.sentDate))(\(formatter.shortWeekdaySymbols[weekdayIndex])) ",
                attributes: [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 10),
                             NSAttributedStringKey.foregroundColor: UIColor.lightGray]
            )
            let mutableAttributedString = NSMutableAttributedString()
            mutableAttributedString.append(string1)
            mutableAttributedString.append(string2)
            mutableAttributedString.append(string1)
            return mutableAttributedString
        }

        return nil
    }
    /*
     // メッセージの上に文字を表示（名前）
     func messageTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
     let name = message.sender.displayName
     return NSAttributedString(string: name, attributes: [NSAttributedStringKey.font: UIFont.preferredFont(forTextStyle: .caption1)])
     }
     */
    // メッセージの下に文字を表示（日付）
    func messageBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        let dateString = clockFormatter.string(from: message.sentDate)
        return NSAttributedString(string: dateString, attributes: [NSAttributedStringKey.font: UIFont.preferredFont(forTextStyle: .caption2)])
    }
}

// メッセージのdelegate
extension ChatMessageViewController: MessagesDisplayDelegate {

    // メッセージの色を変更（デフォルトは自分：白、相手：黒）
    func textColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? .white : .darkText
    }

    // メッセージの背景色を変更している（デフォルトは自分：緑、相手：グレー）
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ?
            UIColor(red: 69/255, green: 193/255, blue: 89/255, alpha: 1) :
            UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 1)
    }

    // メッセージの枠にしっぽを付ける
    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        let corner: MessageStyle.TailCorner = isFromCurrentSender(message: message) ? .bottomRight : .bottomLeft
        return .bubbleTail(corner, .curved)
    }

    // アイコンをセット
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        avatarView.backgroundColor = .clear
        let avatar = Avatar(image: UIImage(), initials: "")
        avatarView.set(avatar: avatar)
        UserService.getUserInfo(message.sender.id, completionHandler: { (user, error) in
            guard let url = user?.profile_image_url else {
                Log.error(error!)
                return
            }
            DispatchQueue.main.async {
                Manager.shared.loadImage(with: URL(string: url)!,
                                         completion: { (result) in
                                            switch result {
                                            case .failure(let error):
                                                Log.error(error)
                                            case .success(let image):
                                                let avatar = Avatar(image: image, initials: "")
                                                avatarView.set(avatar: avatar)
                                            }
                })
            }
        })
    }

    // リンクメッセージの場合青色、下線の設定
    func detectorAttributes(for detector: DetectorType, and message: MessageType, at indexPath: IndexPath) -> [NSAttributedStringKey: Any] {

        let detectorAttributes: [NSAttributedStringKey: Any] = {
            [
                NSAttributedStringKey.foregroundColor: UIColor.blue,
                NSAttributedStringKey.underlineStyle: NSUnderlineStyle.styleSingle.rawValue,
                NSAttributedStringKey.underlineColor: UIColor.blue
            ]
        }()

        MessageLabel.defaultAttributes = detectorAttributes
        return MessageLabel.defaultAttributes
    }

    // メッセージのURLをリンクとして判定
    func enabledDetectors(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> [DetectorType] {
        return [.url]
    }
}


// 各ラベルの高さを設定（デフォルト0なので必須）
extension ChatMessageViewController: MessagesLayoutDelegate {

    func cellTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        //if indexPath.section % 3 == 0 { return 10 }

        var dateFlg = false
        if indexPath.section % 5 == 0 {
            dateFlg = true
        } else {
            let preMessage = self.messages[indexPath.section-1]
            dateFlg = formatter.string(from: preMessage.sentDate) != formatter.string(from: message.sentDate)
        }
        if dateFlg {
            return 15
        }
        return 0
    }

    func messageTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 16
    }

    func messageBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 16
    }
}

extension ChatMessageViewController: MessageCellDelegate {
    // メッセージをタップした時の挙動
    func didTapMessage(in cell: MessageCollectionViewCell) {
        print("Message tapped")
        if let cell = cell as? ChatPhotoCell, let image = cell.imageView.image {
/*
            let photo = INSPhoto(image: image, thumbnailImage: nil)
            let photosVC = INSPhotosViewController(photos: [photo], initialPhoto: photo, referenceView: nil)
            if let overlay = photosVC.overlayView as? INSPhotosOverlayView {
                overlay.frame.origin.y = 20
                overlay.navigationItem.rightBarButtonItems = nil
            }
            self.present(photosVC, animated: true, completion: nil)
*/
        }
    }
}

// MARK: - MessageLabelDelegate

extension ChatMessageViewController: MessageLabelDelegate {

    func didSelectAddress(_ addressComponents: [String : String]) {
        print("Address Selected: \(addressComponents)")
    }

    func didSelectDate(_ date: Date) {
        print("Date Selected: \(date)")
    }

    func didSelectPhoneNumber(_ phoneNumber: String) {
        print("Phone Number Selected: \(phoneNumber)")
    }

    func didSelectURL(_ url: URL) {
        print("URL Selected: \(url)")

        // 念のため開ける形式か判定
        guard UIApplication.shared.canOpenURL(url) else { return }
        //メールアドレスと弾く
        if url.absoluteString.hasPrefix("mailto") { return }
        let safariViewController = SFSafariViewController(url: url)
        present(safariViewController, animated: true)
    }

}

extension ChatMessageViewController: MessageInputBarDelegate {
    // メッセージ送信ボタンをタップした時の挙動
    func messageInputBar(_ inputBar: MessageInputBar, didPressSendButtonWith text: String) {
        for component in inputBar.inputTextView.components {
            if let image = component as? UIImage {
                /*
                 let imageMessage = MockMessage(image: image, sender: currentSender(), messageId: UUID().uuidString, date: Date())
                 messageList.append(imageMessage)
                 messagesCollectionView.insertSections([messageList.count - 1])
                 */
            } else if let text = component as? String {

                self.chatMessageService.postChatMessage(text: text, callbackHandler: { [weak self] error in
                    if let error = error {
                        Log.error(error)
                        return
                    }
                    DispatchQueue.main.async {
                        self?.messageInputBar.inputTextView.text = ""
                        self?.messageInputBar.inputTextView.resignFirstResponder()
                        self?.messagesCollectionView.reloadData()
                        self?.messagesCollectionView.scrollToBottom()
                    }
                })
            }
        }
        inputBar.inputTextView.text = String()
        messagesCollectionView.scrollToBottom()
    }
}
