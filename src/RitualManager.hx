package ;
import luxe.Entity;
import luxe.Input;
import phoenix.geometry.Geometry;
import phoenix.geometry.Vertex;
import phoenix.Batcher.PrimitiveType;
import phoenix.Vector;
import phoenix.Color;
import tween.Delta;
import tween.easing.Sine;
import plant.Plant;
import rituals.*;

class RitualManager extends Entity {
    var plant:Plant;

    var sigils:Array<Geometry>;
    var sigil_positions:Array<Vector>;

    var ritual_tokens:Array<Geometry>;

    var sigil_size:Float;
    var sigil_spacing:Float = 20;
    var sigil_color:Color;

    var ritual_sigil_count:Int = 0;

    var ritual_count:Int = 5;

    var target_left:Vector;
    var target_right:Vector;
    var center_pos:Vector;

    var left_sigil:Int = -1;
    var right_sigil:Int = -1;

    public function new(_plant:Plant) {
        super({
            name:'RitualManager'
        });
        plant = _plant;
        sigils = [];
        sigil_positions = [];
        sigil_color = new Color(0.9, 0.9, 0.9, 1);
        sigil_size = Luxe.screen.h / 15;
        target_left = new Vector(Luxe.screen.mid.x / 2 - sigil_size / 2, Luxe.screen.mid.y - sigil_size / 2);
        target_right = new Vector(Luxe.screen.mid.x + Luxe.screen.mid.x / 2 - sigil_size / 2, Luxe.screen.mid.y - sigil_size / 2);
        center_pos = new Vector(Luxe.screen.mid.x - sigil_size / 2, Luxe.screen.mid.y - sigil_size / 2);
        ritual_tokens = [];
    }

    override public function init() {
        var sigil_x_pos:Float = sigil_size / 2;
        var sigil_y_pos:Float = Luxe.screen.h - sigil_size * 1.5;

        for(i in 0...4) {
            sigils[i] = new Geometry({
                primitive_type:PrimitiveType.triangle_strip,
                batcher:Luxe.renderer.batcher
            });
            sigils[i].transform.pos.set_xy(sigil_x_pos, sigil_y_pos);
            sigil_positions.push(new Vector(sigil_x_pos, sigil_y_pos));
            sigil_x_pos += sigil_size + sigil_spacing;
        }


        sigils[0].add(new Vertex(new Vector(sigil_size * 1 / 3, 0), sigil_color));
        sigils[0].add(new Vertex(new Vector(sigil_size * 1 / 3, sigil_size), sigil_color));
        sigils[0].add(new Vertex(new Vector(sigil_size * 2 / 3, 0), sigil_color));
        sigils[0].add(new Vertex(new Vector(sigil_size * 2 / 3, sigil_size), sigil_color));

        sigils[1].add(new Vertex(new Vector(0, sigil_size * 1 / 3), sigil_color));
        sigils[1].add(new Vertex(new Vector(sigil_size, sigil_size * 1 / 3), sigil_color));
        sigils[1].add(new Vertex(new Vector(0, sigil_size * 2 / 3), sigil_color));
        sigils[1].add(new Vertex(new Vector(sigil_size, sigil_size * 2 / 3), sigil_color));

        sigils[2].add(new Vertex(new Vector(0, sigil_size * 2 / 3), sigil_color));
        sigils[2].add(new Vertex(new Vector(sigil_size * 2 / 3, 0), sigil_color));
        sigils[2].add(new Vertex(new Vector(sigil_size * 1 / 3, sigil_size), sigil_color));
        sigils[2].add(new Vertex(new Vector(sigil_size, sigil_size * 1 / 3), sigil_color));

        sigils[3].add(new Vertex(new Vector(0, sigil_size * 1 / 3), sigil_color));
        sigils[3].add(new Vertex(new Vector(sigil_size * 2 / 3, sigil_size), sigil_color));
        sigils[3].add(new Vertex(new Vector(sigil_size * 1 / 3, 0), sigil_color));
        sigils[3].add(new Vertex(new Vector(sigil_size, sigil_size * 2 / 3), sigil_color));

        var token_y_pos = Luxe.screen.h - sigil_size;
        for(i in 0...ritual_count) {
            ritual_tokens.push(new Geometry({
                primitive_type:PrimitiveType.triangle_strip,
                batcher:Luxe.renderer.batcher
            }));
            var token_color = sigil_color.clone();
            ritual_tokens[i].color = token_color;
            ritual_tokens[i].add(new Vertex(new Vector(sigil_size * 0.2, 0), token_color));
            ritual_tokens[i].add(new Vertex(new Vector(sigil_size * 1.2, 0), token_color));
            ritual_tokens[i].add(new Vertex(new Vector(0, sigil_size / 2), token_color));
            ritual_tokens[i].add(new Vertex(new Vector(sigil_size, sigil_size / 2), token_color));
            ritual_tokens[i].transform.pos.set_xy(Luxe.screen.w - sigil_size * 1.5, token_y_pos);
            token_y_pos -= sigil_size / 2 + sigil_size / 4;
        }

        // Luxe.input.bind_key('sigil1', Key.key_a);
        // Luxe.input.bind_key('sigil1', Key.key_1);
        // Luxe.input.bind_key('sigil2', Key.key_s);
        // Luxe.input.bind_key('sigil2', Key.key_2);
        // Luxe.input.bind_key('sigil3', Key.key_d);
        // Luxe.input.bind_key('sigil3', Key.key_3);
        // Luxe.input.bind_key('sigil4', Key.key_f);
        // Luxe.input.bind_key('sigil4', Key.key_4);
    }

