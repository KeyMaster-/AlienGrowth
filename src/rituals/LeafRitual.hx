package rituals;
import plant.Plant;

class LeafRitual implements Ritual {
    public function new () {}

    public function run(plant:Plant):Bool {
        var nodes = [plant.root];
        while(nodes.length != 0) {
            var node = nodes.shift();
        }
        return true;
    }
}