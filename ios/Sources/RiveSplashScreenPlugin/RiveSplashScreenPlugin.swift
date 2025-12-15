import Foundation
import Capacitor
import RiveRuntime
import UIKit

// MARK: - RiveSplashHelper
/// Helper statique pour afficher le splash screen Rive immédiatement au lancement.
/// Doit être appelé dans l'AppDelegate avant le return de didFinishLaunchingWithOptions.
public class RiveSplashHelper {

    /// Référence interne à la vue Rive du splash screen
    internal static var splashView: RiveView?

    /// Référence au ViewModel pour garder l'animation en vie
    private static var viewModel: RiveViewModel?

    /// Affiche le splash screen Rive dans la window donnée.
    ///
    /// - Parameters:
    ///   - window: La UIWindow principale de l'application
    ///   - assetName: Le nom du fichier .riv (sans extension), ex: "public/splash_anim"
    ///   - fit: Le mode d'ajustement Rive (par défaut .cover)
    ///   - backgroundColor: La couleur de fond de la vue (par défaut .white)
    @objc public static func show(
        in window: UIWindow?,
        assetName: String,
        fit: RiveFit = .cover,
        backgroundColor: UIColor = .white
    ) {
        guard let window = window else {
            print("RiveSplashHelper: Window is nil, cannot show splash screen")
            return
        }

        guard !assetName.isEmpty else {
            print("RiveSplashHelper: assetName is empty, cannot show splash screen")
            return
        }

        // Initialisation du ViewModel avec le nom du fichier
        let riveViewModel = RiveViewModel(
            fileName: assetName,
            fit: fit,
            alignment: .center
        )
        viewModel = riveViewModel

        // Création de la vue Rive
        let riveView = riveViewModel.createRiveView()
        riveView.translatesAutoresizingMaskIntoConstraints = false
        riveView.backgroundColor = backgroundColor

        // Stockage dans la variable statique
        splashView = riveView

        // Ajout à la window (pas au ViewController)
        window.addSubview(riveView)

        // Contraintes AutoLayout pour le plein écran
        NSLayoutConstraint.activate([
            riveView.topAnchor.constraint(equalTo: window.topAnchor),
            riveView.bottomAnchor.constraint(equalTo: window.bottomAnchor),
            riveView.leadingAnchor.constraint(equalTo: window.leadingAnchor),
            riveView.trailingAnchor.constraint(equalTo: window.trailingAnchor)
        ])

        // S'assurer que la vue est au-dessus de tout
        window.bringSubviewToFront(riveView)
    }

    /// Version avec String pour le fit (utile pour l'appel depuis Objective-C ou configuration)
    @objc public static func show(
        in window: UIWindow?,
        assetName: String,
        fitString: String,
        backgroundColor: UIColor = .white
    ) {
        let fit = parseFit(from: fitString)
        show(in: window, assetName: assetName, fit: fit, backgroundColor: backgroundColor)
    }

    /// Parse une chaîne de caractères en RiveFit
    private static func parseFit(from string: String) -> RiveFit {
        switch string.lowercased() {
        case "contain": return .contain
        case "fill": return .fill
        case "fitwidth": return .fitWidth
        case "fitheight": return .fitHeight
        case "none": return .noFit
        case "scaledown": return .scaleDown
        case "layout": return .layout
        default: return .cover
        }
    }

    /// Nettoie les ressources du splash screen
    internal static func cleanup() {
        splashView?.removeFromSuperview()
        splashView = nil
        viewModel = nil
    }
}

// MARK: - RiveSplashScreenPlugin
/// Plugin Capacitor pour contrôler le splash screen Rive depuis JavaScript.
/// Note: L'affichage initial doit être fait via RiveSplashHelper dans l'AppDelegate.
@objc(RiveSplashScreenPlugin)
public class RiveSplashScreenPlugin: CAPPlugin, CAPBridgedPlugin {

    public let identifier = "RiveSplashScreenPlugin"
    public let jsName = "RiveSplashScreen"
    public let pluginMethods: [CAPPluginMethod] = [
        CAPPluginMethod(name: "hide", returnType: CAPPluginReturnPromise)
    ]

    /// Cache la vue splash screen avec une animation de fade-out.
    ///
    /// - Parameter call: L'appel Capacitor avec option `fadeDuration` en millisecondes (défaut: 400)
    @objc func hide(_ call: CAPPluginCall) {
        let durationMs = call.getDouble("fadeDuration") ?? 400
        let durationSec = durationMs / 1000.0

        DispatchQueue.main.async {
            guard let view = RiveSplashHelper.splashView else {
                // Pas de vue à cacher, on résout quand même
                call.resolve()
                return
            }

            UIView.animate(withDuration: durationSec, animations: {
                view.alpha = 0
            }) { _ in
                // Nettoyage des ressources
                RiveSplashHelper.cleanup()
                call.resolve()
            }
        }
    }
}
