package rituals;
import plant.Plant;

class EmptyRitual implements Ritual {
    public function new() {}

    public function run(plant:Plant) {
        var nodes = [plant.root];
        while(nodes.length != 0) {
            
        }
        return true;
    }

    public function cleanup(plant:Plant) {
        
    }
}