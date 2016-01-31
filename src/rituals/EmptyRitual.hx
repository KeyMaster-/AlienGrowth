package rituals;
import plant.Plant;

class EmptyRitual implements Ritual {
    public function new() {}

    public function run(plant:Plant) {
        trace('Ran empty ritual');
        return true;
    }
}