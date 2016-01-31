package rituals;
import plant.Plant;
import tween.Delta;
import tween.easing.Quad;

class RotationRitual implements Ritual {
    public function new() {}

    public function run(plant:Plant) {
        var nodes = [plant.root];

        while(nodes.length != 0) {
            var node = nodes.shift();
            var angle = Luxe.utils.random.float(plant.gen_info.end_angle_range.min, plant.gen_info.end_angle_range.max);
            
            var sin_a = Math.sin(angle);
            var cos_a = Math.cos(angle);
            for(v in node.vertices) {
                var rel_pos = v.pos.clone();
                rel_pos.subtract(node.pos);
                var backup_x = rel_pos.x;
                rel_pos.x = cos_a * rel_pos.x - sin_a * rel_pos.y;
                rel_pos.y = sin_a * backup_x + cos_a * rel_pos.y;
                rel_pos.add(node.pos);

                Delta.tween(v.pos)
                    .propMultiple({x:rel_pos.x, y:rel_pos.y}, 0.5);
            }

            for(child in node.children) {
                nodes.push(child);
            }
        }
        return true;
    }

    public function cleanup(plant:Plant) {
        
    }
}