    // override public function oninputdown(name:String, event:InputEvent) {
    //     switch(name) {
    //         case 'sigil1':
    //             trace('move sigil 1');
    //         case 'sigil2':
    //             trace('move sigil 2');
    //         case 'sigil3':
    //             trace('move sigil 3');
    //         case 'sigil4':
    //             trace('move sigil 4');
    //     }
    // }

    override public function onkeydown(event:KeyEvent) {
        switch(event.keycode) {
            case Key.key_1 | Key.key_a:
                onSigilSelect(0);
            case Key.key_2 | Key.key_s:
                onSigilSelect(1);
            case Key.key_3 | Key.key_d:
                onSigilSelect(2);
            case Key.key_4 | Key.key_f:
                onSigilSelect(3);
               
        }
    }

    function onSigilSelect(n:Int) {
        if(ritual_sigil_count == 2) return;
        if(ritual_sigil_count == 0) {
            if(left_sigil != -1) return;
            left_sigil = n;
        }
        moveSigil(sigils[n]);

        if(ritual_sigil_count == 1) {
            right_sigil = n;
            Delta.tween(sigils[left_sigil].transform.pos)
                .waitForTrigger('sigil_count_1')
                .propMultiple({x:center_pos.x, y:center_pos.y}, 0.5).ease(Sine.easeInOut)
                .wait(0.3)
                .propMultiple({x:sigil_positions[left_sigil].x, y:sigil_positions[left_sigil].y}, 0.5).ease(Sine.easeInOut);
                // .wait(0.1)
                // .tween(sigils[left_sigil].transform.scale)
                // .propMultiple({x:1.3, y:1.3}, 0.5).ease(Sine.easeInOut)
                // .propMultiple({x:1, y:1}, 0.5).ease(Sine.easeInOut);
            Delta.tween(sigils[n].transform.pos)
                .waitForTrigger('sigil_count_1')
                .propMultiple({x:center_pos.x, y:center_pos.y}, 0.5).ease(Sine.easeInOut)
                .wait(0.3)
                .trigger('runRitualEffect')
                .propMultiple({x:sigil_positions[n].x, y:sigil_positions[n].y}, 0.5).ease(Sine.easeInOut)
                .onComplete(resetSigilSelect);
                // .wait(0.1)
                // .tween(sigils[n].transform.scale)
                // .propMultiple({x:1.3, y:1.3}, 0.5).ease(Sine.easeInOut)
                // .propMultiple({x:1, y:1}, 0.5).ease(Sine.easeInOut);
            Delta.tween(null).waitForTrigger('runRitualEffect').onComplete(runRitualEffect);
        }

        ritual_sigil_count++;
    }

    function runRitualEffect() {
        var ritual_signature = '$left_sigil$right_sigil';
        var ritual:Ritual = switch(ritual_signature) {
            case '01':
                new EmptyRitual();
            case '02':
                new EmptyRitual();
            case '03':
                new GrowRitual();
            case '10':
                new EmptyRitual();
            case '12':
                new EmptyRitual();
            case '13':
                new EmptyRitual();
            case '20':
                new EmptyRitual();
            case '21':
                new EmptyRitual();
            case '23':
                new EmptyRitual();
            case _:
                new EmptyRitual();
        }
        if(ritual.run(plant)) {
            ritual_count--;
            Delta.tween(ritual_tokens[ritual_count].color)
                .prop('a', 0, 0.5).ease(Sine.easeInOut);
        }
        if(ritual_count == 0) {
            trace('finish plant');
        }
    }

    function resetSigilSelect() {
        ritual_sigil_count = 0;
        left_sigil = -1;
        right_sigil = -1;
    }

    public function reset() {
        ritual_count = 5;
        for(i in 0...ritual_count) {
            Delta.tween(ritual_tokens[i].color)
                .prop('a', 1, 0.3);
        }

        for(i in 0...sigils.length) {
            Delta.tween(sigils[i].transform.pos)
                .propMultiple({x:sigil_positions[i].x, y:sigil_positions[i].y}, 0.3);
        }

        resetSigilSelect();
    }

    function moveSigil(geom:Geometry) {
        var target:Vector = target_left;
        if(ritual_sigil_count == 1) {
            target = target_right;
        }
        Delta.tween(geom.transform.pos)
            .propMultiple({x:target.x, y:target.y}, 0.5).ease(Sine.easeInOut)
            .trigger('sigil_count_$ritual_sigil_count', true);
    }
}