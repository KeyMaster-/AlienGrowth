package plant;
import luxe.Visual;
import luxe.Vector;
import luxe.Color;
import luxe.Color.ColorHSL;
import phoenix.geometry.Geometry;
import phoenix.geometry.Vertex;
import phoenix.Batcher.PrimitiveType;
import de.polygonal.ds.LinkedQueue;
import tween.Delta;
import tween.easing.Quad;
import ChancesCollection;

class Plant extends Visual {
    public var gen_info:PlantGenInfo;

    public var root(default, null):PlantNode;
    public var leafs(default, null):Array<PlantNode>;

    var cur_tween_index:Int = 0;
    var wait_tween_index:Int = 0;

    public var tree_colors(default, null):Array<ColorHSL>;

    public var tree_depth(default, null):Int = 0;
    public var max_tree_depth(default, null):Int = 7;

    var tween_duration:Float = 0.5;


    public function new(_gen_info:PlantGenInfo) {
        super({
            name:'Plant',
            no_geometry:true
        });
        
        geometry = new Geometry({
            primitive_type:PrimitiveType.triangles,
            batcher:Luxe.renderer.batcher
        });
        gen_info = _gen_info;

        initialise();
    }

    function initialise() {
        tree_colors = [gen_info.start_color.clone(), gen_info.end_color.clone()];
        root = new PlantNode(new Vector(0, 0), gen_info.root_angle, gen_info.root_length, null);
        leafs = [root];
        tree_depth = 0;

        growGeom();
    }

    public function runIterations(n:Int) {
        for(i in 0...n) {
            if(!runIteration()) break;
        }
    }

    public function runIteration() {
        var leafs_len = leafs.length;
        for(i in 0...leafs_len) {
            var cur_leaf = leafs.shift();
            var num_children = gen_info.children.get();
            if(cur_leaf == root) {
                while(num_children == 0) {
                    num_children = gen_info.children.get();
                }
            }
            var scalars = [];
            var end_count = 0;
            for(i in 0...num_children) {
                var pos = gen_info.positions.get();
                scalars.push(pos);
                if(pos == 1) end_count++;
            }

            var end_angle = Luxe.utils.random.float(gen_info.end_angle_range.min, gen_info.end_angle_range.max) * Math.PI * 2;
            var end_angle_step = gen_info.end_angle_range.range * Math.PI * 2 / end_count;
            end_angle -= end_angle_step * (end_count - 1) / 2;

            for(i in 0...num_children) {
                var pos_scalar = scalars[i];
                var child_pos = cur_leaf.pos.clone();
                child_pos.add(Vector.Multiply(cur_leaf.segment, pos_scalar));
                
                var angle = cur_leaf.angle;
                var left_side:Bool = false;
                if(pos_scalar == 1) {
                    end_angle += (gen_info.end_angle_range.variation / 2) * Luxe.utils.random.float(-1, 1) * Math.PI * 2;
                    angle += end_angle;
                    end_angle += end_angle_step;
                }
                else {
                    //Take the normal as base angle if the branch is attached to the side
                    left_side = Luxe.utils.random.bool(gen_info.left_side_chance);
                    if(left_side) {
                        angle -= Math.PI / 2;
                    }
                    else {
                        angle += Math.PI / 2;
                    }
                    angle += Luxe.utils.random.float(gen_info.side_angle_range.min, gen_info.side_angle_range.max) * Math.PI * 2 * (left_side ? 1 : -1);
                }

                // angle += Luxe.utils.random.float(angle_range.lower, angle_range.upper) * Math.PI * 2 * (left_side ? 1 : -1);
                var length = gen_info.lengths.get() * cur_leaf.length;
                var node = new PlantNode(child_pos, angle, length, cur_leaf);
                cur_leaf.children.push(node);
                leafs.push(node);
            }
            //:todo: Sort cur_leaf.children based on angle difference (for graphics tracing)
        }
        tree_depth++;

        growGeom();

        return leafs.length != 0;
    }

