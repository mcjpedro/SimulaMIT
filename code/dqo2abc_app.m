function [va, vb, vc] = dqo2abc_app(q, d, o, w)

    def = (2*pi)/3;
    abc = ([cos(w) sin(w) 1; cos(w - def) sin(w - def) 1; cos(w + def) sin(w + def) 1])*([q; d; o]);
    va = abc(1);
    vb = abc(2);
    vc = abc(3);

end
