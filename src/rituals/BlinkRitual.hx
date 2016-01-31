package rituals;
import plant.Plant;
import tween.Delta;
import tween.easing.Sine;
import phoenix.Color.ColorHSL;

class BlinkRitual implements Ritual {
    var color_lows:Array<Float>;
    var color_highs:Array<Float>;
    var plant:Plant;

    public function new() {
        color_lows = [];
        color_highs = [];
    }

    public function run(_plant:Plant) {
        plant = _plant;
        for(i in 0...plant.tree_colors.length) {
            var low = Luxe.utils.random.float(0.1, 0.3);
            var high = Luxe.utils.random.float(0.6, 0.7);
            color_lows.push(low);
            color_highs.push(high);
        }
        applyTweens();
        return true;
    }

    function applyTweens() {
        for(i in 0...plant.tree_colors.length) {
            
            Delta.tween(plant.tree_colors[i])
                .prop('l', color_lows[i], 3).ease(Sine.easeInOut).wait(0.1)
                .prop('l', color_highs[i], 3).ease(Sine.easeInOut);
        }
        Delta.tween(this).wait(6.1).onComplete(applyTweens);
    }

    public function cleanup(plant:Plant) {
        for(color in plant.tree_colors) {
            Delta.removeTweensOf(color);
        }
        Delta.removeTweensOf(this);
    }
}