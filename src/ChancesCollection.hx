class ChancesCollection<T> {
    public var values:Array<T>;
    public var chances:Array<Float>;
    public function new(_values:Array<T>, _chances:Array<Float>) {
        values = _values;
        chances = _chances;
    }

    public function get():T {
        var val = Luxe.utils.random.get();
        var ret = values[0];
        var accum:Float = 0;
        for(i in 0...chances.length) {
            accum += chances[i];
            if(val < accum) {
                ret = values[i];
                break;
            }
        }
        return ret;
    }
}