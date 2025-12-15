import { registerPlugin } from '@capacitor/core';

import type { RiveSplashScreenPlugin } from './definitions';

const RiveSplashScreen = registerPlugin<RiveSplashScreenPlugin>('RiveSplashScreen', {
  web: () => import('./web').then((m) => new m.RiveSplashScreenWeb()),
});

export * from './definitions';
export { RiveSplashScreen };
