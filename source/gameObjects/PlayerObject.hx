package gameObjects;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.math.FlxPoint;
import flixel.system.FlxSound;
import flixel.tile.FlxTilemap;
import meta.data.SonicMath;

class PlayerStats
{
    public var acceleration:Float        = 168.75;
    public var deceleration:Float        = 1800.0;
    public var friction:Float            = 168.75;
    public var topSpeed:Float            = 360.0;
    public var slopeFactor:Float         = 450.0;
    public var slopeRollDown:Float       = 1125.0;
    public var slopeRollUp:Float         = 281.25;

    public var rollDeceleration:Float    = 450.0;
    public var rollFriction:Float        = 84.375;
    public var minSpeedToRoll:Float      = 60.0;
    public var unrollSpeed:Float         = 30.0;
    public var minSpeedToBrake:Float     = 240.0;

    public var airAcceleration:Float     = 337.5;
    public var gravity:Float             = 787.5;
    public var maxJumpHeight:Float       = 390.0;
    public var minJumpHeight:Float       = 240.0;

    public var slideAngle:Float          = 45.0;
    public var fallAngle:Float           = 80.0;
    public var minSpeedToFall:Float      = 150.0;
    public var controlLockDuration:Float = 0.5;

    public function new() {}
}

class PlayerCollision
{
    public var heightRadius:Float    = 19.0;
    public var widthRadius:Float     = 9.0;
    public var pushRadius:Float      = 10.0;
    public var groundExtension:Float = 17.0;
    public var pushHeightOffset:Float = 8.0;

    public var heightRadiusRolling:Float = 14.0;
    public var widthRadiusRolling:Float  = 7.0;

    public function new() {}
}

enum PlayerStateID { Regular; Rolling; Braking; Air; Spring; }

class PlayerObject extends FlxSprite
{
    public var xPosition:Float = 0;
    public var yPosition:Float = 0;

    public var xSpeed:Float = 0;
    public var ySpeed:Float = 0;

    public var gAngle:Float        = 0;
    public var groundNormalX:Float = 0;
    public var groundNormalY:Float = -1;

    public var inputX:Float = 0;
    public var inputY:Float = 0;
    public var inputDotVelocity:Float = 0;

    // state flagz
    public var isGrounded:Bool = false;
    public var isRolling:Bool  = false;
    public var isBall:Bool     = false;
    public var isJumping:Bool  = false;

    // control lock (boooo..)
    public var isControlLocked:Bool   = false;
    public var controlLockTimer:Float = 0.0;

    // res
    public var stats:PlayerStats;
    public var standingBounds:PlayerCollision;
    public var rollingBounds:PlayerCollision;

    // coll map
    public var collisionMap:FlxTilemap;

    // audio shitz
    public var jumpAudio:FlxSound;
    public var brakeAudio:FlxSound;
    public var spinAudio:FlxSound;

    // statemahcine
    public var currentState:PlayerStateID;
    public var lastState:PlayerStateID;

    var _stateRegular:StateRegular;
    var _stateRolling:StateRolling;
    var _stateBraking:StateBraking;
    var _stateAir:StateAir;
    var _stateSpring:StateSpring;

    // bounds shortcut
    public var currentBounds(get, never):PlayerCollision;
    function get_currentBounds():PlayerCollision return isBall ? rollingBounds : standingBounds;

    public function new(X:Float = 0, Y:Float = 0)
    {
        super(X, Y);
        velocity.set(0, 0);
        acceleration.set(0, 0);

        stats          = new PlayerStats();
        standingBounds = new PlayerCollision();
        rollingBounds  = new PlayerCollision();

        _stateRegular = new StateRegular();
        _stateRolling = new StateRolling();
        _stateBraking = new StateBraking();
        _stateAir     = new StateAir();
        _stateSpring  = new StateSpring();

        xPosition = X + standingBounds.widthRadius;
        yPosition = Y + standingBounds.heightRadius;

        changeState(Regular);
    }

    public function changeState(to:PlayerStateID):Void
    {
        if (currentState != null)
            getState(currentState).exit(this);
        lastState    = currentState;
        currentState = to;
        getState(currentState).enter(this);
    }

    function getState(id:PlayerStateID):PlayerState
    {
        return switch (id) {
            case Regular: _stateRegular;
            case Rolling: _stateRolling;
            case Braking: _stateBraking;
            case Air:     _stateAir;
            case Spring:  _stateSpring;
        };
    }

    override public function update(elapsed:Float)
    {
        handleInput();
        handleControlLock(elapsed);
        getState(currentState).step(this, elapsed);
        handleMotion(elapsed);
        syncPosition();
        super.update(elapsed);
    }

