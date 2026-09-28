//
//  PowerUpSheetViewViewController.swift
//  How Lucky
//
//  Created by Peyton White on 12/10/24.
//

import Foundation
import GoogleMobileAds

class RewardedViewModel: NSObject, ObservableObject, GADFullScreenContentDelegate {
    @Published var coins = 0
    private var rewardedAd: GADRewardedAd?
    private var rewardCompletion: ((Int) -> Void)?
    private var earnedReward = 0
    
    @Published var isBannerAdLoaded = false // To track banner ad status
    private var bannerView: GADBannerView!

    
    override init() {
          super.init()
          loadBannerAd() // Initialize banner ad loading
      }
    
    func showAd(completion: @escaping (Int) -> Void) {
        guard rewardCompletion == nil else { return }
        guard let rewardedAd = rewardedAd else {
            completion(0)
            return
        }
        rewardCompletion = completion
        earnedReward = 0
        rewardedAd.present(fromRootViewController: nil) { [weak self] in
            self?.earnedReward = max(0, Int(truncating: rewardedAd.adReward.amount))
        }
    }

    private func finishReward() {
        let completion = rewardCompletion
        let reward = earnedReward
        rewardCompletion = nil
        rewardedAd = nil
        earnedReward = 0
        completion?(reward)
    }

    func addCoins(amount:Int) {
        
    }
    
    
    //Banner mine: ca-app-pub-4618134083822244/2581213726
    //Banner test: ca-app-pub-4618134083822244~7321588879
    func loadBannerAd() {
        bannerView = GADBannerView(adSize: GADAdSizeBanner)
        bannerView.delegate = self
        
        // Add your AdMob Ad Unit ID for the banner ad
        bannerView.adUnitID = "ca-app-pub-4618134083822244/2581213726"
        
        let scenes = UIApplication.shared.connectedScenes
        let windowScene = scenes.first as? UIWindowScene
        let window = windowScene?.windows.first
        
        bannerView.rootViewController = window?.rootViewController
        
        
        let request = GADRequest()
        bannerView.load(request)
    }
    
  
    //mine: ca-app-pub-4618134083822244/8251527162
    //test: ca-app-pub-3940256099942544/1712485313
    func loadAd() async {
        rewardedAd = nil
        do {
            rewardedAd = try await GADRewardedAd.load(
                withAdUnitID: "ca-app-pub-4618134083822244/8251527162", request: GADRequest())
            rewardedAd?.fullScreenContentDelegate = self
            print("Loaded")
        } catch {
            print("Failed to load rewarded ad with error: \(error.localizedDescription)")
        }
    }
    
    // Handle Banner Ad Display in SwiftUI
       func getBannerAdView() -> GADBannerView {
           return bannerView
       }
    
    func adDidRecordImpression(_ ad: GADFullScreenPresentingAd) {
      print("\(#function) called")
    }

    func adDidRecordClick(_ ad: GADFullScreenPresentingAd) {
      print("\(#function) called")
    }

    func ad(
      _ ad: GADFullScreenPresentingAd,
      didFailToPresentFullScreenContentWithError error: Error
    ) {
      print("\(#function) called")
      finishReward()
    }

    func adWillPresentFullScreenContent(_ ad: GADFullScreenPresentingAd) {
      print("\(#function) called")
    }

    func adWillDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
      print("\(#function) called")
    }

    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
      print("\(#function) called")
      finishReward()
    }
    
    
}


// MARK: - GADBannerViewDelegate methods
extension RewardedViewModel: GADBannerViewDelegate {
    func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
        isBannerAdLoaded = true
        print("Banner ad loaded.")
    }
    
    func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error) {
        isBannerAdLoaded = false
        print("Failed to load banner ad: \(error.localizedDescription)")
    }
    
    func bannerViewWillPresentScreen(_ bannerView: GADBannerView) {
        print("Banner ad clicked.")
    }
    
    func bannerViewDidDismissScreen(_ bannerView: GADBannerView) {
        print("Banner ad dismissed.")
    }
}
