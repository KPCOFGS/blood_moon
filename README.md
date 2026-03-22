# Blood Moon

Random blood moon events for Luanti. The sky turns red, a massive crimson moon rises, and hostile mobs become far more dangerous.

![screenshot1](./docs/blood_moon.png)

## Features

- **Random trigger** — 1 in 3 chance each night
- **Red sky** — dark red sky, red fog, red-tinted stars
- **Blood moon** — large crimson moon texture (2x scale)
- **Warning** — chat message and sound when blood moon begins
- **Automatic reset** — sky returns to normal at dawn
- **Persistent** — blood moon state saves across world reloads

## Mod API

Blood Moon exposes a global API for other mods to integrate with:

```lua
bloodmoon.is_active()       -- returns true during a blood moon
bloodmoon.get_damage_mult() -- returns 2.0 during blood moon, 1.0 otherwise
bloodmoon.get_speed_mult()  -- returns 2.0 during blood moon, 1.0 otherwise
```

## Integration with Infectious mod

When used alongside the **Infectious** mod, blood moon automatically:

- Doubles zombie damage and movement speed
- Doubles spawn frequency (every 2.5s instead of 5s)
- Doubles maximum pack size (up to 6 per spawn)
- Infected Brute gets 95% damage reduction
- Void Reaper spawn rate tripled

## Dependencies

No hard dependencies. Works standalone on any game.

## License

- Code: MIT
- Textures: CC BY-SA 4.0
