export interface RiveSplashScreenPlugin {
  echo(options: { value: string }): Promise<{ value: string }>;
}
