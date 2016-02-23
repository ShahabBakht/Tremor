function [S, f, t, Serr] = PowerSpectrum(x,params)

% add the path of chronux
p = genpath('D:\Tools\chronux_2_11');
addpath(p);

switch params.method
    case 'spec'
        [S, f, Serr] = mtspectrumc( x, params );
        t = [];
    case 'specgc'
        [S,t,f,Serr] = mtspecgramc( x, params.movingwin, params);
end

end