    function handleInput():Void
    {
        var right:Bool = FlxG.keys.pressed.RIGHT;
        var left:Bool  = FlxG.keys.pressed.LEFT;
        var up:Bool    = FlxG.keys.pressed.UP;
        var down:Bool  = FlxG.keys.pressed.DOWN;

        var horizontal:Float = right ? 1 : (left ? -1 : 0);
        var vertical:Float   = up   ? 1 : (down  ? -1 : 0);

        if (isControlLocked) horizontal = 0;

        inputX = horizontal;
        inputY = vertical;

        inputDotVelocity = inputX * xSpeed + inputY * ySpeed;
    }

    function handleMotion(elapsed:Float):Void
    {
        var speed:Float   = Math.sqrt(xSpeed * xSpeed + ySpeed * ySpeed);
        var offset:Float  = speed * elapsed;
        var maxStep:Float = currentBounds.widthRadius;
        var steps:Int     = Math.ceil(offset / maxStep);
        if (steps < 1) steps = 1;

        var stepDt:Float = elapsed / steps;
        for (_ in 0...steps)
        {
            applyMotion(stepDt);
            handleWallCollision();
            handleGroundCollision();
            handleCeilingCollision();
        }
    }

    function applyMotion(dt:Float):Void
    {
        if (isGrounded)
        {
            var nx:Float = groundNormalX;
            var ny:Float = groundNormalY;
            xPosition += (xSpeed * -ny + ySpeed * -nx) * dt;
            yPosition += (xSpeed *  nx - ySpeed *  ny) * dt;
        }
        else
        {
            xPosition += xSpeed * dt;
            yPosition += ySpeed * dt;
        }
    }

    public function handleGravity(elapsed:Float):Void
    {
        if (!isGrounded)
            ySpeed += stats.gravity * elapsed;
    }

    public function handleAcceleration(elapsed:Float):Void
    {
        if (inputX != 0)
        {
            if (SonicMath.sign(inputX) == SonicMath.sign(xSpeed) || !isGrounded)
            {
                var amount:Float = isGrounded ? stats.acceleration : stats.airAcceleration;
                if (Math.abs(xSpeed) < stats.topSpeed)
                {
                    xSpeed += inputX * amount * elapsed;
                    if (xSpeed >  stats.topSpeed) xSpeed =  stats.topSpeed;
                    if (xSpeed < -stats.topSpeed) xSpeed = -stats.topSpeed;
                }
            }
            else
            {
                xSpeed += inputX * stats.deceleration * elapsed;
            }
        }
    }

    public function handleDeceleration(elapsed:Float):Void
    {
        if (inputX != 0 && SonicMath.sign(inputX) != SonicMath.sign(xSpeed))
        {
            var amount:Float = isRolling ? stats.rollDeceleration : stats.deceleration;
            if (xSpeed > 0)
            {
                xSpeed -= amount * elapsed;
                if (xSpeed < 0) xSpeed = 0;
            }
            else if (xSpeed < 0)
            {
                xSpeed += amount * elapsed;
                if (xSpeed > 0) xSpeed = 0;
            }
        }
    }

    public function handleFriction(elapsed:Float):Void
    {
        if (isGrounded && (inputX == 0 || isRolling))
        {
            var amount:Float = isRolling ? stats.rollFriction : stats.friction;
            if (xSpeed > 0)
            {
                xSpeed -= amount * elapsed;
                if (xSpeed < 0) xSpeed = 0;
            }
            else if (xSpeed < 0)
            {
                xSpeed += amount * elapsed;
                if (xSpeed > 0) xSpeed = 0;
            }
        }
    }

    public function handleSlope(elapsed:Float):Void
    {
        if (isGrounded)
        {
            var downHill:Bool       = (xSpeed * groundNormalX + ySpeed * groundNormalY) > 0;
            var rollingFactor:Float = downHill ? stats.slopeRollDown : stats.slopeRollUp;
            var amount:Float        = isRolling ? rollingFactor : stats.slopeFactor;
            xSpeed += amount * groundNormalX * elapsed;
        }
    }

    public function handleJump(elapsed:Float):Void
    {
        var jumpJust:Bool = FlxG.keys.justPressed.Z || FlxG.keys.justPressed.SPACE;
        var jumpHeld:Bool = FlxG.keys.pressed.Z     || FlxG.keys.pressed.SPACE;

        if (isGrounded && jumpJust)
        {
            isJumping  = true;
            isRolling  = true;
            isBall     = true;
            ySpeed     = -stats.maxJumpHeight;
            isGrounded = false;
            if (jumpAudio != null) jumpAudio.play();
        }

        if (isJumping && !jumpHeld && ySpeed < -stats.minJumpHeight)
            ySpeed = -stats.minJumpHeight;
    }

