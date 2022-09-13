# TF2Classic-CritVsCond
TF2Classic's `or_crit_vs_playercond` attribute, expanded.

## Features
- Easy configuration
- Allows usage of any available condition
- Option to deal mini-crits instead of crits
- Option to check condition on attacker instead of victim
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

`cond` is the Condition ID the effect will be applied against

`minicrit` is the type of crit that will be applied (optional) 
- `0` Crit **_(default)_**
- `1` Mini-Crit 

`selfcond` determines wether the condition check should be applied on the victim or the attacker (optional) 
- `0` Victim **_(default)_** 
- `1` Attacker 


## Example
```js

"Weapons"
{
	"25"        			// Item definition index for Engineer's PDA
	{
		"cond"		"109" 	// TF_COND_TRANQUILIZED
		"minicrit"	"1"
	}
	
	"6"        			// Item definition index for soldier's shovel
	{
		"cond"		"22" 	// TF_COND_BURNING
		"minicrit"	"0" 	// crit
		"selfcond"	"1"	// check owner of weapon's cond
	}

	"40"        			// Item definition index for soldier's R.P.G.
	{
		"cond"		"81" 	// TF_COND_BLASTJUMPING
	}				// no crit type specified, therefore 0 (crit)
}
```
