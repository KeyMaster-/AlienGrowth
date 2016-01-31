
import luxe.Input;
import luxe.Color.ColorHSL;
import plant.Plant;
import tween.Delta;
import ChancesCollection;
import phoenix.geometry.Geometry;
import phoenix.Batcher.PrimitiveType;
import phoenix.geometry.Vertex;
import phoenix.Vector;

class Main extends luxe.Game {
    var plant:Plant;
    var rituals:RitualManager;
    override function config(config:luxe.AppConfig) {

        return config;

    } //config

    override function ready() {

        plant = new Plant(makeRandomGenInfo());
        plant.transform.pos.set_xy(Luxe.screen.mid.x, Luxe.screen.height);
        plant.runIterations(5);

        var bg_geom = new Geometry({
            primitive_type:PrimitiveType.triangle_strip,
            batcher:Luxe.renderer.batcher,
            depth:-1
        });

        var lowerColor = new ColorHSL(0, 0, 0.01, 1);
        var upperColor = new ColorHSL(0, 0, 0.23, 1);

        bg_geom.add(new Vertex(new Vector(0, Luxe.screen.h), lowerColor));
        bg_geom.add(new Vertex(new Vector(0, 0), upperColor));
        bg_geom.add(new Vertex(new Vector(Luxe.screen.w, Luxe.screen.h), lowerColor));
        bg_geom.add(new Vertex(new Vector(Luxe.screen.w, 0), upperColor));

        rituals = new RitualManager(plant);

        Luxe.draw.text({
            text:'R - New plant',
            point_size:32 * Luxe.screen.device_pixel_ratio,
            pos:new Vector(20, 10)
        });
    } //ready

    override function onkeyup( e:KeyEvent ) {
        if(e.keycode == Key.escape) {
            Luxe.shutdown();
        }

    } //onkeyup

    override function onkeydown( e:KeyEvent) {
        switch(e.keycode) {
            case Key.key_r:
                plant.gen_info = makeRandomGenInfo();
                plant.reset();
                plant.runIterations(5);
                rituals.reset();
        }
    }

    var randGenStats = {
        children:{
            numAdds:new ChancesCollection([1, 2], [0.8, 0.2]),
            startNum:new ChancesCollection([0, 1, 2], [0.1, 0.7, 0.2]),
            minEntries:2,
            maxEntries:4,
            binomMin:0.4,
            binomMax:0.6
        },
        positions:{
            minEntries:2,
            maxEntries:4,
            startMin:0.5,
            startMax:0.7,
            stepMin:0.1,
            stepMax:0.5,
            binomMin:0.4,
            binomMax:0.6,
            endChance:0.7
        },
        lengths:{
            minEntries:2,
            maxEntries:4,
            startMin:0.6,
            startMax:0.7,
            stepMin:0.05,
            stepMax:0.1,

            hardMax:0.85,

            binomMin:0.5,
            binomMax:0.6
        },
        angles:{
            end:{
                minLower:-70/360,
                minUpper:-20/360,
                maxLower:20/360,
                maxUpper:70/360,
                rangeLower:20/360,
                rangeUpper:60/360,
                variationLower:5/360,
                variationUpper:15/360
            },
            side:{
                minLower:20/360,
                minUpper:40/360,
                maxLower:60/360,
                maxUpper:85/360
            }
        },
        left_side_chance_lower:0.3,
        left_side_chance_upper:0.7,

        length_width_ratio_lower:0.05,
        length_width_ratio_upper:0.15,

        root_len_lower:120,
        root_len_upper:320
    }

