import { WebPlugin } from '@capacitor/core';

import type { RiveSplashScreenPlugin } from './definitions';

export class RiveSplashScreenWeb extends WebPlugin implements RiveSplashScreenPlugin {
  async echo(options: { value: string }): Promise<{ value: string }> {
    console.log('ECHO', options);
    return options;
  }
}
