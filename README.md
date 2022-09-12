# TF2Classic-CritVsCond
TF2Classic's `or_crit_vs_playercond` attribute, expanded.

## Features
- Easy configuration
- Allows usage of any available condition
- Option to deal mini-crits instead of crits
- Apply effect to sentry, if using PDA item definition index
- Weapon-only effect, eliminating the need of using `provide_on_active` attribute

## Requirements
[AnyMap](https://github.com/dysphie/sm-anymap)

## ConVars
### sm_critvscond_reload
- Parse configuration file without reloading plugin

## Configuration File
The configuration file is stored in `addons/sourcemod/configs/TF2Classic-CritVsCond.cfg`

Each weapon defined in the configuration file has its own section:
- The value of `cond` is the Condition ID the effect will be applied against
- The value of `crittype` is the type of crit that will be applied: 
#### 1 = Crit 
#### 2 = Mini-Crit 

Any other value will be ignored.

## Example
```js

"Weapons"
{
	"25"        			// Item definition index for Engineer's PDA
	{
		"cond"		"109" 	// TF_COND_TRANQUILIZED
		"crittype"	"2" 	// minicrit
	}
	"8"        			// Item definition index for Medic's Bonesaw
	{
		"cond"		"21" 	// TF_COND_HEALTH_BUFF
		"crittype"	"1" 	// crit
	}
}
```
