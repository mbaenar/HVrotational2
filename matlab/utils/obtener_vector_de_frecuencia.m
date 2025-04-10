function [f,fin,ini,ptosvent,Nespec,df] = obtener_vector_de_frecuencia(segvent,dt,dfnew,fmax,flim1,flim2)
ptosvent = round(segvent/dt);
if rem(ptosvent,2) ~= 0
    ptosvent = ptosvent-1;
end
Nespec = 1*ptosvent;
NQ = Nespec/2+1;
df = 1/(Nespec*dt);

if df > dfnew
    NQ = fmax/dfnew+1;
    Nespec = (NQ-1)*2;
    df = dfnew;
end

frec = linspace(0,fmax,NQ).';
frec = round(frec*1000000)/1000000;
ini = find(frec>=flim1,1,'first');
fin = find(frec>=flim2,1,'first');
f = frec(ini:fin);
