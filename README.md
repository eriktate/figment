# figment
A simple, small, "from scratch" game engine for making the types of games I want to make

## Why?
I'm a programmer, I like to understand how things work, and I think "engine-level" problems are really fun to work on. It would probably be smarter to use something like Godot or Unity, but those suck the fun out of creating for me. I also think I can probably create a more efficient engine for the specific games I want to make without the baggage of building something completely general purpose

## What types of games?
Mostly 2D, often pixel art, tile-based games. A lot of my ideas end up being sidescrolling platformers, but top down games as well. And who knows, maybe one day something that doesn't quite fit "traditional" 2D games

## How do you choose what to write from scratch?
Basically anything I'm interested in doing myself. For example, I'm not (yet) interested in:
- Windowing/input
- Playing sound/music
- Rasterizing fonts
- Loading PNGs
- OpenGL function loading

This list might grow as I realize I need access to more things, but all of the submodules in the `vendor/` folder solve problems I'm not interested in tackling

## Is this an actual engine?
Depends on your definition. My current plan is to have some core libraries and systems that get re-used across all of my games along with a small handful of tools to make it easier to add content. I don't really have any aspirations to make a full-blown, general purpose game editor like Godot.

## What's the expected workflow?
I'm still working on this, but I have plans for:
- Asset creation and management through Aseprite. I have some ideas for an asset pipeline that uses Aseprite as the core and might involve some code generation
- A scene/level editor. This will mostly be for tile painting and placing entities
- Potentially an entity editor. This will mostly be for simple things like visually aligning bounding boxes, setting origins, etc. Could also select sprites/animations from here
- Hot code reloading? We'll see I guess
- Everything else is just code
