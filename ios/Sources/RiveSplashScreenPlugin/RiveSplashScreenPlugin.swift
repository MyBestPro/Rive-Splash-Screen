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
        let assetName = getConfigValue("assetName") as? String ?? ""
        let fitString = getConfigValue("fit") as? String ?? "cover"
        
        // Sécurité : si pas de nom de fichier, on arrête
        if assetName.isEmpty { return }
        
        // 1. Trouver le fichier dans le dossier "public" (géré par Capacitor)
        // Capacitor place le contenu du dossier 'dist'/'www' dans un dossier 'public' à la racine du bundle
        guard let url = Bundle.main.url(forResource: "public/\(assetName)", withExtension: "riv") else {
            print("❌ RiveSplashScreen: Fichier introuvable dans le bundle public: public/\(assetName).riv")
            return
        }

        // 2. Charger les données binaires du fichier
        guard let data = try? Data(contentsOf: url) else {
            print("❌ RiveSplashScreen: Impossible de lire les données du fichier")
            return
        }

        // 3. Initialiser Rive avec ces données (RiveFile)
        guard let riveFile = try? RiveFile(data: data) else {
            print("❌ RiveSplashScreen: Le fichier .riv semble corrompu ou invalide")
            return
        }

        // 4. Mapping du mode Fit (conforme à la doc Rive Runtime)
        let fit: RiveRuntime.Fit
        switch fitString.lowercased() {
        case "contain": fit = .contain
        case "fill": fit = .fill
        case "fitwidth": fit = .fitWidth
        case "fitheight": fit = .fitHeight
        case "none": fit = .none
        case "scaledown": fit = .scaleDown
        case "layout": fit = .layout
        default: fit = .cover
        }

        // 5. Initialisation du ViewModel (on conserve la référence)
        let viewModel = RiveViewModel(
            riveFile: riveFile,
            fit: fit,
            alignment: .center,
            autoPlay: true
        )
        self.riveViewModel = viewModel

        // 6. Création de la vue (RiveView est une sous-classe de UIView)
        let view = viewModel.createRiveView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.white // Pour éviter la transparence par défaut
        
        self.riveView = view

        // 7. Injection dans la hiérarchie de Capacitor (par-dessus la WebView)
        guard let bridge = self.bridge, let viewController = bridge.viewController else {
            print("❌ RiveSplashScreen: Impossible d'accéder au ViewController de Capacitor")
            return
        }

        viewController.view.addSubview(view)

        // 8. Contraintes Auto Layout (plein écran)
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