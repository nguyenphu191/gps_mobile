import Flutter
import UIKit
import UserNotifications
import google_mobile_ads

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    
    let factory = NativeAdFactory()
    FLTGoogleMobileAdsPlugin.registerNativeAdFactory(
        self, factoryId: "nativeFull", nativeAdFactory: factory)
        
    let smallFactory = SmallNativeAdFactory()
    FLTGoogleMobileAdsPlugin.registerNativeAdFactory(
        self, factoryId: "nativeSmall", nativeAdFactory: smallFactory)
        
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
import Foundation
import google_mobile_ads
import GoogleMobileAds
import UIKit

class NativeAdFactory: NSObject, FLTNativeAdFactory {
    func createNativeAd(
        _ nativeAd: NativeAd,
        customOptions: [AnyHashable : Any]?
    ) -> NativeAdView? {
        let adView = CustomNativeAdView()
        
        adView.nativeAd = nativeAd
        
        (adView.headlineView as? UILabel)?.text = nativeAd.headline
        (adView.bodyView as? UILabel)?.text = nativeAd.body
        (adView.callToActionView as? UIButton)?.setTitle(nativeAd.callToAction, for: .normal)
        
        adView.iconView?.isHidden = nativeAd.icon == nil
        (adView.iconView as? UIImageView)?.image = nativeAd.icon?.image
        
        adView.mediaView?.mediaContent = nativeAd.mediaContent
        adView.mediaView?.isHidden = false
        
        return adView
    }
}

class CustomNativeAdView: NativeAdView {
    let ctaButton = UIButton(type: .system)
    let iconImageView = UIImageView()
    let adBadgeLabel = UILabel()
    let headlineLabel = UILabel()
    let bodyLabel = UILabel()
    let myMediaView = MediaView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    private func setupViews() {
        self.backgroundColor = UIColor(red: 245/255.0, green: 245/255.0, blue: 250/255.0, alpha: 1.0)
        
        // Call to action
        ctaButton.backgroundColor = UIColor(red: 44/255.0, green: 54/255.0, blue: 104/255.0, alpha: 1.0)
        ctaButton.setTitleColor(.white, for: .normal)
        ctaButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        ctaButton.layer.cornerRadius = 24
        ctaButton.isUserInteractionEnabled = false 
        
        self.addSubview(ctaButton)
        self.callToActionView = ctaButton
        
        // Icon
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.clipsToBounds = true
        iconImageView.layer.cornerRadius = 4
        self.addSubview(iconImageView)
        self.iconView = iconImageView
        
        // Ad Badge
        adBadgeLabel.text = "Ad"
        adBadgeLabel.backgroundColor = UIColor(red: 253/255, green: 216/255, blue: 53/255, alpha: 1.0)
        adBadgeLabel.textColor = .black
        adBadgeLabel.font = UIFont.systemFont(ofSize: 11, weight: .bold)
        adBadgeLabel.layer.cornerRadius = 3
        adBadgeLabel.clipsToBounds = true
        adBadgeLabel.textAlignment = .center
        self.addSubview(adBadgeLabel)
        
        // Headline
        headlineLabel.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        headlineLabel.textColor = .black
        headlineLabel.numberOfLines = 1
        self.addSubview(headlineLabel)
        self.headlineView = headlineLabel
        
        // Body (Hidden to match image)
        bodyLabel.isHidden = true
        self.addSubview(bodyLabel)
        self.bodyView = bodyLabel
        
        // Media View
        self.addSubview(myMediaView)
        self.mediaView = myMediaView
        
        // Setup AutoLayout
        ctaButton.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        adBadgeLabel.translatesAutoresizingMaskIntoConstraints = false
        headlineLabel.translatesAutoresizingMaskIntoConstraints = false
        myMediaView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            // CTA Button at the bottom
            ctaButton.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
            ctaButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16),
            ctaButton.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor, constant: -24),
            ctaButton.heightAnchor.constraint(equalToConstant: 50),
            
            // Ad Badge above CTA
            adBadgeLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
            adBadgeLabel.bottomAnchor.constraint(equalTo: ctaButton.topAnchor, constant: -20),
            adBadgeLabel.widthAnchor.constraint(equalToConstant: 26),
            adBadgeLabel.heightAnchor.constraint(equalToConstant: 16),
            
            // Icon View (if present, next to Ad Badge)
            iconImageView.leadingAnchor.constraint(equalTo: adBadgeLabel.trailingAnchor, constant: 6),
            iconImageView.centerYAnchor.constraint(equalTo: adBadgeLabel.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 16),
            iconImageView.heightAnchor.constraint(equalToConstant: 16),
            
            // Headline
            headlineLabel.centerYAnchor.constraint(equalTo: adBadgeLabel.centerYAnchor),
            headlineLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 6),
            headlineLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16),
            
            // Media View takes all space above the text area
            myMediaView.topAnchor.constraint(equalTo: self.topAnchor),
            myMediaView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            myMediaView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            myMediaView.bottomAnchor.constraint(equalTo: adBadgeLabel.topAnchor, constant: -20)
        ])
    }
}
import Foundation
import google_mobile_ads
import GoogleMobileAds
import UIKit

