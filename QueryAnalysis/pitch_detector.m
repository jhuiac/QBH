function [ F0 ] = pitch_detector( x, Fs )
% on lui donne juste un segment o� il y a une note

%Script for multi-pitch detection (reference: Klapuri)
% but with pitch detection with spectral product 
% 
% Author: G. Richard, Janv. 2005 - MAJ:2016
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Lecture du signal
tmps= [0:length(x)-1]/Fs;
%figure, plot(tmps, x);

offset=floor(0.1*Fs); % arbitraire , pour �carter l'attaque..
%offset = 0; % ici on suppose qu'on donne d�s le d�but de la note sans l'attaque
timeAnalysis = (length(x) - offset)*0.9; % arbitraire mais faire en sorte que malgr� l'offset, on n'exc�de pas les dimensions..

spect_smooth=2; % options: 0: no spectral smoothness
               %          1: spectral smoothness principle with triangle 
               %           2 spectral smoothness principle with mean of three harmonics 

%N=floor(0.7*Fs);      % Window size of analysed signal (only one window of signal is analysed)
N = floor(timeAnalysis);
%Fmin=100;             % Minimal F0 frequency that can be detected
%Fmax=900;             % Maximal F0 frequency that can be detected
H=4;                  % H = nombre de versions compress�es
%prod_spec = 1;        %  m�thode pour la d�tection de pitch est produit spectral sinon par autocorrelation
%freq_fond=[];         % tableau contenant la valeur des fr�quences fondamentales
%seuil_F0 = 0.005;  %seuil pour l'acceptation d'un nouveau pitch

%Minimal frequency resolution
dF_min=Fs/N;             

%beta coef d'inharmonicit�
%beta=0;

%alpha: coefficient for harmonic location around the true theoric harmony
%alpha=0.02;

%Window
w=hamming(N);

%Beginning of signal (e.g. attack) is discarded
xw=x(offset+1:offset+N).*w;    %xw est la fenetre de signal analys�

%Minimal number of data points to satisfy the minimal frequency resolution
Nfft_min=Fs/dF_min;

%compute the smallest power of two that satisfies the minimal frequency resolution for FFT
p = nextpow2(Nfft_min);
Nfft=2^p;

%calcul FFT
Xk=fft(xw,Nfft);

%frequency resolution of FFT
df=Fs/Nfft;

%normalisation
Xk=Xk/max(abs(Xk)+eps);

%"Reduced" frequency
f=[0:Nfft-1]/Nfft+eps;

% fr�quence maximale
Rmax = floor((Nfft-1)/(2*H));



%         figure;
%         plot([1:Nfft/2]*(Fs/Nfft), 20*log10(abs(Xk(1:Nfft/2))),'b');
%         axis([0 5000 -80 0]);
%         xlabel('Fr�quences (Hz)','fontsize',14);
%         ylabel('Spectre d''Amplitude (dB)','fontsize',14);      
%         title('Spectre d''amplitude du signal original','fontsize',14);
%         pause

       
%N_P = Nfft/(2*H);  % N_P est le R de l'�nonc� ici...
N_P = Rmax;
f_P = [0:N_P-1]*df;
P = ones(N_P, 1);

Fmin = 50;  % (en Hz)  conseill� dans l'�nonc�
Fmax = 900; % (en Hz) conseill� dans l'�nonc�

Nmin = floor(Fmin*Nfft / Fs);
Nmax = floor(Fmax*Nfft / Fs); % <= Rmax
        
%loop on the number of pitches
%example criterion could use an energy ratio
%while criterion > seuil_F0
    
    %detection of main F0
        %Compute spectral product
        
        for n=1:H
            X_tmp = abs(Xk(1:n:Nfft/2));
            P = P .* X_tmp(1:N_P);
        end
        %figure, plot(f_P, P);
            
        
        % locate maximum
        [maxx, F0] = max(P(Nmin:Nmax));

        %store value of estimated F0
        F0 = (Nmin+F0-2)*df;


    %Subtraction of main note (Main F0 with its harmonics)
        
        %localisation of harmonics around theoretical values (with or without inharmonicy coeeficient) 
        % beta: harmonicity coefficient ;  alpha: coefficient of tolerance
                
        % Harmonic suppression (wideness of an harmonic to be suppressed
        % depends on the main lob of the TF of the analysis window)
            % suppression of harmonics is done on abs(Xk) on forcing all values
            % of a harmonic peak to the minimum value of the peak (e.g. the
            % level of noise).
         
%end


end