    public function handleFall():Void
    {
        if (isGrounded)
        {
            var absAngle:Float = Math.abs(gAngle);
            if (absAngle > stats.slideAngle && Math.abs(xSpeed) <= stats.minSpeedToFall)
            {
                lockControls();
                if (absAngle > stats.fallAngle)
                    isGrounded = false;
            }
        }
    }

    public function lockControls():Void
    {
        if (!isControlLocked)
        {
            inputX           = 0;
            isControlLocked  = true;
            controlLockTimer = stats.controlLockDuration;
        }
    }

    public function unlockControls():Void
    {
        isControlLocked  = false;
        controlLockTimer = 0;
    }

    function handleControlLock(elapsed:Float):Void
    {
        if (isControlLocked)
        {
            inputX = 0;
            if (isGrounded)
            {
                controlLockTimer -= elapsed;
                if (xSpeed == 0 || controlLockTimer <= 0)
                    unlockControls();
            }
        }
    }

    function handleGroundCollision():Void
    {
        if (collisionMap == null) return;

        var b:PlayerCollision = currentBounds;
        var raySize:Float = isGrounded ? b.heightRadius + b.groundExtension : b.heightRadius;
    
        var distA:Float = castGroundRay(xPosition - b.widthRadius, yPosition, raySize);
        var distB:Float = castGroundRay(xPosition + b.widthRadius, yPosition, raySize);
    
        var aHit:Bool = distA <= 0;
        var bHit:Bool = distB <= 0;
        if (aHit != bHit)
        {
            return;
        }
    
        var dist:Float = Math.min(distA, distB);

        if (ySpeed >= 0)
        {
            if (!isGrounded)
            {
                if (dist <= 0)
                {
                    yPosition += dist;
                    xSpeed     = globalToGroundX(xSpeed, ySpeed, groundNormalX, groundNormalY);
                    ySpeed     = 0;

                    isGrounded = true;
                    isJumping  = false;
                    isRolling  = false; 
                    isBall     = false;
                    gAngle     = 0;    // TODO: SLOPES AHHHHH
                    setGroundNormal(0, -1);
                }
            }
            else
            {
                if (dist > b.groundExtension)
                    isGrounded = false;
                else
                    yPosition += dist;
            }
        }
    }

    function globalToGroundX(vx:Float, vy:Float, nx:Float, ny:Float):Float
    {
        var angle:Float = Math.abs(gAngle);
        var xSpeed:Float = vx;

        if (angle > 23)
        {
            var direction:Float = nx < 0 ? -1 : 1;
            if (angle < 45)
                xSpeed = vy * 0.5 * direction;
            else
                xSpeed = vy * direction;
        }
        return xSpeed;
    }

    function handleWallCollision():Void
    {
        if (collisionMap == null) return;

        var b:PlayerCollision = currentBounds;
        var pr:Float = b.pushRadius;

        var checkYs:Array<Float> = [yPosition];
        if (isGrounded && Math.abs(gAngle) < 10)
            checkYs.push(yPosition - b.pushHeightOffset);

        for (wallY in checkYs)
        {
            if (collisionMap.overlapsPoint(FlxPoint.get(xPosition + pr, wallY), false))
            {
                while (collisionMap.overlapsPoint(FlxPoint.get(xPosition + pr, wallY), false))
                    xPosition--;
                if (xSpeed > 0) xSpeed = 0;
                break;
            }
            if (collisionMap.overlapsPoint(FlxPoint.get(xPosition - pr, wallY), false))
            {
                while (collisionMap.overlapsPoint(FlxPoint.get(xPosition - pr, wallY), false))
                    xPosition++;
                if (xSpeed < 0) xSpeed = 0;
                break;
            }
        }
    }

    function handleCeilingCollision():Void
    {
        if (collisionMap == null) return;

        var b:PlayerCollision = currentBounds;
        var topY:Float = yPosition - b.heightRadius;
        var hitE:Bool  = collisionMap.overlapsPoint(FlxPoint.get(xPosition - b.widthRadius, topY), false);
        var hitF:Bool  = collisionMap.overlapsPoint(FlxPoint.get(xPosition + b.widthRadius, topY), false);

        if (hitE || hitF)
        {
            while (collisionMap.overlapsPoint(FlxPoint.get(xPosition - b.widthRadius, yPosition - b.heightRadius), false)
                || collisionMap.overlapsPoint(FlxPoint.get(xPosition + b.widthRadius, yPosition - b.heightRadius), false))
            {
                yPosition++;
            }
            if (ySpeed < 0) ySpeed = 0;
        }
    }

