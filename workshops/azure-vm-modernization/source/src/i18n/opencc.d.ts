declare module 'opencc-js/cn2t' {
  export function Converter(options: { from: 'cn'; to: 'twp' }): (text: string) => string;
}
