package com.mybestpro.plugins.rivesplashscreen

import android.animation.Animator
import android.animation.AnimatorListenerAdapter
import android.graphics.Color
import android.util.Log
import android.view.ViewGroup
import android.widget.FrameLayout
import app.rive.runtime.kotlin.RiveAnimationView
import app.rive.runtime.kotlin.core.File as RiveFile
import app.rive.runtime.kotlin.core.Fit
import app.rive.runtime.kotlin.core.Alignment
import com.getcapacitor.Plugin
import com.getcapacitor.PluginCall
import com.getcapacitor.PluginMethod
import com.getcapacitor.annotation.CapacitorPlugin

@CapacitorPlugin(name = "RiveSplashScreen")
class RiveSplashScreenPlugin : Plugin() {

    companion object {
        private const val TAG = "RiveSplashScreen"
    }

    private var riveView: RiveAnimationView? = null
    private var riveFile: RiveFile? = null
    private var parentLayout: ViewGroup? = null

    override fun load() {
        super.load()

        // L'initialisation de Rive est automatique via androidx.startup
        activity.runOnUiThread {
            setupRiveView()
        }
    }

    private fun setupRiveView() {
        val assetName = config.getString("assetName")

        // Sécurité : Si pas de config, on ne fait rien
        if (assetName.isNullOrEmpty()) {
            Log.w(TAG, "Aucun assetName configuré, splash screen désactivé")
            return
        }

        val fitModeString = config.getString("fit", "cover")
        val fitMode = when (fitModeString?.lowercase()) {
            "contain" -> Fit.CONTAIN
            "fill" -> Fit.FILL
            "fitwidth" -> Fit.FIT_WIDTH
            "fitheight" -> Fit.FIT_HEIGHT
            "none" -> Fit.NONE
            "scaledown" -> Fit.SCALE_DOWN
            // "layout" -> Fit.LAYOUT
            else -> Fit.COVER
        }

        val pathInAssets = "public/$assetName.riv"

        // Chargement du fichier depuis les assets
        val bytes: ByteArray
        try {
            bytes = context.assets.open(pathInAssets).use { it.readBytes() }
        } catch (e: Exception) {
            Log.e(TAG, "Impossible de charger le fichier: $pathInAssets", e)
            return
        }

        // Création du fichier Rive
        try {
            riveFile = RiveFile(bytes)
        } catch (e: Exception) {
            Log.e(TAG, "Fichier .riv invalide ou corrompu: $pathInAssets", e)
            return
        }

        // Création de la vue
        riveView = RiveAnimationView(context).apply {
            layoutParams = FrameLayout.LayoutParams(
                FrameLayout.LayoutParams.MATCH_PARENT,
                FrameLayout.LayoutParams.MATCH_PARENT
            )
            setBackgroundColor(Color.WHITE)

            // Chargement avec setRiveFile (méthode correcte pour les assets)
            setRiveFile(
                file = riveFile!!,
                fit = fitMode,
                alignment = Alignment.CENTER,
                autoplay = true
            )
        }

        // Ajout à la vue racine de l'activité (par-dessus la WebView)
        parentLayout = activity.window.decorView.findViewById(android.R.id.content)
        parentLayout?.addView(riveView)
    }

    @PluginMethod
    fun hide(call: PluginCall) {
        val duration = call.getInt("fadeDuration", 400)?.toLong() ?: 400L

        activity.runOnUiThread {
            if (riveView == null) {
                call.resolve()
                return@runOnUiThread
            }

            riveView?.animate()
                ?.alpha(0f)
                ?.setDuration(duration)
                ?.setListener(object : AnimatorListenerAdapter() {
                    override fun onAnimationEnd(animation: Animator) {
                        cleanup()
                        call.resolve()
                    }
                })
        }
    }

    override fun handleOnDestroy() {
        cleanup()
        super.handleOnDestroy()
    }

    private fun cleanup() {
        riveView?.let {
            parentLayout?.removeView(it)
        }
        riveView = null
        riveFile = null
        parentLayout = null
    }
}