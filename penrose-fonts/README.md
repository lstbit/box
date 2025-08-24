# Penrose Fonts

- `private-build-plans.toml` contains custom build plans for making the Penrose fonts.

## Dependencies

- Iosevka Source Directory
- NodeJS@20
- TTFautohint
- fontforge (Nerd Fonts Patcher)
- python-fontforge (Nerd Fonts Patcher)

## Fonts
We build the fonts with a width of 600 so use even pt sizes in your applicaiton configurations.

- Penrose Sans (Quasi-proportional Sans-Serif)
- Penrose Mono (monospace variant w/ ligatures)
- Penrose Term (monospace variant for use with terminals)
		
All fonts are built with the following weights:
- Light:      400
- Regular:    500
- Bold:       700
- Extra Bold: 800
- Heavy:      900

## Nerd Fonts Patching

The nerd fonts patcher is required, info can be found [here](https://github.com/ryanoasis/nerd-fonts?tab=readme-ov-file#option-10-patch-your-own-font).
