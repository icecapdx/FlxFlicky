package meta.data.font;
    
import flixel.graphics.frames.FlxBitmapFont;
        
class Fonts {    
    static var presents:FlxBitmapFont;
        
    public static function getPresents(): FlxBitmapFont {    
        if (presents == null) {    
            var silverXMLData = Xml.parse(Util.getText("fonts/Presents Font.fnt"));    
            presents = FlxBitmapFont.fromAngelCode(Util.getImage("fonts/Presents Font.png", true), silverXMLData);    
        }    
        return presents;
    }    
}