    public function reset() {
        for(i in cur_tween_index...wait_tween_index+1) {
            Delta.runTrigger('$i');
        }
        geometry.vertices.splice(0, geometry.vertices.length);
        leafs = null;

        initialise();
    }

    public function growGeom() {
        tree_colors.push(gen_info.end_color.clone());

        for(leaf in leafs) {
            var normal_offset = leaf.segment.clone();
            normal_offset.angle2D = leaf.angle - Math.PI / 2;
            normal_offset.multiplyScalar(gen_info.length_width_ratio / 2);
            var normal_offset_inverted = normal_offset.clone();
            normal_offset_inverted.multiplyScalar(-1);

            var low_left = leaf.pos.clone();
            low_left.add(normal_offset);
            var low_left_vert = new Vertex(low_left, tree_colors[tree_depth]);
            var low_right = leaf.pos.clone();
            low_right.add(normal_offset_inverted);
            var low_right_vert = new Vertex(low_right, tree_colors[tree_depth]);

            var end_pos = leaf.pos.clone();
            end_pos.add(leaf.segment);
            var top_left = end_pos.clone();
            top_left.add(normal_offset);
            var top_left_vert = new Vertex(low_left.clone(), tree_colors[tree_depth + 1]);
            var top_right = end_pos.clone();
            top_right.add(normal_offset_inverted);
            var top_right_vert = new Vertex(low_right.clone(), tree_colors[tree_depth + 1]);

            geometry.vertices.push(low_left_vert);
            geometry.vertices.push(top_left_vert);
            geometry.vertices.push(low_right_vert);
            geometry.vertices.push(low_right_vert);
            geometry.vertices.push(top_left_vert);
            geometry.vertices.push(top_right_vert);

            tweenVertTo(top_left_vert, top_left);
            tweenVertTo(top_right_vert, top_right);
        }

        var h_range = gen_info.end_color.h - gen_info.start_color.h;
        var s_range = gen_info.end_color.s - gen_info.start_color.s;
        var l_range = gen_info.end_color.l - gen_info.start_color.l;

        for(i in 1...(tree_depth + 1)) {
            var cur_color = tree_colors[i];
            tweenColorTo(cur_color, 
                h_range * i / (tree_depth + 1) + gen_info.start_color.h,
                s_range * i / (tree_depth + 1) + gen_info.start_color.s,
                l_range * i / (tree_depth + 1) + gen_info.start_color.l);
        }

        createWaitTween(null).wait(tween_duration).onComplete(function() {
            cur_tween_index++;
            Delta.runTrigger('$cur_tween_index');
        });

        wait_tween_index++;
    }

    function createWaitTween(obj:Dynamic) {
        var tween = Delta.tween(obj);
        if(wait_tween_index != cur_tween_index) {
            tween = tween.waitForTrigger('$wait_tween_index');
        }
        return tween;
    }

    function tweenVertTo(vert:Vertex, end:Vector) {
        createWaitTween(vert.pos)
            .propMultiple({x:end.x, y:end.y}, tween_duration).ease(Quad.easeInOut);
            // .prop('x', end.x, tween_duration).ease(Quad.easeInOut)
            // .prop('y', end.y, tween_duration).ease(Quad.easeInOut);
    }

    function tweenColorTo(color:ColorHSL, h:Float, s:Float, l:Float) {
        createWaitTween(color)
            .prop('h', h, tween_duration).ease(Quad.easeInOut)
            .prop('s', s, tween_duration).ease(Quad.easeInOut)
            .prop('l', l, tween_duration).ease(Quad.easeInOut);
    }

}

typedef PlantGenInfo = {
    children:ChancesCollection<Int>,
    positions:ChancesCollection<Float>,
    lengths:ChancesCollection<Float>,
    end_angle_range:AngleRange,
    side_angle_range:AngleRange, //For this range, positive means towards the end of the branch, negative towards the base
    left_side_chance:Float,
    length_width_ratio:Float,
    start_color:ColorHSL,
    end_color:ColorHSL,
    root_angle:Float,
    root_length:Float
}

typedef AngleRange = {
    min:Float,
    max:Float,
    range:Float,
    variation:Float
}