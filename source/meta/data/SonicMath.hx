// should be a 1:1 port of the code from spg https://info.sonicretro.org/SPG:Calculations
package meta.data;

class SonicMath {
    // -- CONVERSION FUNCTIONS --

    // converts Clockwise hex angles into Anti-Clockwise degree angles.
    public static function hexToDeg(hexAng:Int):Float {
        return ((256 - hexAng) / 256) * 360;
    }

    public static function degToHex(degAng:Float):Int {
        return Std.int(((360 - degAng) / 360) * 256);
    }

    // converts Pixels and Subpixels to a Decimal value.
    public static function subpixelToDecimal(pix:Int, subpix:Int):Float {
        return pix + (subpix / 256.0);
    }

    // -- TRIGONOMETRIC TABLES --

    // To perform (Co)sine fast, list of pre-calculated values is used
    public static var SINCOSLIST:Array<Int> = [
        0,6,12,18,25,31,37,43,49,56,62,68,74,80,86,92,97,103,109,115,120,126,131,136,142,147,152,157,162,167,171,176,181,185,189,193,197,201,205,209,212,216,219,222,225,228,231,234,236,238,241,243,244,246,248,249,251,252,253,254,254,255,255,255,
        256,255,255,255,254,254,253,252,251,249,248,246,244,243,241,238,236,234,231,228,225,222,219,216,212,209,205,201,197,193,189,185,181,176,171,167,162,157,152,147,142,136,131,126,120,115,109,103,97,92,86,80,74,68,62,56,49,43,37,31,25,18,12,6,
        0,-6,-12,-18,-25,-31,-37,-43,-49,-56,-62,-68,-74,-80,-86,-92,-97,-103,-109,-115,-120,-126,-131,-136,-142,-147,-152,-157,-162,-167,-171,-176,-181,-185,-189,-193,-197,-201,-205,-209,-212,-216,-219,-222,-225,-228,-231,-234,-236,-238,-241,-243,-244,-246,-248,-249,-251,-252,-253,-254,-254,-255,-255,-255,
        -256,-255,-255,-255,-254,-254,-253,-252,-251,-249,-248,-246,-244,-243,-241,-238,-236,-234,-231,-228,-225,-222,-219,-216,-212,-209,-205,-201,-197,-193,-189,-185,-181,-176,-171,-167,-162,-157,-152,-147,-142,-136,-131,-126,-120,-115,-109,-103,-97,-92,-86,-80,-74,-68,-62,-56,-49,-43,-37,-31,-25,-18,-12,-6
    ];

    // Used in various functions (possibly atan list?)
    public static var ANGLELIST:Array<Int> = [
        0,0,0,0,1,1,1,1,1,1,2,2,2,2,2,2,3,3,3,3,3,3,3,4,4,4,4,4,4,5,5,5,5,5,5,6,6,6,6,6,6,6,7,7,7,7,7,7,8,8,8,8,8,8,8,9,9,9,9,9,9,10,10,10,10,10,10,10,11,11,11,11,11,11,11,12,12,12,12,12,12,12,13,13,13,13,13,13,13,14,14,14,14,14,14,14,15,15,15,15,15,15,15,16,16,16,16,16,16,16,17,17,17,17,17,17,17,17,18,18,18,18,18,18,18,19,19,19,19,19,19,19,19,20,20,20,20,20,20,20,20,21,21,21,21,21,21,21,21,21,22,22,22,22,22,22,22,22,23,23,23,23,23,23,23,23,23,24,24,24,24,24,24,24,24,24,25,25,25,25,25,25,25,25,25,25,26,26,26,26,26,26,26,26,26,27,27,27,27,27,27,27,27,27,27,28,28,28,28,28,28,28,28,28,28,28,29,29,29,29,29,29,29,29,29,29,29,30,30,30,30,30,30,30,30,30,30,30,31,31,31,31,31,31,31,31,31,31,31,31,32,32,32,32,32,32,32,0
    ];

    // Returns a hex Sine value from -256 to 256 (divide 256 to get a -1 to 1 decimal result)
    public static function hexSin(hexAng:Int):Int {
        return SINCOSLIST[hexAng % 256];
    }

    public static function hexCos(hexAng:Int):Int {
        return hexSin(hexAng + 64);
    }

    // Returns a hex angle to the x/y distance. 
    public static function postToHexDir(xDist:Int, yDist:Int):Int {
        if (xDist == 0 && yDist == 0) return 64;

        var xx:Int = xDist < 0 ? -xDist : xDist;
        var yy:Int = yDist < 0 ? -yDist : yDist;
        var compare:Int;
        var angle:Int;

        if (yy >= xx) {
            compare = Std.int((xx * 256) / yy);
            angle = 64 - ANGLELIST[compare];
        } else {
            compare = Std.int((yy * 256) / xx);
            angle = ANGLELIST[compare];
        }

        if (xDist <= 0) angle = -angle + 128;
        if (yDist <= 0) angle = -angle + 256;

        return angle;
    }

    public static var rand:Int = 0; // global variable

    private static function swap16(val:Int):Int {
        return (val << 16) | ((val >> 16) & 0xFFFF);
    }

    public static function randomNumber():Void { // random function eyed conversion from Sonic 1
        if (rand == 0) rand = 0x2A6D365A; // reset seed
        var helper = rand;

        // scramble
        rand = (rand << 2) + helper;
        rand = (rand << 3) + helper;

        helper = rand;
        rand = swap16(rand) + helper;
        rand = swap16(rand);

        rand &= 0xFFFFFFFF; // limit to 32 bits
    }
}