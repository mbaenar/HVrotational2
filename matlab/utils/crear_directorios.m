function crear_directorios(ruta,estac)

if ~exist(ruta,'dir')
    mkdir(ruta)
end

if ~exist([ruta,estac],'dir')
    mkdir([ruta,estac])
end
end