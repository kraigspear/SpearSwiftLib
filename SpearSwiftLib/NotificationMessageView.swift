//
//  NotificationMessage.swift
//  SpearSwiftLib
//
//  Created by Kraig Spear on 1/6/17.
//  Copyright © 2017 spearware. All rights reserved.
//

import UIKit

/**
 Provides a banner like message at the top of another view
 */
public final class NotificationMessageView: NSObject {
    /// The parent view that is hosting this NotificationMessageView.
    fileprivate let notificationParentView: UIView
    /// The height of this notification view.
    fileprivate let notificationHeight: CGFloat
    /// The inner content view that will move down when the notification view is shown.
    fileprivate let notificationContentView: UIView
    /// The view that contains the message.
    fileprivate var messageView: UIView?

    /// A constriant that is docking the notificationContentView to the top, that is disabled when
    ///the NotificationMessageView is shown
    fileprivate var constraintToDisableWhenNotificationShows: NSLayoutConstraint
    /// The top constraint for the messageview that docks the MessageView to the top
    fileprivate var messageViewTopConstraint: NSLayoutConstraint?

    /// Called when the notification has been closed
    public var onClosed: (() -> Void)?

    /**
     Initialize a NotificationMessageView providing the required members

     - parameter notificationParentView: The parent view that is hosting this NotificationMessageView.
     - parameter notificationContentView: The inner content view that will move down when the notification view is shown.
     - parameter constraintToDisableWhenNotificationShows: A constriant that is docking the notificationContentView to the top, that is disabled when the NotificationMessageView is shown
     - parameter height: The height of this notification view.
     */
    public init(notificationParentView: UIView,
                notificationContentView: UIView,
                constraintToDisableWhenNotificationShows: NSLayoutConstraint,
                height: CGFloat) {
        self.notificationParentView = notificationParentView
        self.notificationContentView = notificationContentView
        self.constraintToDisableWhenNotificationShows = constraintToDisableWhenNotificationShows
        notificationHeight = height
    }

    deinit {
        cleanUp()
    }
}

// MARK: - Create

private extension NotificationMessageView {
    func createMessageView(containingMessage: String,
                           backgroundColor: UIColor,
                           textColor: UIColor,
                           font: UIFont) {
        let messageView = UIView()
        self.messageView = messageView
        notificationParentView.addSubview(messageView)
        messageView.backgroundColor = backgroundColor
        layout(messageView: messageView)

        addMessageLabel(containingMessage: containingMessage,
                        textColor: textColor,
                        font: font,
                        to: messageView)

        constraintToDisableWhenNotificationShows.isActive = false
        notificationContentView.topAnchor.constraint(equalTo: messageView.bottomAnchor).isActive = true
        addSwipGesture(to: messageView)
    }

    func layout(messageView: UIView) {
        messageView.translatesAutoresizingMaskIntoConstraints = false
        messageViewTopConstraint = messageView.topAnchor.constraint(equalTo: notificationParentView.topAnchor, constant: -notificationHeight)
        messageViewTopConstraint!.isActive = true
        messageView.leftAnchor.constraint(equalTo: notificationParentView.leftAnchor).isActive = true
        messageView.rightAnchor.constraint(equalTo: notificationParentView.rightAnchor).isActive = true
        messageView.heightAnchor.constraint(equalToConstant: notificationHeight).isActive = true
    }

    func addMessageLabel(containingMessage: String,
                         textColor: UIColor,
                         font: UIFont,
                         to labelParent: UIView) {
        let label = UILabel()
        label.textColor = textColor
        label.font = font
        label.text = containingMessage
        label.numberOfLines = 2
        label.minimumScaleFactor = 0.5
        label.translatesAutoresizingMaskIntoConstraints = false
        labelParent.addSubview(label)

        label.centerYAnchor.constraint(equalTo: labelParent.centerYAnchor).isActive = true
        label.leftAnchor.constraint(equalTo: labelParent.leftAnchor, constant: 20).isActive = true
        label.rightAnchor.constraint(equalTo: labelParent.rightAnchor, constant: -20).isActive = true
    }

    func addSwipGesture(to: UIView) {
        let swipeGesture = UISwipeGestureRecognizer()
        swipeGesture.direction = .up
        swipeGesture.numberOfTouchesRequired = 1
        swipeGesture.addTarget(self, action: #selector(onSwipe(gesture:)))
        to.addGestureRecognizer(swipeGesture)
    }
}

// MARK: - Show / Close / Swipe

public extension NotificationMessageView {
    /**
     Shows a NotificationMessageView

     - parameter message: The message to show in the NotificationMessageView
     - parameter withbackgroundColorOf: The background color of the view
     - parameter andTextColorOf: The color of the text of the message
     */
    func show(message: String,
              withbackgroundColorOf backGroundColor: UIColor,
              andTextColorOf textColor: UIColor,
              usingFont font: UIFont) {
        createMessageView(containingMessage: message,
                          backgroundColor: backGroundColor,
                          textColor: textColor,
                          font: font)

        notificationParentView.layoutIfNeeded()

        UIView.animate(withDuration: 0.5,
                       delay: 0,
                       usingSpringWithDamping: 0.5,
                       initialSpringVelocity: 0.5,
                       options: .curveEaseInOut,
                       animations: { [unowned self] () -> Void in
                           self.messageViewTopConstraint!.constant = 0
                           self.notificationParentView.layoutIfNeeded()
                       },
                       completion: nil)
    }

    func closeMessage(shouldAnimate animate: Bool) {
        if animate == false {
            cleanUp()
            return
        }

        UIView.animate(withDuration: 0.25,
                       delay: 0,
                       usingSpringWithDamping: 0.5,
                       initialSpringVelocity: 0.5,
                       options: .curveEaseInOut,
                       animations: { [unowned self] () -> Void in
                           self.messageViewTopConstraint!.constant = -self.notificationHeight
                           self.notificationParentView.layoutIfNeeded()
                       },
                       completion: { [weak self] _ in
                           self?.cleanUp()
        })
    }

    @objc func onSwipe(gesture: UISwipeGestureRecognizer) {
        messageView?.removeGestureRecognizer(gesture)
        closeMessage(shouldAnimate: true)
    }
}

// MARK: - Clean Up

private extension NotificationMessageView {
    func cleanUp() {
        messageView?.removeFromSuperview()
        messageView = nil
        constraintToDisableWhenNotificationShows.isActive = true
        onClosed?()
    }
}
