package gameObjects;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.util.FlxFSM;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.math.FlxMath;
import meta.data.Global;
import meta.data.SonicMath;

using StringTools;

class PlayerObject extends FlxSprite
{
    // in da same order as SPG has it
    // idk if like keeping these all as floats would cause anything but i hope nto
    // VARS FROM SPG:Basics
    public var xPosition:Float = 0; // X Position (X) 	The X-coordinate of the object's center. 
    public var yPosition:Float = 0; // Y Position (Y) 	The Y-coordinate of the object's center. 
    public var xSpeed:Float = 0; // X Speed 	Speed along the X-axis. 
    public var ySpeed:Float = 0; // Y Speed 	Speed along the Y-axis.
    public var gAngle:Float = 0; // Ground Angle (GAngle) 	The object's angle, or angle on the ground. 
    public var gSpeed:Float = 0; // Ground Speed (GSpeed) 	Speed along the Ground Angle. 
    public var horizRadi:Float = 0; // Horizontal/Width Radius 	The object's width from its origin pixel, left to right. 
    public var vertiRadi:Float = 0; // Vertical/Height Radius 	The object's height from its origin pixel, up to down. 

    // making all of these intergers should be good i think 
    // VARS FROM SPG:Characters
    public var pushRadius:Int = 10; // Push Radius 	10 
    public var widthRadius:Int = 9; // Width Radius 	9 (19 wide)
    public var heightRadius:Int = 19; // Height Radius 	19 (29 pixels tall)
    // for these two I can prolly just set the widthRaidus and heightRadius to the rolling ones instead of having variables for them
    // especially since they probably differ per character.
    public var widthRadiusRolling:Int = 7; // Width Radius (Rolling) 	7 (15 pixels wide)
    public var heightRadiusRolling:Int = 14; // Height Radius (Rolling) 	14 (29 pixels tall)
    // back to our regularly scheduled programming
    public var heightRadiusHitbox:Int = 0; // Height Radius (Hitbox) 	Height Radius - 3 (6 shorter) 
    public var widthRadiusHitbox:Int = 8; // Hitbox Width Radius 	8 (17 pixels wide)
    public var jump_force:Float = 6.5; // jump_force 	6.5 (6 pixels and 128 subpixels)
    // CHAR SPECIFIC NOTES (adding this in case I decide to do tails and knux in the future, also this is pulled straight from the SPG):

    // SONIC NOTES:

    // Hitbox Height Radius (Crouching): 10 
    // When crouching as Sonic only, 12 pixels is added to the hitbox's Y position to put it near the ground. In Sonic 3 and onwards, crouching does not affect Sonic's hitbox. 

    // TAILS NOTES:

    // Height Radius: 15 (31 pixels tall).
    // Flying has the same size as standing. 

    // KNUCKLES NOTES:

    // jump_force: 6 

    // Knuckles (Gliding/Climbing):

    // Width Radius: 10 (21 pixels tall) 
    // Height Radius: 10 (21 pixels tall) 
    //  Falling has the same size as standing. 
    
}