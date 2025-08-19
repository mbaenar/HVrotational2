function funREG(fechahms,estac,sensor,unidad,mps,dt,w1,w2,NS,VE,EW,nombarch)

REG.nombarch = [fechahms,'.mat'];
REG.estac = estac;
REG.sensor = sensor;
REG.unidad = unidad;
REG.mps = mps;
REG.dt = dt;
REG.w1 = w1;
REG.w2 = w2;
REG.NS = NS;
REG.VE = VE;
REG.EW = EW;
REG.fechahms = fechahms;

save(nombarch,'REG','-v7.3');
