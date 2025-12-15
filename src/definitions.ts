export interface RiveSplashScreenPlugin {
  // Masque le splash screen avec un fondu
  hide(options?: { fadeDuration?: number }): Promise<void>;
}
