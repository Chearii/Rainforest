# Rainforest
Misadventures with creating a multi-BVH system in GameMaker
The name comes from the fact that a forest has multiple trees; this system *also* has multiple trees

Primarily learning as I go here, so please don't expect much! I mainly just want a dumping ground for all this ^^;

I owe a lot to Erin Catto's great insight on optimized collision, and just in general parts of [Box2D](https://github.com/erincatto/box2d), which I referenced often during the making of all this; there are parts of a [TypeScript implementation of BVH trees](https://github.com/Sopiro/DynamicBVH/tree/master) by Sopiro that I also adapted into GML for this

Still a WIP; PLANS.txt shows mainly what I'm working towards, as I generally want a malleable, portable GML codebase that can be used for fast, arbitrary collisions *not tied to any object* in GameMaker games, without the need for any extensions to get extra efficiency

## License
Both Box2D and Sopiro's BVH implementation are under the MIT license; this codebase is also under that license, and both of the prior licenses are included in this codebase (check the "notes" folder in rainforest.yyp)

Go nuts (within reason)!
