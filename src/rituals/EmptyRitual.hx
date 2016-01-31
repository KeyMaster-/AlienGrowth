package rituals;
import plant.Plant;

class EmptyRitual implements Ritual {
    public function new() {}

    public function run(plant:Plant) {
        trace('Ran empty ritual');
        return false;
    }

    public function cleanup(plant:Plant) {
        
    }
}