    function makeRandomGenInfo():PlantGenInfo {
        var numChildrenEntries = Luxe.utils.random.int(randGenStats.children.minEntries, randGenStats.children.maxEntries + 1);
        var childrenStart = randGenStats.children.startNum.get();
        var childrenEntries = [childrenStart];
        for(i in 0...numChildrenEntries - 1) {
            childrenStart += randGenStats.children.numAdds.get();
            childrenEntries.push(childrenStart);
        }

        var binomProb:Float = Luxe.utils.random.float(randGenStats.children.binomMin, randGenStats.children.binomMax);
        var childrenChances = [];
        for(i in 0...numChildrenEntries) {
            childrenChances.push(binom(numChildrenEntries - 1, binomProb, i));
        }

        var numPosEntries = Luxe.utils.random.int(randGenStats.positions.minEntries, randGenStats.positions.maxEntries + 1);
        var posStart = Luxe.utils.random.float(randGenStats.positions.startMin, randGenStats.positions.startMax);
        var posEntries = [posStart];
        for(i in 0...numPosEntries) {
            posStart += Luxe.utils.random.float(randGenStats.positions.stepMin, randGenStats.positions.stepMax);
            if(posStart > 1) posStart = 1;
            posEntries.push(posStart);
        }
        if(Luxe.utils.random.bool(randGenStats.positions.endChance)) {
            posEntries[Math.floor(numPosEntries / 2)] = 1;
        }

        binomProb = Luxe.utils.random.float(randGenStats.positions.binomMin, randGenStats.positions.binomMax);
        var posChances = [];
        for(i in 0...numPosEntries) {
            posChances.push(binom(numPosEntries - 1, binomProb, i));
        }

        var numLenEntries = Luxe.utils.random.int(randGenStats.lengths.minEntries, randGenStats.lengths.maxEntries + 1);
        var lenStart = Luxe.utils.random.float(randGenStats.lengths.startMin, randGenStats.lengths.startMax);
        var lenEntries = [lenStart];
        for(i in 0...numLenEntries) {
            lenStart += Luxe.utils.random.float(randGenStats.lengths.stepMin, randGenStats.lengths.stepMax);
            if(lenStart > randGenStats.lengths.hardMax) lenStart = randGenStats.lengths.hardMax;
            lenEntries.push(lenStart);
        }

        binomProb = Luxe.utils.random.float(randGenStats.lengths.binomMin, randGenStats.lengths.binomMax);
        var lenChances = [];
        for(i in 0...numLenEntries) {
            lenChances.push(binom(numLenEntries - 1, binomProb, i));
        }

        var start_color = new ColorHSL();
        start_color.h = Luxe.utils.random.float(360);
        start_color.s = Luxe.utils.random.float(0.3, 1);
        start_color.l = Luxe.utils.random.float(0.2, 0.8);

        var end_color = new ColorHSL();
        end_color.h = (Luxe.utils.random.float(40, 320) + start_color.h) % 360;
        end_color.s = Luxe.utils.random.float(0.3, 1);
        end_color.l = Luxe.utils.random.float(0.2, 0.8);

        // var avg_l = (start_color.l + end_color.l) / 2;
        // avg_l = (avg_l + 0.5) % 1;
        // Luxe.renderer.clear_color.fromColorHSL(new ColorHSL(0, 0, avg_l, 1));
        
        var end_angle_min = Luxe.utils.random.float(randGenStats.angles.end.minLower, randGenStats.angles.end.minUpper);
        var end_angle_max = Luxe.utils.random.float(randGenStats.angles.end.maxLower, randGenStats.angles.end.maxUpper);
        var end_angle_range = Luxe.utils.random.float(randGenStats.angles.end.rangeLower, randGenStats.angles.end.rangeUpper);
        var end_angle_variation = Luxe.utils.random.float(randGenStats.angles.end.variationLower, randGenStats.angles.end.variationUpper);

        var side_angle_min = Luxe.utils.random.float(randGenStats.angles.side.minLower, randGenStats.angles.side.minUpper);
        var side_angle_max = Luxe.utils.random.float(randGenStats.angles.side.maxLower, randGenStats.angles.side.maxUpper);

        var left_side_chance = Luxe.utils.random.float(randGenStats.left_side_chance_lower, randGenStats.left_side_chance_upper);
        var length_width_ratio = Luxe.utils.random.float(randGenStats.length_width_ratio_lower, randGenStats.length_width_ratio_upper);

        var root_angle = (-Math.PI / 2) + Luxe.utils.random.float(-(1/24), 1/24) * Math.PI * 2;
        var root_length = Luxe.utils.random.float(randGenStats.root_len_lower, randGenStats.root_len_upper);

        return {
            children:new ChancesCollection<Int>(childrenEntries, childrenChances),
            positions:new ChancesCollection<Float>(posEntries, posChances),
            lengths:new ChancesCollection<Float>(lenEntries, lenChances),
            end_angle_range:{
                min:end_angle_min,
                max:end_angle_max,
                range:end_angle_range,
                variation:end_angle_variation
            },
            side_angle_range:{
                min:side_angle_min,
                max:side_angle_max,
                //These aren't used for side angles matter for side
                range:0,
                variation:0
            },
            left_side_chance:left_side_chance,
            length_width_ratio: length_width_ratio,
            start_color:start_color,
            end_color:end_color,
            root_angle:root_angle,
            root_length:root_length
        }
    }

    inline function binom(n:Int, p:Float, k:Int) {
        return binomCoefficient(n, k) * Math.pow(p, k) * Math.pow(1 - p, n - k);

    }

    inline function binomCoefficient(n:Int, k:Int) {
        return (factorial(n))/(factorial(k) * factorial(n - k));
    }

    inline function factorial(n:Int) {
        var result = 1;
        for(i in 2...n+1) {
            result *= i;
        }
        return result;
    }

    override function update(dt:Float) {
        Delta.step(dt);
    } //update


} //Main

//Some hand made constants
// {
//     children:new ChancesCollection<Int>([0, 1, 2, 3], [0.01, 0.15, 0.55, 0.29]),
//     positions:new ChancesCollection<Float>([0.3, 0.7, 1], [0.1, 0.3, 0.6]),
//     lengths:new ChancesCollection<Float>([0.4, 0.7, 0.9], [0.1, 0.7, 0.2]),
//     end_angle_range:{
//         min:-30/360,
//         max:30/360,
//         range:50/360,
//         variation:5/360
//     },
//     side_angle_range:{
//         min:40/360,
//         max:70/360,
//         range:20/360,
//         variation:10/360
//     },
//     left_side_chance:0.5,
//     length_width_ratio: 0.1,
//     start_color:new ColorHSL().rgb(0x07E100).toColorHSL(),
//     end_color:new ColorHSL().rgb(0x3BFEFF).toColorHSL(),
//     root_angle:(-Math.PI / 2) + Luxe.utils.random.float(-(1/24), 1/24) * Math.PI * 2,
//     root_length:Luxe.utils.random.float(100, 200)
// }