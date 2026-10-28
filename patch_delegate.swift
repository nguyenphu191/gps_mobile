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
