package plant;
import luxe.Vector;
import phoenix.geometry.Vertex;

class PlantNode {
    public var pos:Vector;
    public var angle:Float;
    public var length:Float;
    public var segment:Vector; //Vector of correct length and angle, starting at 0,0 (i.e. relative to pos)

    public var parent:PlantNode;
    public var children:Array<PlantNode>;

    public var vertices:Array<Vertex>; //

    public function new(_pos:Vector, _angle:Float, _length:Float, _parent:PlantNode) {
        pos = _pos;
        angle = _angle;
        length = _length;
        segment = new Vector(Math.cos(angle) * length, Math.sin(angle) * length);
        parent = _parent;
        children = [];
        vertices = [];
    }
}