package rituals;
import plant.Plant;
import luxe.Vector;
import tween.Delta;
import tween.easing.Sine;

class VertMoveRitual implements Ritual {
    public function new() {}

    public function run(plant:Plant) {
        var root_len = plant.root.length;

        var nodes = [plant.root];
        while(nodes.length != 0) {
            var node = nodes.shift();
            
            var move_vec = node.segment.clone();
            var len_ratio = node.length / root_len;
            len_ratio = 1 - len_ratio;

            move_vec.length = node.length * Luxe.utils.random.float(0.2, len_ratio);

            for(v in node.vertices) {
                Delta.tween(v.pos)
                    .propMultiple({x:v.pos.x + move_vec.x, y:v.pos.y + move_vec.y}, 0.5).ease(Sine.easeInOut);
            }
            node.pos.add(move_vec);

            for(child in node.children) {
                nodes.push(child);
            }
        }
        return true;
    }

    public function cleanup(plant:Plant) {
        
    }
}