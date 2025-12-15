import Foundation
import Capacitor
import RiveRuntime
import UIKit

@objc(RiveSplashScreenPlugin)
public class RiveSplashScreenPlugin: CAPPlugin {

    private var riveViewModel: RiveViewModel?
    private var riveView: RiveView?
    
    override public func load() {
        // L'UI doit toujours être modifiée sur le Main Thread
        DispatchQueue.main.async {
            self.setupRiveView()
        }
    }
    
    func setupRiveView() {
        // 1. Récupération de la configuration
        let config = getConfig()
        let assetName = config.getString("assetName") ?? ""
        let fitString = config.getString("fit") ?? "cover"

        // Sécurité : si pas de nom de fichier, on arrête
        if assetName.isEmpty { return }

        // 2. Mapping du mode Fit (conforme à la doc Rive Runtime)
        let fit: RiveFit
        switch fitString.lowercased() {
        case "contain": fit = .contain
        case "fill": fit = .fill
        case "fitwidth": fit = .fitWidth
        case "fitheight": fit = .fitHeight
        case "none": fit = .noFit
        case "scaledown": fit = .scaleDown
        case "layout": fit = .layout
        default: fit = .cover
        }

        // 3. Initialisation du ViewModel avec le nom du fichier
        // Capacitor place le contenu dans le dossier 'public' du bundle
        let viewModel = RiveViewModel(
            fileName: "public/\(assetName)",
            fit: fit,
            alignment: .center
        )
        self.riveViewModel = viewModel

        // 4. Création de la vue (RiveView est une sous-classe de UIView)
        let view = viewModel.createRiveView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.white

        self.riveView = view

        // 5. Injection dans la hiérarchie de Capacitor (par-dessus la WebView)
        guard let bridge = self.bridge, let viewController = bridge.viewController else {
            print("RiveSplashScreen: Impossible d'accéder au ViewController de Capacitor")
            return
        }

        viewController.view.addSubview(view)

        // 6. Contraintes Auto Layout (plein écran)
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: viewController.view.topAnchor),
            view.bottomAnchor.constraint(equalTo: viewController.view.bottomAnchor),
            view.leadingAnchor.constraint(equalTo: viewController.view.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: viewController.view.trailingAnchor)
        ])
    }

    @objc func hide(_ call: CAPPluginCall) {
        let durationMs = call.getDouble("fadeDuration") ?? 400
        let durationSec = durationMs / 1000.0

        DispatchQueue.main.async {
            guard let view = self.riveView else {
                call.resolve()
                return
            }

            UIView.animate(withDuration: durationSec, animations: {
                view.alpha = 0
            }) { _ in
                self.cleanup()
                call.resolve()
            }
        }
    }

    deinit {
        cleanup()
    }

    private func cleanup() {
        riveView?.removeFromSuperview()
        riveView = nil
        riveViewModel = nil
    }
}