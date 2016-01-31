package rituals;
import plant.Plant;

interface Ritual {
    public function run(plant:Plant):Bool;

    public function cleanup(plant:Plant):Void;
}