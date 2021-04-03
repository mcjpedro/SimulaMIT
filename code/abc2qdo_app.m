function [q, d, o] = abc2qdo_app(va, vb, vc, w)

def = (2*pi)/3;
dqo = (2/3)*([cos(w) cos(w - def) cos(w + def); sin(w) sin(w - def) sin(w + def); 0.5 0.5 0.5])*([va; vb; vc]);
q = dqo(1);
d = dqo(2);
o = dqo(3);

end




