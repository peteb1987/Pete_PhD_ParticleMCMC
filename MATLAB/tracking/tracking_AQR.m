function [ A, Q, R ] = tracking_AQR( model )
%TRACKING_AQR

T = model.T;
a = model.decay;

A = [exp(-a*T) 0 0 (1-exp(-a*T))/a 0 0;
     0 exp(-a*T) 0 0 (1-exp(-a*T))/a 0; 
     0 0 exp(-a*T) 0 0 (1-exp(-a*T))/a; 
     0 0 0 1 0 0;
     0 0 0 0 1 0;
     0 0 0 0 0 1 ];

Q = model.sigx * ...
    [T^3/3  0      0      T^2/2  0      0    ;
     0      T^3/3  0      0      T^2/2  0    ;
     0      0      T^3/3  0      0      T^2/2;
     T^2/2  0      0      T      0      0    ;
     0      T^2/2  0      0      T      0    ;
     0      0      T^2/2  0      0      T    ];
 
R = diag([model.sigtheta model.sigphi model.sigr]);

end

