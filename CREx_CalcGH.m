function [G,H]=CREx_CalcGH(varargin)

if nargin==1
   Montage= varargin{1};
    m=7;
elseif nargin>1
    Montage=varargin{1};
    m=varargin{2};
end

 ThetaRad = (2 * pi * [Montage.theta]) / 360;     % convert Theta and Phi to radians ...
    PhiRad = (2 * pi * [Montage.phi]) / 360;         % ... and Cartesian coordinates ...
    [X,Y,Z] = sph2cart(ThetaRad,PhiRad,1.0); % ... for optimal resolution
    nElec = length(Montage.lab);                   % determine size of EEG montage
    EF(nElec,nElec) = 0;                     % initialize interelectrode matrix ...
    
    for i = 1:nElec;
        for j = 1:nElec;        % ... and compute all cosine distances
            EF(i,j) = 1 - ( ( (X(i) - X(j))^2 + ...
                (Y(i) - Y(j))^2 + (Z(i) - Z(j))^2 ) / 2 );
        end;
    end;
    
  
    if ~ismember(m,[2:10])                    % verify m constant
        disp(sprintf('Error: Invalid m = %d [use an integer between 2 and 10]',[m]));
        G = NaN;
        H = NaN;
        return
    end
    disp(sprintf('Spline flexibility:  m = %d',[m]));
    N = 50;                                  % set N iterations
    G(nElec,nElec) = 0; H(nElec,nElec) = 0;  % claim memory for G- and H-matrices
    fprintf('%d iterations for %d sites [',N,nElec); % intialize progress bar
    for i = 1:nElec;
        for j = 1:nElec;
            P = zeros(N);                          % compute Legendre polynomial
            for n = 1:N;
                p = legendre(n,EF(i,j));
                P(n) = p(1);
            end;
            g = 0.0; h = 0.0;                      % compute h- and g-functions
            if j == 1;
                fprintf('*');
            end;          % show progress
            for n = 1:N;
                g = g + ( (( 2.0*n+1.0) * P(n)) / ((n*n+n)^m    ) );
                h = h + ( ((-2.0*n-1.0) * P(n)) / ((n*n+n)^(m-1)) );
            end;
            G(i,j) =  g / 4.0 / pi;                % finalize cell of G-matrix
            H(i,j) = -h / 4.0 / pi;                % finalize cell of H-matrix
        end;
    end;
    disp(']');


end