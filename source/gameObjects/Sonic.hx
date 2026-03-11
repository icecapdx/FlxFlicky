package gameObjects;

import gameObjects.PlayerObject;

class Sonic extends PlayerObject // we extend the player object class so we won't have to readd the variables to each char
{
    public function new() {
        super();
        heightRadiusHitbox = heightRadius - 3;
    }
}