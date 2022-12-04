# TF2Classic-DamageConditions
Expansion upon TF2Classic's condition related attributes

## Features
- Easy configuration
- Allows usage of any available condition
- Option to deal mini-crits instead of crit vs condition
- Option to check condition on self instead of target
- Apply effect to sentry, if using PDA item definition index
- Weapon-only effect, eliminating the need of using `provide_on_active` attribute
- Apply condition to target and/or self
- Option to gib on kill, or if victim has condition

## Requirements
[AnyMap](https://github.com/dysphie/sm-anymap)

## ConVars
### sm_damageconditions_reload
- Parse configuration file without reloading plugin

## Configuration File
The configuration file is stored in `addons/sourcemod/configs/TF2Classic-DamageConditions.cfg`

Each weapon defined in the configuration file has its own section.

If using a default value, the key is optional and does not need to be defined

### mode
> Player to apply condition check to, if ID is present
- `none`  **_(default)_** 
- `victim`
- `attacker`

### cond
> Condition to check for
- Any valid Condition ID value (Default is -1)

### crittype
> Crit type to deal if check is successful
- `none` **_(default)_** 
- `minicrit`
- `crit`

### gib
> Gib victim on kill
- `default` **_(default)_** 
- `always`
- `never`
- `cond` (gib vs cond)
- `condcrit` (gib if crit vs cond)

### addcond / addcond_self
> Apply condition to self/victim on hit
#### cond
- Any valid Condition ID value (Default is -1)
#### duration
- Any float value (Default is 0.0)
- Set to -1 for infinite duration

## Example
```js

"Weapons"
{
	// revolver that applies marked-for-death to disguised spies and yourself
	"24"					// spy stock revolver
	{
		"mode"		"victim"
		"crittype"	"none"
		"cond"		"3"		// TF_COND_DISGUISED
		"gib"		"cond"
		
		"addcond"
		{
			"cond"		"30"	// TF_COND_MARKEDFORDEATH
			"duration"	"5.0"
		}

		"addcond_self"
		{
			"cond"		"30" 	// TF_COND_MARKEDFORDEATH
			"duration"	"5.0"
		}
	}
}
```
