package rituals;
import plant.Plant;

class GrowRitual implements Ritual {
    public function new() {}

    public function run(plant:Plant) {
        if(plant.tree_depth != plant.max_tree_depth) {
            plant.runIteration();
            return true;
        } //:todo: communicate this better
        return false;
    }

    public function cleanup(plant:Plant) {
        
    }
}