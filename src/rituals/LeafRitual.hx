package rituals;
import plant.Plant;
import phoenix.geometry.Geometry;
import phoenix.geometry.Vertex;
import phoenix.Vector;
import phoenix.Batcher.PrimitiveType;
import phoenix.Color.ColorHSL;
import tween.Delta;
import tween.easing.Quad;

class LeafRitual implements Ritual {
    var leaf_geoms:Array<Geometry>;
    var leaf_start_col:ColorHSL;
    var leaf_end_col:ColorHSL;
    var leaf_middle_col:ColorHSL;

    public function new () {
        leaf_geoms = [];
    }

    public function run(plant:Plant):Bool {
        var nodes = [plant.root];
        leaf_start_col = plant.gen_info.start_color.clone();
        leaf_start_col.h = (leaf_start_col.h + Luxe.utils.random.float(30, 60)) % 360;
        leaf_end_col = plant.gen_info.end_color.clone();
        leaf_end_col.h = (leaf_end_col.h + Luxe.utils.random.float(60, 80)) % 360;
        leaf_middle_col = leaf_start_col.clone();
        leaf_middle_col.h += (leaf_end_col.h - leaf_start_col.h) / 2;

        while(nodes.length != 0) {
            var node = nodes.shift();
            var num_leafs = plant.gen_info.children.get();
            for(i in 0...num_leafs) {
                var pos = plant.gen_info.positions.get();
                if(pos == 1) continue;
                var leaf_pos = node.segment.clone();
                leaf_pos.multiplyScalar(pos);
                leaf_pos.add(node.pos);
                leaf_pos.add(plant.transform.pos);
                var leaf_side_offset = node.segment.clone();
                leaf_side_offset.length = node.length * plant.gen_info.lengths.get() / 6;
                // leaf_side_offset.length = 20;
                var leaf_length_offset = node.segment.clone();
                leaf_length_offset.angle2D = node.angle + Math.PI / 2 + Luxe.utils.random.float(-plant.gen_info.end_angle_range.variation / 2, plant.gen_info.end_angle_range.variation / 2) * Math.PI;
                if(Luxe.utils.random.bool(plant.gen_info.left_side_chance)) {
                    leaf_length_offset.angle2D -= Math.PI;
                }
                leaf_length_offset.length = node.length * plant.gen_info.lengths.get() / 3;
                // leaf_length_offset.length = 20;
                var geom = new Geometry({
                    primitive_type:PrimitiveType.triangle_strip,
                    batcher:Luxe.renderer.batcher
                });

                var end_col = leaf_end_col.clone();
                end_col.h = (end_col.h + Luxe.utils.random.float(-30, 30)) % 360;
                end_col.l += Luxe.utils.random.float(-0.2, 0.2);
                var root = new Vertex(leaf_pos.clone(), leaf_start_col);
                var middle_left = new Vertex(leaf_pos.clone(), leaf_middle_col);
                var middle_right = new Vertex(leaf_pos.clone(), leaf_middle_col);
                var end = new Vertex(leaf_pos.clone(), end_col);
                geom.add(root);
                geom.add(middle_left);
                geom.add(middle_right);
                geom.add(end);

                leaf_pos.add(leaf_length_offset);
                leaf_pos.add(leaf_side_offset);

                tweenVertex(middle_left, leaf_pos);

                leaf_pos.subtract(leaf_side_offset);
                leaf_side_offset.multiplyScalar(Luxe.utils.random.float(0.8, 1.1));
                leaf_pos.subtract(leaf_side_offset);

                tweenVertex(middle_right, leaf_pos);

                leaf_pos.add(leaf_side_offset);
                leaf_length_offset.multiplyScalar(Luxe.utils.random.float(1.1, 1.3));
                leaf_pos.add(leaf_length_offset);
                
                tweenVertex(end, leaf_pos);

                leaf_geoms.push(geom);
            }
            for(child in node.children) {
                nodes.push(child);
            }
        }
        return true;
    }

    function tweenVertex(vert:Vertex, target:Vector) {
        Delta.tween(vert.pos)
            .propMultiple({x:target.x, y:target.y}, 0.5).ease(Quad.easeInOut);
    }

    public function cleanup(plant:Plant) {
        for(geom in leaf_geoms) {
            geom.drop();
        }
        leaf_geoms = [];
    }
}