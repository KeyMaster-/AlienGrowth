package rituals;
import plant.Plant;
import phoenix.geometry.Geometry;
import phoenix.Batcher.PrimitiveType;
import phoenix.geometry.Vertex;
import phoenix.Vector;
import tween.Delta;
import tween.easing.Quad;

class SquaresRitual implements Ritual {
    var square_geoms:Array<Geometry>;

    public function new() {
        square_geoms = [];
    }

    public function run(plant:Plant) {
        var nodes = [plant.root];
        while(nodes.length != 0) {
            var node = nodes.shift();
            if(plant.gen_info.children.get() >= 2) {

                var square_color = plant.gen_info.start_color.clone();
                square_color.h = (square_color.h + Luxe.utils.random.float(40, 100)) % 360;
                square_color.s += Luxe.utils.random.float(0.1, 0.3);

                var center_color = plant.gen_info.end_color.clone();
                center_color.h = (center_color.h + Luxe.utils.random.float(30, 70)) % 360;

                var geom = new Geometry({
                    primitive_type:PrimitiveType.triangles,
                    batcher:Luxe.renderer.batcher
                });

                var pos = node.pos.clone();
                pos.add(node.segment);
                pos.add(Vector.Multiply(node.segment, Luxe.utils.random.float(0.0, 0.2)));
                pos.add(plant.transform.pos);

                var offset = node.segment.clone();
                offset.length = node.length * plant.gen_info.length_width_ratio * Luxe.utils.random.float(1.1, 1.4);
                offset.angle2D += Luxe.utils.random.float(0.0, 0.25) * Math.PI * 2;

                var center = new Vertex(pos.clone(), center_color);
                var first = new Vertex(pos.clone(), square_color);
                var second = new Vertex(pos.clone(), square_color);
                var third = new Vertex(pos.clone(), square_color);
                var fourth = new Vertex(pos.clone(), square_color);

                Delta.tween(first.pos)
                    .propMultiple({x:pos.x + offset.x, y:pos.y + offset.y}, 0.5).ease(Quad.easeInOut);
                offset.angle2D += Math.PI / 2;
                Delta.tween(second.pos)
                    .propMultiple({x:pos.x + offset.x, y:pos.y + offset.y}, 0.5).ease(Quad.easeInOut);
                offset.angle2D += Math.PI / 2;
                Delta.tween(third.pos)
                    .propMultiple({x:pos.x + offset.x, y:pos.y + offset.y}, 0.5).ease(Quad.easeInOut);
                offset.angle2D += Math.PI / 2;
                Delta.tween(fourth.pos)
                    .propMultiple({x:pos.x + offset.x, y:pos.y + offset.y}, 0.5).ease(Quad.easeInOut);

                geom.add(center);
                geom.add(first);
                geom.add(second);

                geom.add(center);
                geom.add(second);
                geom.add(third);
                
                geom.add(center);
                geom.add(third);
                geom.add(fourth);
                
                geom.add(center);
                geom.add(fourth);
                geom.add(first);
                
                square_geoms.push(geom);
            }
            for(child in node.children) {
                nodes.push(child);
            }
        }
        return true;
    }

    public function cleanup(plant:Plant) {
        for(geom in square_geoms) {
            geom.drop();
        }
    }
}