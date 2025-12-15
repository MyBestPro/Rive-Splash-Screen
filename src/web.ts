import { WebPlugin } from '@capacitor/core';

import type { RiveSplashScreenPlugin } from './definitions';

export class RiveSplashScreenWeb extends WebPlugin implements RiveSplashScreenPlugin {
  async hide(): Promise<void> {
    console.warn('RiveSplashScreen: Ce plugin est uniquement disponible sur iOS et Android.');
  }
}