class SmallNativeAdFactory: NSObject, FLTNativeAdFactory {
    func createNativeAd(
        _ nativeAd: NativeAd,
        customOptions: [AnyHashable : Any]?
    ) -> NativeAdView? {
        let adView = CustomSmallNativeAdView()
        
        adView.nativeAd = nativeAd
        
        (adView.headlineView as? UILabel)?.text = nativeAd.headline
        (adView.bodyView as? UILabel)?.text = nativeAd.body
        (adView.callToActionView as? UIButton)?.setTitle(nativeAd.callToAction, for: .normal)
        
        adView.iconView?.isHidden = nativeAd.icon == nil
        (adView.iconView as? UIImageView)?.image = nativeAd.icon?.image
        
        // No media view in small ad
        
        return adView
    }
}

class CustomSmallNativeAdView: NativeAdView {
    let ctaButton = UIButton(type: .system)
    let iconImageView = UIImageView()
    let adBadgeLabel = UILabel()
    let headlineLabel = UILabel()
    let bodyLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    private func setupViews() {
        self.backgroundColor = .white
        
        // Call to action
        ctaButton.backgroundColor = UIColor(red: 37/255.0, green: 99/255.0, blue: 235/255.0, alpha: 1.0)
        ctaButton.setTitleColor(.white, for: .normal)
        ctaButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
        ctaButton.layer.cornerRadius = 8
        ctaButton.isUserInteractionEnabled = false 
        
        self.addSubview(ctaButton)
        self.callToActionView = ctaButton
        
        // Icon
        iconImageView.contentMode = .scaleAspectFill
        iconImageView.clipsToBounds = true
        iconImageView.layer.cornerRadius = 4
        self.addSubview(iconImageView)
        self.iconView = iconImageView
        
        // Ad Badge
        adBadgeLabel.text = "Ad"
        adBadgeLabel.backgroundColor = UIColor(red: 253/255, green: 216/255, blue: 53/255, alpha: 1.0)
        adBadgeLabel.textColor = .black
        adBadgeLabel.font = UIFont.systemFont(ofSize: 10, weight: .bold)
        adBadgeLabel.layer.cornerRadius = 3
        adBadgeLabel.clipsToBounds = true
        adBadgeLabel.textAlignment = .center
        self.addSubview(adBadgeLabel)
        
        // Headline
        headlineLabel.font = UIFont.boldSystemFont(ofSize: 14)
        headlineLabel.textColor = .black
        headlineLabel.numberOfLines = 1
        self.addSubview(headlineLabel)
        self.headlineView = headlineLabel
        
        // Body
        bodyLabel.font = UIFont.systemFont(ofSize: 12)
        bodyLabel.textColor = .darkGray
        bodyLabel.numberOfLines = 1
        self.addSubview(bodyLabel)
        self.bodyView = bodyLabel
        
        // Setup AutoLayout
        ctaButton.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        adBadgeLabel.translatesAutoresizingMaskIntoConstraints = false
        headlineLabel.translatesAutoresizingMaskIntoConstraints = false
        bodyLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            // Icon
            iconImageView.topAnchor.constraint(equalTo: self.topAnchor, constant: 8),
            iconImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 8),
            iconImageView.widthAnchor.constraint(equalToConstant: 40),
            iconImageView.heightAnchor.constraint(equalToConstant: 40),
            
            // Ad Badge
            adBadgeLabel.topAnchor.constraint(equalTo: iconImageView.topAnchor),
            adBadgeLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 8),
            adBadgeLabel.widthAnchor.constraint(equalToConstant: 20),
            adBadgeLabel.heightAnchor.constraint(equalToConstant: 14),
            
            // Headline
            headlineLabel.centerYAnchor.constraint(equalTo: adBadgeLabel.centerYAnchor),
            headlineLabel.leadingAnchor.constraint(equalTo: adBadgeLabel.trailingAnchor, constant: 6),
            headlineLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -8),
            
            // Body
            bodyLabel.topAnchor.constraint(equalTo: headlineLabel.bottomAnchor, constant: 2),
            bodyLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 8),
            bodyLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -8),
            
            // CTA Button on bottom
            ctaButton.topAnchor.constraint(equalTo: iconImageView.bottomAnchor, constant: 8),
            ctaButton.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 8),
            ctaButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -8),
            ctaButton.heightAnchor.constraint(equalToConstant: 36),
            ctaButton.bottomAnchor.constraint(lessThanOrEqualTo: self.bottomAnchor, constant: -8)
        ])
    }
}