    function castGroundRay(sensorX:Float, centerY:Float, hRad:Float):Float
    {
        var startY:Float = centerY - hRad;
        var expectedFeetY:Float = centerY + hRad;
        var scanLimit:Int = Std.int(hRad * 2) + 32;
        for (i in 0...scanLimit)
        {
            if (collisionMap.overlapsPoint(FlxPoint.get(sensorX, startY + i), false))
                return (startY + i) - expectedFeetY;
        }
        return 32;
    }

    public function setGroundNormal(nx:Float, ny:Float):Void
    {
        groundNormalX = nx;
        groundNormalY = ny;
        var radians:Float = Math.atan2(nx, -ny);
        gAngle = -(radians * 180 / Math.PI);
    }

    function syncPosition():Void
    {
        x = xPosition - currentBounds.widthRadius;
        y = yPosition - currentBounds.heightRadius;
    }
}

    class PlayerState
    {
        public function new() {}
        public function enter(p:PlayerObject):Void {}
        public function exit(p:PlayerObject):Void  {}
        public function step(p:PlayerObject, dt:Float):Void {}
    }

    class StateRegular extends PlayerState
    {
        public function new() { super(); }

        override public function enter(p:PlayerObject):Void
        {
            p.isBall = false;
        }

        override public function step(p:PlayerObject, dt:Float):Void
        {
            p.handleFall();
            p.handleGravity(dt);
            p.handleJump(dt);
            p.handleSlope(dt);
            p.handleAcceleration(dt);
            p.handleFriction(dt);

            if (p.isGrounded)
            {
                if (p.inputDotVelocity < 0 && Math.abs(p.xSpeed) >= p.stats.minSpeedToBrake)
                    p.changeState(Braking);
                else if (p.inputY < 0 && Math.abs(p.xSpeed) > p.stats.minSpeedToRoll)
                    p.changeState(Rolling);
            }
            else
            {
                p.changeState(Air);
            }
        }
    }

    class StateRolling extends PlayerState
    {
        public function new() { super(); }

        override public function enter(p:PlayerObject):Void
        {
            p.isRolling = true;
            p.isBall    = true;
            if (p.spinAudio != null) p.spinAudio.play();
        }

        override public function step(p:PlayerObject, dt:Float):Void
        {
            p.handleFall();
            p.handleGravity(dt);
            p.handleJump(dt);
            p.handleSlope(dt);
            p.handleDeceleration(dt);
            p.handleFriction(dt);

            if (p.isGrounded)
            {
                if (Math.abs(p.xSpeed) < p.stats.unrollSpeed)
                {
                    p.isRolling = false;
                    p.changeState(Regular);
                }
            }
            else
            {
                p.changeState(Air);
            }
        }
    }

    class StateBraking extends PlayerState
    {
        public function new() { super(); }

        override public function enter(p:PlayerObject):Void
        {
            if (p.brakeAudio != null) p.brakeAudio.play();
        }

        override public function step(p:PlayerObject, dt:Float):Void
        {
            p.handleFall();
            p.handleJump(dt);
            p.handleDeceleration(dt);

            if (p.isGrounded)
            {
                if (p.inputDotVelocity >= 0)
                    p.changeState(Regular);
                else if (p.inputY < 0)
                    p.changeState(Rolling);
            }
            else
            {
                p.changeState(Air);
            }
        }
    }

    class StateAir extends PlayerState
    {
        public function new() { super(); }

        public var lastAbsoluteHorizontalSpeed:Float = 0;
        public var canUseShield:Bool = false;

        override public function enter(p:PlayerObject):Void
        {
            canUseShield = p.isRolling;
            lastAbsoluteHorizontalSpeed = Math.abs(p.xSpeed);

            if (p.isRolling)
                p.isBall = true;
            else
            {
                p.isBall    = false;
                p.isRolling = false;
            }
        }

        override public function step(p:PlayerObject, dt:Float):Void
        {
            p.handleGravity(dt);
            p.handleJump(dt);
            p.handleAcceleration(dt);

            if (p.isGrounded)
            {
                if (p.inputY < 0)
                    p.changeState(Rolling);
                else
                    p.changeState(Regular);
            }
        }
    }

    class StateSpring extends PlayerState
    {
        public function new() { super(); }

        override public function enter(p:PlayerObject):Void
        {
            p.isJumping = false;
            p.isRolling = false;
            p.isBall    = false;
        }

        override public function step(p:PlayerObject, dt:Float):Void
        {
            p.handleGravity(dt);
            p.handleAcceleration(dt);

            if (p.isGrounded)
                p.changeState(Regular);
            else if (p.ySpeed > 0)
                p.changeState(Air);
        }
    }