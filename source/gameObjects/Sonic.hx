package gameObjects;

import flixel.graphics.frames.FlxAtlasFrames;
import gameObjects.PlayerObject;

using StringTools;

class Sonic extends PlayerObject // we extend the player object class so we won't have to readd the variables to each char
{
    var boredTimer:Float = 0;

    public function new(X:Float = 0, Y:Float = 0)
    {
        super(X, Y);

        loadGraphic("assets/images/Sonic.png", true);
        frames = FlxAtlasFrames.fromSparrow(
            "assets/images/Sonic.png",
            "assets/images/Sonic.xml"
        );

        animation.addByPrefix("idle",      "idle",      12, true);
        animation.addByPrefix("walk",      "walk",      12, true);
        animation.addByPrefix("run",       "run",       12, true);
        animation.addByPrefix("roll",      "roll",      12, true);
        animation.addByPrefix("spindash",  "spindash",  12, true);
        animation.addByPrefix("down",      "down",      12, true);
        animation.addByPrefix("boredInit", "bored",      4, false);
        animation.addByPrefix("boredLoop", "boredLoop",  4, true);

        animation.callback = function(name:String, frameNumber:Int, frameIndex:Int) {
            if (name == "boredInit") {
                var boredInit = animation.getByName("boredInit");
                if (boredInit != null && frameNumber == boredInit.frames.length - 1)
                    animation.play("boredLoop");
            }
        };

        setSize(standingBounds.widthRadius * 2, standingBounds.heightRadius * 2);

        var frameW:Float = frameWidth;
        var frameH:Float = frameHeight;
        offset.set(
            frameW * 0.5 - standingBounds.widthRadius,
            frameH - standingBounds.heightRadius * 3.5
        );

        animation.play("idle");
    }

    override public function update(elapsed:Float)
    {
        super.update(elapsed);
        updateAnim(elapsed);
    }

    function updateAnim(elapsed:Float):Void
    {
        if (xSpeed != 0)
            flipX = xSpeed < 0;

        var absSpeed = Math.abs(xSpeed);

        if (!isGrounded || isRolling || inputX != 0 || inputY != 0)
        {
            boredTimer = 0;
        }
        else
        {
            boredTimer += elapsed;
        }

        if (!isGrounded)
        {
            if (isBall || isRolling)
                animation.play("roll");
            return;
        }

        if (inputY < 0 && !isRolling)
        {
            animation.play("down");
            return;
        }

        if (isRolling)
        {
            animation.play("roll");
            return;
        }

        if (absSpeed < 5)
        {
            if (boredTimer >= 9)
            {
                if (animation.name == null || !animation.name.startsWith("bored"))
                    animation.play("boredInit");
            }
            else
            {
                animation.play("idle");
            }
        }
        else if (absSpeed < 200)
        {
            animation.play("walk");
        }
        else
        {
            animation.play("run");
        }
    }
}